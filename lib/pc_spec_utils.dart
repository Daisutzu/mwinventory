// Helper per i filtri PC nella ricerca: classifica la CPU in una famiglia
// leggibile e converte le stringhe di RAM/storage in un numero (GB) per
// poterle ordinare. I dati arrivano da due fonti diverse (sigle abbreviate
// dal foglio originale tipo "I7"/"RYZ7", e nomi completi presi dal sito
// MediaWorld tipo "Intel® Core Ultra 7 356H"), quindi il riconoscimento
// deve coprire entrambi i formati.
String? cpuFamily(String? cpu) {
  if (cpu == null || cpu.isEmpty) return null;
  final c = cpu.toUpperCase();

  if (RegExp(r'^M\d').hasMatch(c) || RegExp(r'^A\d+\s*PRO$').hasMatch(c)) {
    return 'Apple Silicon';
  }
  if (c.contains('SNAPDRAGON') ||
      RegExp(r'^S?QX\d').hasMatch(c) ||
      c.contains('X1E') ||
      c.contains('X2E') ||
      c.contains('X2P')) {
    return 'Qualcomm Snapdragon';
  }
  if (c.contains('RYZEN') || c.startsWith('RYZ')) {
    return 'AMD Ryzen';
  }
  if (c.contains('MEDIATEK') || c.contains('KOMP') || c.startsWith('MKT')) {
    return 'MediaTek';
  }
  if (c.contains('INTEL') ||
      RegExp(r'^I[3579]$').hasMatch(c) ||
      RegExp(r'^C[3-9]$').hasMatch(c) ||
      RegExp(r'^U[579]$').hasMatch(c) ||
      RegExp(r'^N\d{3,4}').hasMatch(c) ||
      c == 'CEL') {
    return 'Intel';
  }
  return 'Altro';
}

// Livello preciso del processore (es. "Core i5", "Ryzen 7", "M4 Pro"),
// usato per il filtro di ricerca: la sola famiglia (Intel/Ryzen) e' troppo
// generica quando in catalogo convivono modelli molto diversi tra loro.
String? cpuTier(String? cpu) {
  if (cpu == null || cpu.isEmpty) return null;
  final c = cpu.toUpperCase();

  // Apple Silicon: il nome del chip e' gia' di per se' il "livello".
  if (RegExp(r'^M\d').hasMatch(c) || RegExp(r'^A\d+\s*PRO$').hasMatch(c)) {
    return cpu.trim();
  }

  // AMD Ryzen (sia sigla RYZ7 che nome esteso "AMD Ryzen 7 260"), con la
  // linea "Ryzen AI" tenuta distinta perche' e' una gamma diversa.
  final ryzenAi = RegExp(r'RYZ(?:EN)?\s*AI\s*(\d)').firstMatch(c);
  if (ryzenAi != null) return 'Ryzen AI ${ryzenAi.group(1)}';
  final ryzen = RegExp(r'RYZ(?:EN)?\s*(\d)').firstMatch(c);
  if (ryzen != null) return 'Ryzen ${ryzen.group(1)}';

  // Intel Core Ultra: sigla U7 (nel foglio originale "U" sta per Ultra) o
  // nome esteso "Core Ultra 7 ...".
  final coreUltraAbbrev = RegExp(r'^U([579])$').firstMatch(c);
  if (coreUltraAbbrev != null) return 'Core Ultra ${coreUltraAbbrev.group(1)}';
  final coreUltra = RegExp(r'CORE\s+ULTRA\s+([579])\b').firstMatch(c);
  if (coreUltra != null) return 'Core Ultra ${coreUltra.group(1)}';

  // Intel Core "classico" con la i (sigla I5 o nome esteso "Core i5 ...").
  final coreI = RegExp(r'^I([3579])\b').firstMatch(c) ??
      RegExp(r'CORE\s+I([3579])\b').firstMatch(c);
  if (coreI != null) return 'Core i${coreI.group(1)}';

  // Intel Core "nuova numerazione" senza la i: sigla C7 (nel foglio
  // originale "C" sta per Core) o nome esteso "Core 7 150U".
  final corePlainAbbrev = RegExp(r'^C([3-9])$').firstMatch(c);
  if (corePlainAbbrev != null) return 'Core ${corePlainAbbrev.group(1)}';
  final corePlain = RegExp(r'CORE\s+([357])\b').firstMatch(c);
  if (corePlain != null) return 'Core ${corePlain.group(1)}';

  // Intel entry-level: Celeron/Pentium serie N, oppure Celeron generico.
  if (RegExp(r'\bN\d{3,4}\b').hasMatch(c)) return 'Intel serie N';
  if (c == 'CEL' || c.contains('CELERON')) return 'Celeron';

  // Qualcomm Snapdragon: dal piu' al meno specifico.
  if (c.contains('X2') && c.contains('ELITE')) return 'Snapdragon X2 Elite';
  if (c.contains('X2') && c.contains('PLUS')) return 'Snapdragon X2 Plus';
  if (c.contains('ELITE')) return 'Snapdragon X Elite';
  if (c.contains('PLUS')) return 'Snapdragon X Plus';
  if (c.contains('SNAPDRAGON') || RegExp(r'^S?QX\d').hasMatch(c)) {
    return 'Snapdragon X';
  }

  // Fallback: usa la famiglia generica (copre anche MediaTek/"Altro").
  return cpuFamily(cpu);
}

// Ordine suggerito in cui mostrare i livelli CPU nei filtri, quando
// presenti nel catalogo. Qualunque livello non elencato qui (perche'
// nuovo o non previsto) viene comunque mostrato, in coda e in ordine
// alfabetico: vedi `_availableCpuTiers` in search_products_screen.dart.
const kCpuTierOrder = [
  'Celeron',
  'Intel serie N',
  'Core i3',
  'Core i5',
  'Core i7',
  'Core i9',
  'Core 3',
  'Core 5',
  'Core 7',
  'Core 8',
  'Core Ultra 5',
  'Core Ultra 7',
  'Core Ultra 9',
  'Ryzen 3',
  'Ryzen 5',
  'Ryzen 7',
  'Ryzen 9',
  'Ryzen AI 5',
  'Ryzen AI 7',
  'Ryzen AI 9',
  'Snapdragon X',
  'Snapdragon X Plus',
  'Snapdragon X Elite',
  'Snapdragon X2 Plus',
  'Snapdragon X2 Elite',
  'MediaTek',
];

// "16GB" -> 16, "1TB" -> 1000, per poter ordinare correttamente.
int sizeInGb(String value) {
  final m = RegExp(r'^(\d+)(GB|TB)$', caseSensitive: false).firstMatch(value);
  if (m == null) return 0;
  final n = int.parse(m.group(1)!);
  return m.group(2)!.toUpperCase() == 'TB' ? n * 1000 : n;
}
