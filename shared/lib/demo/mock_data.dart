import 'package:flutter/material.dart';

class MockData {
  static final List<Map<String, dynamic>> bikes = [
    {
      'id': 'bike_1',
      'bike_name': 'Royal Enfield Classic 350',
      'category': 'Cruiser',
      'rental_price': 1200.0,
      'security_deposit': 3000.0,
      'availability_status': 'Available',
      'registration_number': 'KA-01-HH-1234'
    },
    {
      'id': 'bike_2',
      'bike_name': 'Bajaj Pulsar NS200',
      'category': 'Sport',
      'rental_price': 800.0,
      'security_deposit': 2000.0,
      'availability_status': 'Available',
      'registration_number': 'MH-12-AB-9876'
    },
    {
      'id': 'bike_3',
      'bike_name': 'Honda Activa 6G',
      'category': 'Scooter',
      'rental_price': 400.0,
      'security_deposit': 1000.0,
      'availability_status': 'Maintenance',
      'registration_number': 'DL-04-CD-5678'
    },
    {
      'id': 'bike_4',
      'bike_name': 'KTM Duke 390',
      'category': 'Sport',
      'rental_price': 1500.0,
      'security_deposit': 5000.0,
      'availability_status': 'Available',
      'registration_number': 'TN-09-XY-3456'
    },
    {
      'id': 'bike_5',
      'bike_name': 'TVS Apache RTR 160',
      'category': 'Street',
      'rental_price': 700.0,
      'security_deposit': 1500.0,
      'availability_status': 'On Rent',
      'registration_number': 'UP-16-YZ-7890'
    },
    {
      'id': 'bike_6',
      'bike_name': 'Yamaha R15 V4',
      'category': 'Sport',
      'rental_price': 1000.0,
      'security_deposit': 2500.0,
      'availability_status': 'Available',
      'registration_number': 'TS-07-EA-1122'
    },
    {
      'id': 'bike_7',
      'bike_name': 'Suzuki Access 125',
      'category': 'Scooter',
      'rental_price': 450.0,
      'security_deposit': 1000.0,
      'availability_status': 'Available',
      'registration_number': 'WB-02-PQ-3344'
    },
    {
      'id': 'bike_8',
      'bike_name': 'Hero Splendor Plus',
      'category': 'Street',
      'rental_price': 300.0,
      'security_deposit': 500.0,
      'availability_status': 'On Rent',
      'registration_number': 'RJ-14-MN-5566'
    },
    {
      'id': 'bike_9',
      'bike_name': 'Royal Enfield Himalayan',
      'category': 'Cruiser',
      'rental_price': 1400.0,
      'security_deposit': 4000.0,
      'availability_status': 'Available',
      'registration_number': 'CH-01-AB-7788'
    },
    {
      'id': 'bike_10',
      'bike_name': 'Ather 450X',
      'category': 'Scooter',
      'rental_price': 600.0,
      'security_deposit': 2000.0,
      'availability_status': 'Available',
      'registration_number': 'KA-03-TR-9900'
    },
    {
      'id': 'bike_11',
      'bike_name': 'Honda CB350 Hness',
      'category': 'Cruiser',
      'rental_price': 1300.0,
      'security_deposit': 3500.0,
      'availability_status': 'Available',
      'registration_number': 'MH-14-LK-2233'
    },
    {
      'id': 'bike_12',
      'bike_name': 'Bajaj Dominar 400',
      'category': 'Sport',
      'rental_price': 1200.0,
      'security_deposit': 3000.0,
      'availability_status': 'Maintenance',
      'registration_number': 'GJ-05-HG-4455'
    },
    {
      'id': 'bike_13',
      'bike_name': 'Ola S1 Pro',
      'category': 'Scooter',
      'rental_price': 550.0,
      'security_deposit': 1500.0,
      'availability_status': 'Available',
      'registration_number': 'KA-51-EF-6677'
    },
    {
      'id': 'bike_14',
      'bike_name': 'TVS NTORQ 125',
      'category': 'Scooter',
      'rental_price': 450.0,
      'security_deposit': 1000.0,
      'availability_status': 'Available',
      'registration_number': 'KL-07-ZX-8899'
    },
    {
      'id': 'bike_15',
      'bike_name': 'KTM RC 200',
      'category': 'Sport',
      'rental_price': 1100.0,
      'security_deposit': 2500.0,
      'availability_status': 'On Rent',
      'registration_number': 'AP-09-CV-1122'
    },
    {
      'id': 'bike_16',
      'bike_name': 'Hero Xpulse 200',
      'category': 'Street',
      'rental_price': 800.0,
      'security_deposit': 2000.0,
      'availability_status': 'Available',
      'registration_number': 'HR-26-BN-3344'
    },
    {
      'id': 'bike_17',
      'bike_name': 'Yamaha MT-15',
      'category': 'Street',
      'rental_price': 900.0,
      'security_deposit': 2000.0,
      'availability_status': 'Available',
      'registration_number': 'PB-08-AS-5566'
    },
    {
      'id': 'bike_18',
      'bike_name': 'Suzuki Gixxer SF',
      'category': 'Sport',
      'rental_price': 850.0,
      'security_deposit': 2000.0,
      'availability_status': 'Available',
      'registration_number': 'OD-02-QW-7788'
    },
    {
      'id': 'bike_19',
      'bike_name': 'Royal Enfield Meteor 350',
      'category': 'Cruiser',
      'rental_price': 1350.0,
      'security_deposit': 3500.0,
      'availability_status': 'Available',
      'registration_number': 'UP-32-DF-9900'
    },
    {
      'id': 'bike_20',
      'bike_name': 'Honda Dio',
      'category': 'Scooter',
      'rental_price': 350.0,
      'security_deposit': 800.0,
      'availability_status': 'Available',
      'registration_number': 'TN-22-KJ-1234'
    }
  ];

  static void initializeImages() {
    for (var bike in bikes) {
      if (!bike.containsKey('imageUrl')) {
        switch (bike['category']) {
          case 'Cruiser':
            bike['imageUrl'] = 'https://images.unsplash.com/photo-1558981403-c5f9899a28bc?q=80&w=1000&auto=format&fit=crop';
            break;
          case 'Sport':
            bike['imageUrl'] = 'https://images.unsplash.com/photo-1568772585407-9361f9bf3a87?q=80&w=1000&auto=format&fit=crop';
            break;
          case 'Scooter':
            bike['imageUrl'] = 'https://images.unsplash.com/photo-1620610312674-89c02db2cbbe?q=80&w=1000&auto=format&fit=crop';
            break;
          case 'Street':
          default:
            bike['imageUrl'] = 'https://images.unsplash.com/photo-1558980663-3685c1d673c4?q=80&w=1000&auto=format&fit=crop';
            break;
        }
      }
    }
  }

  static final List<Map<String, dynamic>> customers = List.generate(60, (index) {
    final firstNames = ['Amit', 'Rahul', 'Priya', 'Sneha', 'Vikram', 'Neha', 'Rohan', 'Aditi', 'Karan', 'Pooja', 'Suresh', 'Deepa'];
    final lastNames = ['Sharma', 'Verma', 'Patel', 'Singh', 'Kumar', 'Gupta', 'Iyer', 'Reddy', 'Das', 'Joshi'];
    final statuses = ['APPROVED', 'APPROVED', 'APPROVED', 'PENDING', 'REJECTED'];
    final firstName = firstNames[index % firstNames.length];
    final lastName = lastNames[(index + 3) % lastNames.length];
    
    return {
      'id': 'cust_$index',
      'name': '$firstName $lastName',
      'phone': '+91 9${(876543210 + index * 1234).toString().padLeft(9, '0')}',
      'email': '${firstName.toLowerCase()}.${lastName.toLowerCase()}$index@gmail.com',
      'kycStatus': statuses[index % statuses.length],
      'dlUrl': 'https://placeholder.com/dl_$index.jpg',
      'aadhaarUrl': 'https://placeholder.com/aadhaar_$index.jpg',
      'isBlocked': index % 15 == 0, // Block every 15th user for demo
    };
  });

  static final List<Map<String, dynamic>> bookings = List.generate(100, (index) {
    final statuses = ['COMPLETED', 'COMPLETED', 'ACTIVE', 'CONFIRMED', 'CANCELLED', 'REJECTED'];
    final bike = bikes[index % bikes.length];
    final customer = customers[index % customers.length];
    final days = (index % 5) + 1;
    final price = bike['rental_price'] as double;
    
    return {
      'id': 'bk_$index',
      'booking_number': 'BRN${10000 + index}',
      'customer_name': customer['name'],
      'bike_name': bike['bike_name'],
      'bike_id': bike['id'],
      'pickup_date': DateTime.now().subtract(Duration(days: index)).toIso8601String(),
      'return_date': DateTime.now().subtract(Duration(days: index - days)).toIso8601String(),
      'duration_days': days,
      'price': price,
      'deposit': bike['security_deposit'],
      'taxes': price * days * 0.18,
      'final_amount': (price * days) + (price * days * 0.18),
      'booking_status': statuses[index % statuses.length],
      'payment_status': 'PAID'
    };
  });

  static final Map<String, dynamic> dashboardStats = {
    'total_bikes': 20,
    'available_bikes': 15,
    'active_rentals': 3,
    'pending_bookings': 2,
    'today_revenue': 4500.0,
    'monthly_revenue': 125000.0,
  };
}
