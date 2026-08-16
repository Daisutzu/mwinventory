import 'product.dart';

// Catalogo TV generato dai codici PIM/EAN forniti (2026-08-16).
final List<Product> tvCatalog = [
  // --- LG ---
  Product(
    id: 'tv1',
    name: '27TQ615S Monitor TV Smart 27" LED FHD 2HDMI',
    brand: 'LG',
    category: 'TV',
    imagePath: 'assets/products/lg27tq615smonitortvsmart27ledfhd2hdmi.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '177909', ean: '8806091723161', screen: '27"', color: 'Nero'),
      PcVariant(code: '180463', ean: '8806091723178', screen: '27"', color: 'Bianco'),
    ],
  ),
  // --- PEAQ ---
  Product(
    id: 'tv2',
    name: 'F260-5026KE',
    brand: 'Peaq',
    category: 'TV',
    imagePath: 'assets/products/peaqf2605026ke.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '562268', ean: '4049011222823'),
    ],
  ),
  Product(
    id: 'tv3',
    name: 'PTV24H-7026C 24" LED HD 2HDMI',
    brand: 'Peaq',
    category: 'TV',
    imagePath: 'assets/products/peaqptv24h7026c24ledhd2hdmi.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '555997', ean: '4049011219465', screen: '24"'),
    ],
  ),
  // --- STRONG ---
  Product(
    id: 'tv4',
    name: 'Q1 LCD 1280x720',
    brand: 'Strong',
    category: 'TV',
    imagePath: 'assets/products/strongq1lcd1280x720.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '427611', ean: '9120072375163'),
    ],
  ),
  // --- PEAQ ---
  Product(
    id: 'tv5',
    name: 'PTV32H-7124C 32" LED HD 2HDMI',
    brand: 'Peaq',
    category: 'TV',
    imagePath: 'assets/products/peaqptv32h7124c32ledhd2hdmi.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '398990', ean: '4049011203440', screen: '32"'),
    ],
  ),
  Product(
    id: 'tv6',
    name: 'PTV24VH-7025C 24" LED HD 2HDMI',
    brand: 'Peaq',
    category: 'TV',
    imagePath: 'assets/products/peaqptv24vh7025c24ledhd2hdmi.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '529228', ean: '4049011216723', screen: '24"'),
    ],
  ),
  Product(
    id: 'tv7',
    name: 'PTV32GH-7124C 32" LED HD 2HDMI',
    brand: 'Peaq',
    category: 'TV',
    imagePath: 'assets/products/peaqptv32gh7124c32ledhd2hdmi.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '398989', ean: '4049011203433', screen: '32"'),
    ],
  ),
  Product(
    id: 'tv8',
    name: '24GH-5025C 24" LED',
    brand: 'Peaq',
    category: 'TV',
    imagePath: 'assets/products/peaq24gh5025c24led.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '430661', ean: '4049011213128', screen: '24"'),
    ],
  ),
  Product(
    id: 'tv9',
    name: 'PTV32VH-7025C 32" LED HD 2HDMI',
    brand: 'Peaq',
    category: 'TV',
    imagePath: 'assets/products/peaqptv32vh7025c32ledhd2hdmi.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '529238', ean: '4049011216730', screen: '32"'),
    ],
  ),
  // --- TCL ---
  Product(
    id: 'tv10',
    name: '32S4K 32" LED',
    brand: 'Tcl',
    category: 'TV',
    imagePath: 'assets/products/tcl32s4k32led.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '442302', ean: '5901292526047', screen: '32"'),
    ],
  ),
  // --- HISENSE ---
  Product(
    id: 'tv11',
    name: '32A4S 32" D-LED HD 2HDMI',
    brand: 'Hisense',
    category: 'TV',
    imagePath: 'assets/products/hisense32a4s32dledhd2hdmi.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '572022', ean: '6942351429205', screen: '32"'),
    ],
  ),
  // --- PHILIPS ---
  Product(
    id: 'tv12',
    name: '32PHS6000/12 32" LED 4K 3HDMI',
    brand: 'Philips',
    category: 'TV',
    imagePath: 'assets/products/philips32phs60001232led4k3hdmi.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '496144', ean: '8718863045978', screen: '32"'),
    ],
  ),
  // --- XIAOMI ---
  Product(
    id: 'tv13',
    name: 'TV 32 A Pro 2026 QLED 4K 2HDMI',
    brand: 'Xiaomi',
    category: 'TV',
    imagePath: 'assets/products/xiaomitv32apro2026qled4k2hdmi.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '585422', ean: '6941948705524'),
    ],
  ),
  // --- PEAQ ---
  Product(
    id: 'tv14',
    name: 'PTV40F-7026C 40" LED FHD 3HDMI',
    brand: 'Peaq',
    category: 'TV',
    imagePath: 'assets/products/peaqptv40f7026c40ledfhd3hdmi.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '589003', ean: '4049011226227', screen: '40"'),
    ],
  ),
  // --- TCL ---
  Product(
    id: 'tv15',
    name: '32S5K 32" LED UHD',
    brand: 'Tcl',
    category: 'TV',
    imagePath: 'assets/products/tcl32s5k32leduhd.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '427751', ean: '5901292526030', screen: '32"'),
    ],
  ),
  // --- HISENSE ---
  Product(
    id: 'tv16',
    name: '32A5Q 32" QLED FHD 2HDMI',
    brand: 'Hisense',
    category: 'TV',
    imagePath: 'assets/products/hisense32a5q32qledfhd2hdmi.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '438075', ean: '6942351418179', screen: '32"'),
    ],
  ),
  Product(
    id: 'tv17',
    name: '40A4Q 40" D-LED FHD 2HDMI',
    brand: 'Hisense',
    category: 'TV',
    imagePath: 'assets/products/hisense40a4q40dledfhd2hdmi.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '438122', ean: '6942351418032', screen: '40"'),
    ],
  ),
  // --- PEAQ ---
  Product(
    id: 'tv18',
    name: 'PTV40GF-7124C 40" LED FHD 3HDMI',
    brand: 'Peaq',
    category: 'TV',
    imagePath: 'assets/products/peaqptv40gf7124c40ledfhd3hdmi.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '398997', ean: '4049011203457', screen: '40"'),
    ],
  ),
  Product(
    id: 'tv19',
    name: 'PTV40VF-7025C 40" LED FHD 3HDMI',
    brand: 'Peaq',
    category: 'TV',
    imagePath: 'assets/products/peaqptv40vf7025c40ledfhd3hdmi.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '529241', ean: '4049011216747', screen: '40"'),
    ],
  ),
  // --- LG ---
  Product(
    id: 'tv20',
    name: '32LQ630B6LA 32" HD Ready Smart TV 2022',
    brand: 'LG',
    category: 'TV',
    imagePath: 'assets/products/lg32lq630b6la32hdreadysmarttv2022.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '169192', ean: '8806091638373', screen: '32"'),
    ],
  ),
  Product(
    id: 'tv21',
    name: '24TQ510S Monitor TV Smart 24" LED HD 5HDMI BK',
    brand: 'LG',
    category: 'TV',
    imagePath: 'assets/products/lg24tq510smonitortvsmart24ledhd5hdmibk.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '173237', ean: '8806091548818', screen: '24"'),
    ],
  ),
  // --- TCL ---
  Product(
    id: 'tv22',
    name: '40S5K 40" LED UHD',
    brand: 'Tcl',
    category: 'TV',
    imagePath: 'assets/products/tcl40s5k40leduhd.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '427776', ean: '5901292526023', screen: '40"'),
    ],
  ),
  // --- SAMSUNG ---
  Product(
    id: 'tv23',
    name: 'UE24F6000FUXZT 24"',
    brand: 'Samsung',
    category: 'TV',
    imagePath: 'assets/products/samsungue24f6000fuxzt24.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '435574', ean: '8806097233701', screen: '24"'),
    ],
  ),
  // --- PEAQ ---
  Product(
    id: 'tv24',
    name: 'PTV43VF-7025C 43" LED FHD 3HDMI',
    brand: 'Peaq',
    category: 'TV',
    imagePath: 'assets/products/peaqptv43vf7025c43ledfhd3hdmi.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '529242', ean: '4049011216754', screen: '43"'),
    ],
  ),
  // --- HISENSE ---
  Product(
    id: 'tv25',
    name: '32A5S 32" QLED FHD 2HDMI',
    brand: 'Hisense',
    category: 'TV',
    imagePath: 'assets/products/hisense32a5s32qledfhd2hdmi.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '572063', ean: '6942351429441', screen: '32"'),
    ],
  ),
  // --- PEAQ ---
  Product(
    id: 'tv26',
    name: 'PTV55GU-7025C 55" LED UHD 4K 3HDMI',
    brand: 'Peaq',
    category: 'TV',
    imagePath: 'assets/products/peaqptv55gu7025c55leduhd4k3hdmi.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '438631', ean: '4049011213722', screen: '55"'),
    ],
  ),
  // --- HISENSE ---
  Product(
    id: 'tv27',
    name: '40A4S 40" D-LED FHD 2HDMI',
    brand: 'Hisense',
    category: 'TV',
    imagePath: 'assets/products/hisense40a4s40dledfhd2hdmi.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '572040', ean: '6942351429359', screen: '40"'),
    ],
  ),
  // --- PEAQ ---
  Product(
    id: 'tv28',
    name: 'PTV50GU-7025C 50" LED 4K 3HDMI',
    brand: 'Peaq',
    category: 'TV',
    imagePath: 'assets/products/peaqptv50gu7025c50led4k3hdmi.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '420526', ean: '4049011211308', screen: '50"'),
    ],
  ),
  Product(
    id: 'tv29',
    name: 'PTV43GU-7025C 43" LED 4K 3HDMI',
    brand: 'Peaq',
    category: 'TV',
    imagePath: 'assets/products/peaqptv43gu7025c43led4k3hdmi.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '420525', ean: '4049011210394', screen: '43"'),
    ],
  ),
  // --- SAMSUNG ---
  Product(
    id: 'tv30',
    name: 'UE27F6000FUXZT 27"',
    brand: 'Samsung',
    category: 'TV',
    imagePath: 'assets/products/samsungue27f6000fuxzt27.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '435545', ean: '8806097233718', screen: '27"'),
    ],
  ),
  // --- LG ---
  Product(
    id: 'tv31',
    name: '32LQ63006LA Smart FHD 32" LED FHD 2HDMI',
    brand: 'LG',
    category: 'TV',
    imagePath: 'assets/products/lg32lq63006lasmartfhd32ledfhd2hdmi.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '170119', ean: '8806091638359', screen: '32"'),
    ],
  ),
  Product(
    id: 'tv32',
    name: '24TQ510S Monitor TV Smart 24" LED HD 2HDMI WH',
    brand: 'LG',
    category: 'TV',
    imagePath: 'assets/products/lg24tq510smonitortvsmart24ledhd2hdmiwh.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '339058', ean: '8806091548825', screen: '24"'),
    ],
  ),
  // --- PHILIPS ---
  Product(
    id: 'tv33',
    name: '40PFS6000/12 40" LED 2K 3HDMI',
    brand: 'Philips',
    category: 'TV',
    imagePath: 'assets/products/philips40pfs60001240led2k3hdmi.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '497758', ean: '8718863045992', screen: '40"'),
    ],
  ),
  // --- PEAQ ---
  Product(
    id: 'tv34',
    name: 'PTV43VU-7025C 43" LED 4K 3HDMI',
    brand: 'Peaq',
    category: 'TV',
    imagePath: 'assets/products/peaqptv43vu7025c43led4k3hdmi.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '529243', ean: '4049011216761', screen: '43"'),
    ],
  ),
  // --- XIAOMI ---
  Product(
    id: 'tv35',
    name: 'Smart Projector L1 EU 1920x1080',
    brand: 'Xiaomi',
    category: 'TV',
    imagePath: 'assets/products/xiaomismartprojectorl1eu1920x1080.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '452454', ean: '6941812706282'),
    ],
  ),
  // --- TCL ---
  Product(
    id: 'tv36',
    name: '43P6K 43" LED UHD',
    brand: 'Tcl',
    category: 'TV',
    imagePath: 'assets/products/tcl43p6k43leduhd.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '427768', ean: '5901292522928', screen: '43"'),
    ],
  ),
  // --- XGIMI ---
  Product(
    id: 'tv37',
    name: 'Vibe One (Batteria) WH 1080p',
    brand: 'XGIMI',
    category: 'TV',
    imagePath: 'assets/products/xgimivibeonebatteriawh1080p.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '554611', ean: '6935670510051'),
    ],
  ),
  // --- HISENSE ---
  Product(
    id: 'tv38',
    name: '43A6S 43" D-LED 4K 3HDMI',
    brand: 'Hisense',
    category: 'TV',
    imagePath: 'assets/products/hisense43a6s43dled4k3hdmi.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '572069', ean: '6942351430102', screen: '43"'),
    ],
  ),
  // --- TCL ---
  Product(
    id: 'tv39',
    name: '43P7K 43" QD-LED 4HDMI',
    brand: 'Tcl',
    category: 'TV',
    imagePath: 'assets/products/tcl43p7k43qdled4hdmi.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '427954', ean: '5901292525958', screen: '43"'),
    ],
  ),
  // --- PHILIPS ---
  Product(
    id: 'tv40',
    name: '43PUS8010/12 43" LED 4K 3HDMI',
    brand: 'Philips',
    category: 'TV',
    imagePath: 'assets/products/philips43pus80101243led4k3hdmi.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '497939', ean: '8718863046289', screen: '43"'),
    ],
  ),
  // --- PEAQ ---
  Product(
    id: 'tv41',
    name: 'PTV50GU-7026C 50" LED 4K 4HDMI',
    brand: 'Peaq',
    category: 'TV',
    imagePath: 'assets/products/peaqptv50gu7026c50led4k4hdmi.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '556000', ean: '4049011219472', screen: '50"'),
    ],
  ),
  // --- LG ---
  Product(
    id: 'tv42',
    name: 'webOS 43LR60006LA 43" LED AI FHD 2HDMI',
    brand: 'LG',
    category: 'TV',
    imagePath: 'assets/products/lgwebos43lr60006la43ledaifhd2hdmi.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '442227', ean: '8806096520970', screen: '43"'),
    ],
  ),
  // --- PHILIPS ---
  Product(
    id: 'tv43',
    name: '43PUS7000/12 43" LED',
    brand: 'Philips',
    category: 'TV',
    imagePath: 'assets/products/philips43pus70001243led.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '450277', ean: '8718863046012', screen: '43"'),
    ],
  ),
  // --- PEAQ ---
  Product(
    id: 'tv44',
    name: 'PTV50VU-7026C 50" LED 4K 3HDMI',
    brand: 'Peaq',
    category: 'TV',
    imagePath: 'assets/products/peaqptv50vu7026c50led4k3hdmi.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '565213', ean: '4049011223158', screen: '50"'),
    ],
  ),
  // --- HISENSE ---
  Product(
    id: 'tv45',
    name: '40A5S 40" QLED FHD 2HDMI',
    brand: 'Hisense',
    category: 'TV',
    imagePath: 'assets/products/hisense40a5s40qledfhd2hdmi.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '572065', ean: '6942351429632', screen: '40"'),
    ],
  ),
  // --- SAMSUNG ---
  Product(
    id: 'tv46',
    name: 'UE32F6000FUXZT 32"',
    brand: 'Samsung',
    category: 'TV',
    imagePath: 'assets/products/samsungue32f6000fuxzt32.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '435544', ean: '8806095912660', screen: '32"'),
    ],
  ),
  // --- HISENSE ---
  Product(
    id: 'tv47',
    name: '43Q7S 43" QLED 4K 3HDMI',
    brand: 'Hisense',
    category: 'TV',
    imagePath: 'assets/products/hisense43q7s43qled4k3hdmi.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '572088', ean: '6942351430928', screen: '43"'),
    ],
  ),
  // --- SONY ---
  Product(
    id: 'tv48',
    name: 'KD32W800 32" LED WXGA 3HDMI',
    brand: 'Sony',
    category: 'TV',
    imagePath: 'assets/products/sonykd32w80032ledwxga3hdmi.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '184961', ean: '4548736153448', screen: '32"'),
    ],
  ),
  // --- TCL ---
  Product(
    id: 'tv49',
    name: '55P6K 55" LED UHD',
    brand: 'Tcl',
    category: 'TV',
    imagePath: 'assets/products/tcl55p6k55leduhd.png',
    variants: [],
    pcVariants: [
      PcVariant(code: '427807', ean: '5901292528386', screen: '55"'),
    ],
  ),
];
