# Far girare lo scraper prezzi su un vecchio telefono Android (Termux)

Perche' un telefono e non GitHub Actions: mediaworld.it blocca (HTTP 403)
le richieste dagli IP dei server cloud/datacenter. Un telefono connesso
al WiFi di casa/negozio ha un IP normale, come un cliente qualsiasi.

Serve un vecchio Android non piu' usato, sempre acceso e in carica,
connesso a un WiFi stabile (o dati mobili se non c'e' WiFi).

## 1. Installa Termux (NON dal Play Store, e' una versione vecchia e rotta)

1. Installa **F-Droid**: https://f-droid.org/it/ (scarica l'APK e installalo,
   Android chiedera' di autorizzare "sorgenti sconosciute" la prima volta)
2. Dentro F-Droid cerca e installa **Termux**
3. Dentro F-Droid cerca e installa anche **Termux:Boot**

## 2. Apri Termux e prepara l'ambiente

```
pkg update && pkg upgrade -y
pkg install python git cronie -y
pip install requests google-cloud-firestore
termux-setup-storage
```

(Concedi il permesso di accesso ai file quando richiesto.)

## 3. Scarica lo script (il repository e' pubblico, non serve login)

```
git clone https://github.com/Daisutzu/mwinventory.git
```

## 4. Trasferisci il file delle credenziali sul telefono

Il file e' quello che hai gia' scaricato da Firebase Console (Project
Settings -> Service accounts), attualmente su questo PC in:
`C:\Users\Utente\mwinventory-scripts\service-account.json`

Trasferiscilo **via cavo USB** (piu' sicuro di email o cloud, e' una
credenziale sensibile): collega il telefono al PC, copialo nella cartella
Download del telefono, poi in Termux:

```
mkdir -p ~/mwinventory-scripts
cp ~/storage/downloads/service-account.json ~/mwinventory-scripts/
chmod 600 ~/mwinventory-scripts/service-account.json
```

Una volta copiato, cancella la copia dalla cartella Download del telefono
(resta solo dentro Termux, che le altre app non possono leggere).

## 5. Crea lo script che lancia lo scraper

```
nano ~/mwinventory-scripts/run_price_scraper.sh
```

Incolla questo contenuto (Ctrl+O per salvare, invio, Ctrl+X per uscire):

```bash
#!/data/data/com.termux/files/usr/bin/bash
export GOOGLE_APPLICATION_CREDENTIALS=$HOME/mwinventory-scripts/service-account.json
cd $HOME/mwinventory/scripts
python scrape_prices.py >> $HOME/mwinventory-scripts/scrape_prices.log 2>&1
```

Poi rendilo eseguibile:

```
chmod +x ~/mwinventory-scripts/run_price_scraper.sh
```

## 6. Programma l'esecuzione giornaliera alle 6:00

```
crontab -e
```

Aggiungi questa riga (Ctrl+O per salvare, Ctrl+X per uscire):

```
0 6 * * * ~/mwinventory-scripts/run_price_scraper.sh
```

## 7. Fai partire crond automaticamente al riavvio del telefono

```
mkdir -p ~/.termux/boot
nano ~/.termux/boot/start-crond.sh
```

Contenuto:

```bash
#!/data/data/com.termux/files/usr/bin/bash
termux-wake-lock
crond
```

```
chmod +x ~/.termux/boot/start-crond.sh
```

Poi apri l'app **Termux:Boot** una volta (anche solo per attivarla), cosi'
Android sa che deve avviarla ad ogni riavvio.

Per avviare crond subito, senza aspettare un riavvio, esegui anche ora a
mano: `crond`

## 8. Disattiva il risparmio energetico per Termux

Impostazioni Android -> App -> Termux -> Batteria -> **Nessuna
restrizione** (il nome esatto varia da telefono a telefono, cerca
"ottimizzazione batteria" o "esecuzione in background"). Senza questo
passaggio Android puo' terminare Termux dopo qualche ora e il cron non
partira' piu'.

## 9. Verifica che funzioni

Per testare subito senza aspettare le 6:00:

```
~/mwinventory-scripts/run_price_scraper.sh
cat ~/mwinventory-scripts/scrape_prices.log
```

L'ultima riga dovrebbe essere tipo:
`Fatto. Controllati 777 codici PIM, NNN aggiornati...`

## Aggiornare lo script in futuro

Se lo scraper viene modificato nel repository, sul telefono basta:

```
cd ~/mwinventory
git pull
```

Non serve rifare nient'altro (credenziali e cron restano quelli).
