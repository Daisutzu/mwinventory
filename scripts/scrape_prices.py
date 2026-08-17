"""Scraper prezzi MediaWorld per il catalogo MW Inventory.

Legge tutti i prodotti dalla collection Firestore "products" e, per ogni
codice PIM trovato (variants[].code e pcVariants[].code), interroga la
pagina di ricerca pubblica di mediaworld.it per leggere il prezzo di
listino e l'eventuale prezzo promozionale, poi aggiorna il documento su
Firestore. L'app legge questi campi via sync (catalog_cloud_sync.dart) e
li mostra in product_detail_screen.dart: prezzo originale sempre visibile
(barrato se in promo), prezzo promo in rosso con etichetta "PROMO".

Il prezzo originale mostrato e' sempre lo strikePrice.amount di MediaWorld
(il prezzo di listino/RRP); il promoPrice viene valorizzato solo quando
MediaWorld stessa segnala la promo attiva (strikePrice.shouldBeStruck) e
il prezzo corrente e' piu' basso di quello di listino.

Autenticazione: un service account Firebase (Admin SDK), non l'account
condiviso usato per il login nell'app - sono scopi diversi (automazione
server vs accesso umano) e il service account bypassa le regole di
sicurezza di Firestore senza doverle allentare per un bot.

Uso:
    GOOGLE_APPLICATION_CREDENTIALS=/percorso/service-account.json \
        python scripts/scrape_prices.py
"""

from __future__ import annotations

import json
import re
import sys
import time

import requests
from google.cloud import firestore

REQUEST_DELAY_SECONDS = 1.5
REQUEST_TIMEOUT_SECONDS = 20
COLLECTION = "products"

HEADERS = {
    "User-Agent": (
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 "
        "(KHTML, like Gecko) Chrome/124.0 Safari/537.36"
    ),
    "Accept-Language": "it-IT,it;q=0.9",
}


def extract_preloaded_state(html: str) -> dict | None:
    """Estrae window.__PRELOADED_STATE__ dall'HTML della pagina MediaWorld.

    Non e' JSON puro (contiene token JS come "undefined"), quindi serve uno
    scanner che tenga conto di profondita' delle graffe e stringhe prima di
    poterlo passare a json.loads.
    """
    marker = "window.__PRELOADED_STATE__"
    marker_idx = html.find(marker)
    if marker_idx == -1:
        return None

    start = html.index("{", marker_idx)
    depth = 0
    in_string = False
    escaped = False
    i = start
    while i < len(html):
        char = html[i]
        if in_string:
            if escaped:
                escaped = False
            elif char == "\\":
                escaped = True
            elif char == '"':
                in_string = False
        else:
            if char == '"':
                in_string = True
            elif char == "{":
                depth += 1
            elif char == "}":
                depth -= 1
                if depth == 0:
                    i += 1
                    break
        i += 1

    raw = html[start:i]
    fixed = re.sub(r":undefined\b", ":null", raw)
    try:
        return json.loads(fixed)
    except json.JSONDecodeError:
        return None


def fetch_price(pim: str) -> tuple[float | None, float | None]:
    """Ritorna (prezzo_originale, prezzo_promo) per un codice PIM.

    prezzo_promo e' None quando il prodotto non e' in promozione.
    Ritorna (None, None) se il prodotto non viene trovato o la pagina non
    e' analizzabile (es. rete assente, layout cambiato).
    """
    url = f"https://www.mediaworld.it/it/search.html?query={pim}"
    try:
        response = requests.get(url, headers=HEADERS, timeout=REQUEST_TIMEOUT_SECONDS)
        response.raise_for_status()
    except requests.RequestException as exc:
        print(f"  [{pim}] richiesta fallita: {exc}")
        return None, None

    state = extract_preloaded_state(response.text)
    if not state:
        return None, None

    apollo_state = state.get("apolloState")
    if not apollo_state:
        return None, None

    needle = f'"id":"Media:it:{pim}"'
    for key, value in apollo_state.items():
        if not key.startswith("CofrPriceFeature:") or needle not in key:
            continue

        price_block = value.get("price") or {}
        strike_block = value.get("strikePrice") or {}
        current_amount = price_block.get("amount")
        strike_amount = strike_block.get("amount")

        if current_amount is None:
            return None, None

        original = strike_amount if strike_amount is not None else current_amount
        is_on_promo = bool(strike_block.get("shouldBeStruck")) and current_amount < original
        promo = current_amount if is_on_promo else None
        return float(original), (float(promo) if promo is not None else None)

    return None, None


def update_variants(variants: list[dict], stats: dict) -> bool:
    # doc_needs_write e' True appena troviamo anche un solo prezzo valido,
    # cosi' updatedAt si aggiorna ogni notte anche se il prezzo non e'
    # cambiato: serve a distinguere "controllato ieri sera, tutto fermo" da
    # "lo scraper non trova piu' questo prodotto da giorni".
    doc_needs_write = False
    for variant in variants:
        code = variant.get("code")
        if not code:
            continue

        price, promo_price = fetch_price(code)
        stats["checked"] += 1
        time.sleep(REQUEST_DELAY_SECONDS)

        if price is None:
            stats["not_found"] += 1
            continue

        if variant.get("price") != price or variant.get("promoPrice") != promo_price:
            stats["price_changed"] += 1

        variant["price"] = price
        variant["promoPrice"] = promo_price
        variant["updatedAt"] = int(time.time() * 1000)
        doc_needs_write = True
        stats["refreshed"] += 1
    return doc_needs_write


def main() -> int:
    db = firestore.Client()
    docs = list(db.collection(COLLECTION).stream())
    print(f"Prodotti in catalogo: {len(docs)}")

    stats = {"checked": 0, "refreshed": 0, "price_changed": 0, "not_found": 0}

    for doc in docs:
        data = doc.to_dict() or {}
        name = data.get("name", doc.id)
        variants = data.get("variants", [])
        pc_variants = data.get("pcVariants", [])

        changed_phone = update_variants(variants, stats)
        changed_pc = update_variants(pc_variants, stats)

        if changed_phone or changed_pc:
            db.collection(COLLECTION).document(doc.id).update({
                "variants": variants,
                "pcVariants": pc_variants,
            })
            print(f"Aggiornato: {name}")

    print(
        f"Fatto. Controllati {stats['checked']} codici PIM, "
        f"{stats['refreshed']} aggiornati (di cui {stats['price_changed']} "
        f"con prezzo cambiato), {stats['not_found']} non trovati."
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
