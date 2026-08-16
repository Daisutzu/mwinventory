import 'product.dart';

// Catalogo Console generato dai codici PIM/EAN forniti (2026-08-16).
final List<Product> consoleCatalog = [
  // --- SONY ---
  Product(
    id: 'cons1',
    name: 'PS5 Unità Disco',
    brand: 'Sony',
    category: 'Console',
    imagePath: 'assets/products/sonyps5unitdisco.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '215355', ean: '0711719580799'),
    ],
  ),
  Product(
    id: 'cons2',
    name: 'PlayStation Portal',
    brand: 'Sony',
    category: 'Console',
    imagePath: 'assets/products/sonyplaystationportal.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '211019', ean: '0711719580782', color: 'Standard'),
      PcVariant(code: '418594', ean: '0711719592983', color: 'Nero'),
    ],
  ),
  Product(
    id: 'cons3',
    name: 'PS5 Digital Slim (D Chassis)',
    brand: 'Sony',
    category: 'Console',
    imagePath: 'assets/products/sonyps5digitalslimdchassis.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '215349', ean: '0711719577294'),
    ],
  ),
  Product(
    id: 'cons4',
    name: 'PS5 Disc Slim (D Chassis)',
    brand: 'Sony',
    category: 'Console',
    imagePath: 'assets/products/sonyps5discslimdchassis.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '215347', ean: '0711719577171'),
    ],
  ),
  Product(
    id: 'cons5',
    name: 'PS5 Disc (E Chassis)',
    brand: 'Sony',
    category: 'Console',
    imagePath: 'assets/products/sonyps5discechassis.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '528652', ean: '0711719021247'),
    ],
  ),
  Product(
    id: 'cons6',
    name: 'PS5 Digital + 2 DualSense',
    brand: 'Sony',
    category: 'Console',
    imagePath: 'assets/products/sonyps5digitalplus2dualsense.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '551888', ean: '0711719022633'),
    ],
  ),
  Product(
    id: 'cons7',
    name: 'PlayStation 5 Pro',
    brand: 'Sony',
    category: 'Console',
    imagePath: 'assets/products/sonyplaystation5pro.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '548489', ean: '0711719024040', storage: '2TB'),
    ],
  ),
  // --- NINTENDO ---
  Product(
    id: 'cons8',
    name: 'Switch Lite',
    brand: 'Nintendo',
    category: 'Console',
    imagePath: 'assets/products/nintendoswitchlite.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '110289', ean: '0045496452711', color: 'Turchese'),
    ],
  ),
  Product(
    id: 'cons9',
    name: 'Switch OLED',
    brand: 'Nintendo',
    category: 'Console',
    imagePath: 'assets/products/nintendoswitcholed.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '163046', ean: '0045496453435', color: 'Bianca'),
    ],
  ),
  Product(
    id: 'cons10',
    name: 'Switch',
    brand: 'Nintendo',
    category: 'Console',
    imagePath: 'assets/products/nintendoswitch.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '184273', ean: '0045496453596', color: 'Rosso Neon e Blu Neon'),
    ],
  ),
  Product(
    id: 'cons11',
    name: 'Switch 2',
    brand: 'Nintendo',
    category: 'Console',
    imagePath: 'assets/products/nintendoswitch2.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '430529', ean: '0045496321444', color: 'Nera'),
    ],
  ),
  Product(
    id: 'cons12',
    name: 'Switch 2 + Mario Kart World',
    brand: 'Nintendo',
    category: 'Console',
    imagePath: 'assets/products/nintendoswitch2plusmariokartworld.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '430530', ean: '0045496321529'),
    ],
  ),
  // --- META QUEST ---
  Product(
    id: 'cons13',
    name: '3S',
    brand: 'Meta Quest',
    category: 'Console',
    imagePath: 'assets/products/metaquest3s.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '425939', ean: '0815820025252', storage: '128GB'),
      PcVariant(code: '426333', ean: '0815820025313', storage: '256GB'),
    ],
  ),
  Product(
    id: 'cons14',
    name: '3',
    brand: 'Meta Quest',
    category: 'Console',
    imagePath: 'assets/products/metaquest3.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '426334', ean: '0815820024101', storage: '512GB'),
    ],
  ),
  // --- ASUS ---
  Product(
    id: 'cons15',
    name: 'ROG Xbox Ally',
    brand: 'Asus',
    category: 'Console',
    imagePath: 'assets/products/asusrogxboxally.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '465583', ean: '4711636195119', storage: '512GB'),
    ],
  ),
  Product(
    id: 'cons16',
    name: 'ROG Xbox Ally X',
    brand: 'Asus',
    category: 'Console',
    imagePath: 'assets/products/asusrogxboxallyx.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '465550', ean: '4711636195102', storage: '1TB'),
    ],
  ),
];
