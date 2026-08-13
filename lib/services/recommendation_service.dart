import '../models/product_model.dart';

class RecommendationService {
  // Return healthier alternatives if product score is below 60
  List<ProductModel> getAlternatives(ProductModel product) {
    if (product.score >= 60) return [];

    final nameLower = product.name.toLowerCase();
    final categoryLower = product.category.toLowerCase();

    // 1. Soft drinks / Soda / Cola
    if (nameLower.contains('cola') ||
        nameLower.contains('soda') ||
        nameLower.contains('drink') ||
        nameLower.contains('pepsi') ||
        nameLower.contains('lemonade') ||
        categoryLower.contains('drink') ||
        categoryLower.contains('beverage')) {
      return [
        ProductModel(
          barcode: '5449000000484',
          name: 'Sparkling Spring Water with Lemon',
          brand: 'San Pellegrino',
          imageUrl: 'https://images.openfoodfacts.org/images/products/544/900/000/0484/front_en.3.400.jpg',
          ingredients: ['Carbonated Water', 'Natural Lemon Extract'],
          calories: 12.0,
          sugar: 0.1,
          protein: 0.0,
          fat: 0.0,
          allergens: [],
          score: 92,
          category: 'Excellent',
        ),
        ProductModel(
          barcode: '5000159480602',
          name: 'Diet Cola Zero Sugar',
          brand: 'Diet Choice',
          imageUrl: 'https://images.openfoodfacts.org/images/products/500/015/948/0602/front_en.3.400.jpg',
          ingredients: [
            'Carbonated Water',
            'Colour (Caramel)',
            'Sweeteners (Aspartame)',
          ],
          calories: 0.5,
          sugar: 0.0,
          protein: 0.0,
          fat: 0.0,
          allergens: [],
          score: 75,
          category: 'Good',
        ),
        ProductModel(
          barcode: '5000112637999',
          name: 'Pure Green Tea Infusion',
          brand: 'Twinings',
          imageUrl: 'https://images.openfoodfacts.org/images/products/500/011/263/7999/front_en.3.400.jpg',
          ingredients: ['Green Tea'],
          calories: 2.0,
          sugar: 0.0,
          protein: 0.0,
          fat: 0.0,
          allergens: [],
          score: 95,
          category: 'Excellent',
        ),
      ].take(3).toList();
    }
    // 2. Chocolate / Confectionery / Snacks / Nutella
    else if (nameLower.contains('chocolate') ||
        nameLower.contains('nutella') ||
        nameLower.contains('spread') ||
        nameLower.contains('candy') ||
        nameLower.contains('crisps') ||
        nameLower.contains('snack') ||
        nameLower.contains('biscuit')) {
      return [
        ProductModel(
          barcode: '3046920025621',
          name: 'Organic 85% Dark Chocolate',
          brand: 'Green & Black\'s',
          imageUrl: 'https://images.openfoodfacts.org/images/products/304/692/002/5621/front_en.11.400.jpg',
          ingredients: [
            'Organic Cocoa Mass',
            'Organic Raw Cane Sugar',
            'Organic Cocoa Butter',
            'Vanilla Extract',
          ],
          calories: 580.0,
          sugar: 14.0,
          protein: 9.5,
          fat: 48.0,
          allergens: [],
          score: 72,
          category: 'Good',
        ),
        ProductModel(
          barcode: '7622210449283',
          name: 'Almond & Sea Salt Dark Bar',
          brand: 'Divine',
          imageUrl: 'https://images.openfoodfacts.org/images/products/762/221/044/9283/front_en.7.400.jpg',
          ingredients: ['Cocoa Mass', 'Sugar', 'Almonds (15%)', 'Sea Salt'],
          calories: 550.0,
          sugar: 18.0,
          protein: 8.5,
          fat: 42.0,
          allergens: ['Nuts'],
          score: 68,
          category: 'Fair',
        ),
        ProductModel(
          barcode: '5010029117688',
          name: 'Baked Lentil Crisps Sea Salt',
          brand: 'Priya Snacks',
          imageUrl: 'https://images.openfoodfacts.org/images/products/501/002/911/7688/front_en.3.400.jpg',
          ingredients: [
            'Lentil Flour',
            'Potato Starch',
            'Corn Flour',
            'Rapeseed Oil',
            'Sea Salt',
          ],
          calories: 420.0,
          sugar: 1.5,
          protein: 12.0,
          fat: 14.0,
          allergens: [],
          score: 78,
          category: 'Good',
        ),
      ].take(3).toList();
    }
    // 3. Cereal & Bread
    else if (nameLower.contains('cereal') ||
        nameLower.contains('granola') ||
        nameLower.contains('bread') ||
        nameLower.contains('toast')) {
      return [
        ProductModel(
          barcode: '5000112637953',
          name: 'Organic Wholewheat Seeded Bread',
          brand: 'Hovis',
          imageUrl: 'https://images.openfoodfacts.org/images/products/500/011/263/7953/front_en.3.400.jpg',
          ingredients: [
            'Wholewheat Flour',
            'Water',
            'Mixed Seeds (12%)',
            'Yeast',
            'Salt',
          ],
          calories: 245.0,
          sugar: 2.2,
          protein: 11.0,
          fat: 4.5,
          allergens: ['Gluten', 'Seeds'],
          score: 84,
          category: 'Excellent',
        ),
        ProductModel(
          barcode: '5000112637954',
          name: 'Organic Rolled Porridge Oats',
          brand: 'Flahavan\'s',
          imageUrl: 'https://images.openfoodfacts.org/images/products/500/011/263/7954/front_en.3.400.jpg',
          ingredients: ['100% Irish Wholegrain Rolled Oats'],
          calories: 375.0,
          sugar: 1.0,
          protein: 11.0,
          fat: 7.0,
          allergens: ['Gluten'],
          score: 94,
          category: 'Excellent',
        ),
      ].take(3).toList();
    }
    // 4. Milk & Dairy
    else if (nameLower.contains('milk') ||
        nameLower.contains('cheese') ||
        nameLower.contains('yogurt') ||
        nameLower.contains('cream')) {
      return [
        ProductModel(
          barcode: '5000112637952',
          name: 'Organic Semi-Skimmed Milk',
          brand: 'Tesco',
          imageUrl: 'https://images.openfoodfacts.org/images/products/500/011/263/7952/front_en.3.400.jpg',
          ingredients: ['Organic Cow\'s Milk'],
          calories: 50.0,
          sugar: 4.8,
          protein: 3.6,
          fat: 1.8,
          allergens: ['MILK'],
          score: 88,
          category: 'Excellent',
        ),
        ProductModel(
          barcode: '5010029117604',
          name: 'Greek Style Natural Yogurt',
          brand: 'Fage',
          imageUrl: 'https://images.openfoodfacts.org/images/products/501/002/911/7604/front_en.11.400.jpg',
          ingredients: ['Pasteurised Cow\'s Milk', 'Live Yogurt Cultures'],
          calories: 97.0,
          sugar: 4.0,
          protein: 9.0,
          fat: 5.0,
          allergens: ['MILK'],
          score: 85,
          category: 'Excellent',
        ),
      ].take(3).toList();
    } else {
      // Generic healthy alternatives
      return [
        ProductModel(
          barcode: '5000112637952',
          name: 'Organic Whole Milk',
          brand: 'Tesco',
          imageUrl: 'https://images.openfoodfacts.org/images/products/500/011/263/7952/front_en.3.400.jpg',
          ingredients: ['Organic Cow\'s Milk'],
          calories: 62.0,
          sugar: 4.7,
          protein: 3.4,
          fat: 3.6,
          allergens: ['MILK'],
          score: 82,
          category: 'Excellent',
        ),
        ProductModel(
          barcode: '5010029117604',
          name: 'Baked Beans in Tomato Sauce',
          brand: 'Heinz',
          imageUrl: 'https://images.openfoodfacts.org/images/products/501/002/911/7604/front_en.11.400.jpg',
          ingredients: [
            'Beans (51%)',
            'Tomatoes (34%)',
            'Water',
            'Sugar',
            'Salt',
          ],
          calories: 79.0,
          sugar: 4.7,
          protein: 4.7,
          fat: 0.2,
          allergens: [],
          score: 74,
          category: 'Good',
        ),
        ProductModel(
          barcode: '5000112637955',
          name: 'Mixed Berry Fruit Smoothie',
          brand: 'Innocent',
          imageUrl: 'https://images.openfoodfacts.org/images/products/500/011/263/7955/front_en.3.400.jpg',
          ingredients: [
            'Pressed Apple',
            'Mashed Banana',
            'Whole Blueberries',
            'Crushed Strawberries',
          ],
          calories: 52.0,
          sugar: 11.2,
          protein: 0.8,
          fat: 0.2,
          allergens: [],
          score: 78,
          category: 'Good',
        ),
      ].take(3).toList();
    }
  }
}
