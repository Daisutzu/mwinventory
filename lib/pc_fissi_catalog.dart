import 'product.dart';

// Catalogo PC Fissi generato dai codici PIM/EAN forniti (2026-08-16).
// I modelli desktop Apple (Mac Mini/iMac/Mac Studio), inizialmente
// importati sotto 'PC' insieme ai notebook, sono stati spostati qui.
final List<Product> pcFissiCatalog = [
  // --- MEDIACOM ---
  Product(
    id: 'pcf1',
    name: 'Mini PC 103',
    brand: 'Mediacom',
    category: 'PC Fissi',
    imagePath: 'assets/products/mediacomminipc103.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '361500', ean: '8028153131275', cpu: 'N4020', ram: '4GB', storage: '128GB'),
    ],
  ),
  // --- ASUS ---
  Product(
    id: 'pcf2',
    name: 'AIO V440VAK',
    brand: 'Asus',
    category: 'PC Fissi',
    imagePath: 'assets/products/asusaiov440vak.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '428834', ean: '4711387852866', cpu: 'I5', ram: '8GB', storage: '512GB'),
    ],
  ),
  Product(
    id: 'pcf3',
    name: 'AIO VM670GA',
    brand: 'Asus',
    category: 'PC Fissi',
    imagePath: 'assets/products/asusaiovm670ga.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '576133', ean: '4711636479967', cpu: 'RYZ5', ram: '16GB', storage: '512GB'),
    ],
  ),
  // --- HP ---
  Product(
    id: 'pcf4',
    name: 'All-in-One 24-CR0083NL',
    brand: 'HP',
    category: 'PC Fissi',
    imagePath: 'assets/products/hpallinone24cr0083nl.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '563051', ean: '0199896044820', cpu: 'RYZ3', ram: '8GB', storage: '512GB'),
    ],
  ),
  Product(
    id: 'pcf5',
    name: 'All-in-One 24-cr0095nl',
    brand: 'HP',
    category: 'PC Fissi',
    imagePath: 'assets/products/hpallinone24cr0095nl.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '590150', ean: '0821844651643', cpu: 'I5', ram: '8GB', storage: '512GB'),
    ],
  ),
  Product(
    id: 'pcf6',
    name: 'OmniDesk M02-0033NL',
    brand: 'HP',
    category: 'PC Fissi',
    imagePath: 'assets/products/hpomnideskm020033nl.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '552059', ean: '0199642546929', cpu: 'I7', ram: '16GB', storage: '512GB'),
    ],
  ),
  Product(
    id: 'pcf7',
    name: 'All-in-One 27-CR1013NL',
    brand: 'HP',
    category: 'PC Fissi',
    imagePath: 'assets/products/hpallinone27cr1013nl.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '563714', ean: '0199896044875', cpu: 'U5', ram: '16GB', storage: '512GB'),
    ],
  ),
  Product(
    id: 'pcf8',
    name: 'OMEN 16L Gaming TG03-0049nl',
    brand: 'HP',
    category: 'PC Fissi',
    imagePath: 'assets/products/hpomen16lgamingtg030049nl.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '590180', ean: '0821844671276', cpu: 'RYZ7', ram: '16GB', storage: '1TB', gpu: 'RTX5060-8'),
    ],
  ),
  // --- LENOVO ---
  Product(
    id: 'pcf9',
    name: 'IdeaCentre Tower',
    brand: 'Lenovo',
    category: 'PC Fissi',
    imagePath: 'assets/products/lenovoideacentretower.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '531774', ean: '0199272592075', cpu: 'I5', ram: '16GB', storage: '1TB'),
    ],
  ),
  Product(
    id: 'pcf10',
    name: 'IdeaCentre AIO 27ARR9',
    brand: 'Lenovo',
    category: 'PC Fissi',
    imagePath: 'assets/products/lenovoideacentreaio27arr9.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '394622', ean: '0197530090615', cpu: 'RYZ5', ram: '16GB', storage: '512GB'),
    ],
  ),
  Product(
    id: 'pcf11',
    name: 'IdeaCentre AIO',
    brand: 'Lenovo',
    category: 'PC Fissi',
    imagePath: 'assets/products/lenovoideacentreaio.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '590739', ean: '0199275382949', cpu: 'U5', ram: '16GB', storage: '512GB'),
    ],
  ),
  Product(
    id: 'pcf12',
    name: 'LOQ Tower',
    brand: 'Lenovo',
    category: 'PC Fissi',
    imagePath: 'assets/products/lenovoloqtower.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '498135', ean: '0199271507605', cpu: 'I5', ram: '16GB', storage: '1TB+512GB', gpu: 'RTX5060-8'),
      PcVariant(code: '590740', ean: '0199275396533', cpu: 'RYZ7', ram: '16GB', storage: '1TB', gpu: 'RTX5060-8'),
    ],
  ),
  // --- ACER ---
  Product(
    id: 'pcf13',
    name: 'Aspire C27A-GRPL',
    brand: 'Acer',
    category: 'PC Fissi',
    imagePath: 'assets/products/aceraspirec27agrpl.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '562317', ean: '4711474748140', cpu: 'C5', ram: '16GB', storage: '512GB'),
    ],
  ),
  Product(
    id: 'pcf14',
    name: 'Nitro 50 N50-656',
    brand: 'Acer',
    category: 'PC Fissi',
    imagePath: 'assets/products/acernitro50n50656.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '562307', ean: '4711474888945', cpu: 'I5', ram: '32GB', storage: '1TB', gpu: 'RTX5060-8'),
    ],
  ),
  // --- MSI ---
  Product(
    id: 'pcf15',
    name: 'MAG Infinite S3 14-2681IT',
    brand: 'MSI',
    category: 'PC Fissi',
    imagePath: 'assets/products/msimaginfinites3142681it.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '454333', ean: '4711377328685', cpu: 'I7', ram: '16GB', storage: '1TB', gpu: 'RTX5070-12'),
    ],
  ),
  Product(
    id: 'pcf16',
    name: 'MAG Infinite S AI 2NVL7-008EU',
    brand: 'MSI',
    category: 'PC Fissi',
    imagePath: 'assets/products/msimaginfinitesai2nvl7008eu.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '584831', ean: '4711377436694', cpu: 'U7', ram: '32GB', storage: '1TB', gpu: 'RTX5060-8'),
    ],
  ),
  // --- APPLE ---
  Product(
    id: 'pcf17',
    name: 'Mac Mini',
    brand: 'Apple',
    category: 'PC Fissi',
    imagePath: 'assets/products/applemacmini.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '187604', cpu: 'M4 Pro', ram: '24GB', storage: '512GB', gpu: '12-core CPU, 16-core GPU'),
      PcVariant(code: '187610', cpu: 'M4', ram: '16GB', storage: '512GB', gpu: '10-core CPU, 10-core GPU'),
      PcVariant(code: '187613', ean: '0195949080418', cpu: 'M4', ram: '16GB', storage: '256GB', gpu: '10-core CPU, 10-core GPU'),
    ],
  ),
  Product(
    id: 'pcf18',
    name: 'iMac 24\'\'',
    brand: 'Apple',
    category: 'PC Fissi',
    imagePath: 'assets/products/appleimac24.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '374603', cpu: 'M4', ram: '16GB', storage: '256GB', gpu: '8-core CPU, 8-core GPU', screen: '24"', color: 'Argento'),
      PcVariant(code: '374604', cpu: 'M4', ram: '16GB', storage: '256GB', gpu: '8-core CPU, 8-core GPU', screen: '24"', color: 'Verde'),
      PcVariant(code: '374607', cpu: 'M4', ram: '16GB', storage: '256GB', gpu: '8-core CPU, 8-core GPU', screen: '24"', color: 'Blu'),
      PcVariant(code: '374609', ean: '0195949593413', cpu: 'M4', ram: '16GB', storage: '256GB', gpu: '8-core CPU, 8-core GPU', screen: '24"', color: 'Rosa'),
      PcVariant(code: '374617', ean: '0195949597398', cpu: 'M4', ram: '16GB', storage: '256GB', gpu: '10-core CPU, 10-core GPU', screen: '24"'),
      PcVariant(code: '215071', ean: '0195950080957', cpu: 'M4', ram: '16GB', storage: '256GB', gpu: '10-core CPU, 10-core GPU', screen: '24"'),
    ],
  ),
  Product(
    id: 'pcf19',
    name: 'Mac Studio',
    brand: 'Apple',
    category: 'PC Fissi',
    imagePath: 'assets/products/applemacstudio.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '424436', ean: '0195949056413', cpu: 'M4 Max', ram: '36GB', storage: '512GB', gpu: '14-core CPU, 32-core GPU'),
      PcVariant(code: '424437', cpu: 'M3 Ultra', ram: '96GB', storage: '1TB', gpu: '25-core CPU, 60-core GPU'),
    ],
  ),
  Product(
    id: 'pcf20',
    name: 'iMac 24\'\' CTO con display Retina 4,5K',
    brand: 'Apple',
    category: 'PC Fissi',
    imagePath: 'assets/products/appleimac24ctocondisplayretina45k.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '566258', ean: '2400007769166', cpu: 'M4', ram: '16GB', storage: '256GB', gpu: '8-core CPU, 8-core GPU', screen: '24"', color: 'Argento con Gigabit Ethernet'),
      PcVariant(code: '582906', cpu: 'M4', ram: '16GB', storage: '256GB', gpu: '8-core CPU, 8-core GPU', screen: '24"', color: 'Blu con Gigabit Ethernet'),
    ],
  ),
];
