import '../models/product_model.dart';

class ProductService {
  // Mock recent scans / database for Version 0.1
  // TODO: Future API integration - connect to Open Food Facts API or Firebase Firestore
  final List<ProductModel> _recentScans = [
    const ProductModel(
      barcode: '5000112637952',
      name: 'Organic Whole Milk',
      brand: 'Tesco',
      ingredients: ['Organic Cow\'s Milk'],
      calories: 62.0,
      sugar: 4.7,
      protein: 3.4,
      fat: 3.6,
      score: 78,
    ),
    const ProductModel(
      barcode: '5010029117604',
      name: 'Baked Beans in Tomato Sauce',
      brand: 'Heinz',
      ingredients: [
        'Beans (51%)',
        'Tomatoes (34%)',
        'Water',
        'Sugar',
        'Spirit Vinegar',
        'Modified Cornflower',
        'Salt',
        'Spice Extracts',
        'Herb Extract',
      ],
      calories: 79.0,
      sugar: 4.7,
      protein: 4.7,
      fat: 0.2,
      score: 65,
    ),
    const ProductModel(
      barcode: '5000159480602',
      name: 'Diet Coke',
      brand: 'Coca-Cola',
      ingredients: [
        'Carbonated Water',
        'Colour (Caramel E150d)',
        'Sweeteners (Aspartame, Acesulfame K)',
        'Natural Flavourings',
        'Caffeine',
        'Acid (Phosphoric Acid)',
        'Citric Acid',
      ],
      calories: 0.5,
      sugar: 0.0,
      protein: 0.0,
      fat: 0.0,
      score: 42,
    ),
  ];

  // Fetch recent scans
  Future<List<ProductModel>> getRecentScans() async {
    // TODO: Future API / Local DB integration (e.g. Hive or SQLite or Firebase local cache)
    await Future.delayed(
      const Duration(milliseconds: 300),
    ); // simulate network/disk latency
    return _recentScans;
  }

  // Fetch product by barcode
  Future<ProductModel?> scanProduct(String barcode) async {
    // TODO: Future API integration - call REST API or Firebase Functions
    await Future.delayed(const Duration(milliseconds: 500));

    // Check if exists in mock list or return a default scanned item
    try {
      return _recentScans.firstWhere((p) => p.barcode == barcode);
    } catch (_) {
      // Return a generic mock product if barcode not found in preset
      return ProductModel(
        barcode: barcode,
        name: 'British Mature Cheddar',
        brand: 'Sainsbury\'s',
        ingredients: [
          'Pasteurised Cow\'s Milk',
          'Salt',
          'Starter Culture',
          'Rennet',
        ],
        calories: 416.0,
        sugar: 0.1,
        protein: 25.4,
        fat: 34.9,
        score: 55,
      );
    }
  }

  // Add product to recent scans
  void addRecentScan(ProductModel product) {
    // TODO: Future API/Local DB persistence
    _recentScans.removeWhere((p) => p.barcode == product.barcode);
    _recentScans.insert(0, product);
  }
}
