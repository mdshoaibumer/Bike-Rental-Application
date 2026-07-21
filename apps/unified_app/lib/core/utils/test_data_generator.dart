import 'dart:math';
import '../../features/bikes/providers/bike_provider.dart';

class TestDataGenerator {
  static final _random = Random(42); // Seed for deterministic output

  static final List<String> _brands = ['Honda', 'Yamaha', 'Royal Enfield', 'KTM', 'Bajaj', 'TVS', 'Suzuki', 'Kawasaki'];
  static final List<String> _models = ['CBR', 'R15', 'Classic 350', 'Duke 390', 'Pulsar', 'Apache', 'Gixxer', 'Ninja'];
  static final List<String> _colors = ['Red', 'Blue', 'Black', 'White', 'Silver', 'Green', 'Yellow'];
  static final List<String> _categories = ['Sport', 'Cruiser', 'Naked', 'Adventure', 'Scooter'];

  static List<Bike> generateMockBikes(int count) {
    return List.generate(count, (index) {
      final brand = _brands[_random.nextInt(_brands.length)];
      final model = _models[_random.nextInt(_models.length)];
      final category = _categories[_random.nextInt(_categories.length)];
      final isAvailable = _random.nextDouble() > 0.2; // 80% available
      
      String localImage;
      switch (category) {
        case 'Cruiser':
          localImage = 'assets/images/bikes/cruiser_bike.png';
          break;
        case 'Adventure':
          localImage = 'assets/images/bikes/adventure_bike.png';
          break;
        case 'Scooter':
          localImage = 'assets/images/bikes/scooter.png';
          break;
        case 'Sport':
        case 'Naked':
        default:
          localImage = 'assets/images/bikes/sport_bike.png';
      }
      
      return Bike(
        id: 'mock_bike_${index + 1}',
        bikeName: '$brand $model ${2020 + _random.nextInt(5)}',
        brand: brand,
        model: model,
        category: category,
        rentalPrice: 15.0 + _random.nextInt(35),
        securityDeposit: 100.0 + _random.nextInt(200),
        availabilityStatus: isAvailable ? 'Available' : 'Rented',
        description: 'A well-maintained $brand $model ready for your next adventure. Perfect for city commutes or weekend getaways.',
        color: _colors[_random.nextInt(_colors.length)],
        engineCC: 150 + _random.nextInt(850),
        fuelType: 'Petrol',
        transmission: 'Manual',
        imageUrl: localImage,
        registrationNumber: 'DL-${10 + _random.nextInt(90)}-${1000 + _random.nextInt(9000)}',
      );
    });
  }

  static List<Map<String, dynamic>> generateMockBikesJson(int count) {
    return generateMockBikes(count).map((b) => {
      'id': b.id,
      'bike_name': b.bikeName,
      'brand': b.brand,
      'model': b.model,
      'category': b.category,
      'rental_price': b.rentalPrice,
      'security_deposit': b.securityDeposit,
      'availability_status': b.availabilityStatus,
      'description': b.description,
      'color': b.color,
      'engine_cc': b.engineCC,
      'fuel_type': b.fuelType,
      'transmission': b.transmission,
      'image_url': b.imageUrl,
      'registration_number': b.registrationNumber,
    }).toList();
  }
}
