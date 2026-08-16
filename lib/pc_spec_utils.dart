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
  if (c.contains('MEDIATEK') || c.contains('KOMPANIO') || c.startsWith('MKT')) {
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

const kCpuFamilyOrder = [
  'Apple Silicon',
  'Intel',
  'AMD Ryzen',
  'Qualcomm Snapdragon',
  'MediaTek',
  'Altro',
];

// "16GB" -> 16, "1TB" -> 1000, per poter ordinare correttamente.
int sizeInGb(String value) {
  final m = RegExp(r'^(\d+)(GB|TB)$', caseSensitive: false).firstMatch(value);
  if (m == null) return 0;
  final n = int.parse(m.group(1)!);
  return m.group(2)!.toUpperCase() == 'TB' ? n * 1000 : n;
}
