import 'package:flutter/material.dart';

/// The Property model used by every screen, plus the design-time
/// sample listings. Live listings now come from the API
/// (ApiListing.toProperty in api_listing.dart); the samples remain
/// as labelled design samples (e.g. guest My Ads).
class Property {
  const Property({
    required this.id,
    required this.title,
    required this.priceLabel,
    required this.priceValue,
    required this.isRent,
    required this.type,
    required this.area,
    required this.city,
    required this.sizeLabel,
    required this.beds,
    required this.baths,
    required this.postedLabel,
    required this.status,
    required this.description,
    required this.sellerName,
    required this.sellerType,
    required this.sellerRating,
    required this.sellerJoined,
    required this.phoneMasked,
    required this.phoneFull,
    required this.icon,
    required this.photoCount,
    this.amenities = const [],
    this.addedDate = '4 November 2026',
    this.views = 0,
    this.imageUrls = const [],
    this.sellerAvatarUrl,
  });

  final String id;
  final String title;
  final String priceLabel;
  final int priceValue; // in PKR, for sorting/filtering (design only)
  final bool isRent;
  final String type;
  final String area;
  final String city;
  final String sizeLabel;
  final int beds; // 0 = not applicable (plots/commercial)
  final int baths;
  final String postedLabel;
  final String status;
  final String description;
  final String sellerName;
  final String sellerType;
  final double sellerRating;
  final String sellerJoined;
  final String phoneMasked;
  final String phoneFull;
  final IconData icon;
  final int photoCount;
  final List<String> amenities;
  final String addedDate;
  final int views;

  /// Real photo URLs (API listings); empty for design samples,
  /// which show the icon placeholder instead.
  final List<String> imageUrls;
  final String? sellerAvatarUrl;

  String get location => '$area, $city';
}

const List<Property> dummyProperties = [
  Property(
    id: 'p1',
    title: '5 Marla Brand New House',
    priceLabel: 'PKR 1.45 Crore',
    priceValue: 14500000,
    isRent: false,
    type: 'House',
    area: 'Eden Gardens',
    city: 'Faisalabad',
    sizeLabel: '5 Marla (Normal)',
    beds: 4,
    baths: 3,
    postedLabel: '2 days ago',
    views: 231,
    status: 'Ready to move',
    description:
        'Brand new double storey house with imported fittings, Spanish tiles, solid wood work and a peaceful street. Near to main boulevard, schools and market.',
    sellerName: 'Marwa',
    sellerType: 'Property Owner',
    sellerRating: 3.0,
    sellerJoined: 'Oct 2026',
    phoneMasked: '+92 300 XXX XXXX',
    phoneFull: '+92 300 1112233',
    icon: Icons.house_rounded,
    photoCount: 6,
    amenities: [
      'Parking',
      'Gas available',
      'Electricity Backup',
      'Boundary Wall',
    ],
  ),
  Property(
    id: 'p2',
    title: '2 Bed Luxury Apartment',
    priceLabel: 'PKR 85,000 / mo',
    priceValue: 85000,
    isRent: true,
    type: 'Flat / Apartment',
    area: 'Gulberg',
    city: 'Lahore',
    sizeLabel: '1,250 Sq. Ft.',
    beds: 2,
    baths: 2,
    postedLabel: '5 hours ago',
    views: 87,
    status: 'Ready to move',
    description:
        'Furnished apartment in a secure building with lift, standby generator and underground parking. Ideal for small families and executives.',
    sellerName: 'Ahmed Raza',
    sellerType: 'Agent',
    sellerRating: 4.5,
    sellerJoined: 'Mar 2026',
    phoneMasked: '+92 321 XXX XXXX',
    phoneFull: '+92 321 4445566',
    icon: Icons.apartment_rounded,
    photoCount: 8,
    amenities: ['Elevator/Lift', 'Furnished', 'Security Staff/CCTV', 'Parking'],
  ),
  Property(
    id: 'p3',
    title: '10 Marla House for Rent',
    priceLabel: 'PKR 150,000 / mo',
    priceValue: 150000,
    isRent: true,
    type: 'House',
    area: 'DHA Defence',
    city: 'Lahore',
    sizeLabel: '10 Marla (Normal)',
    beds: 5,
    baths: 4,
    postedLabel: '1 day ago',
    status: 'Ready to move',
    description:
        'Spacious house with lush green lawn, servant quarter and separate gate. Walking distance to DHA school and commercial market.',
    sellerName: 'Bilal Hussain',
    sellerType: 'Property Owner',
    sellerRating: 4.0,
    sellerJoined: 'Jan 2026',
    phoneMasked: '+92 333 XXX XXXX',
    phoneFull: '+92 333 7778899',
    icon: Icons.villa_rounded,
    photoCount: 10,
    amenities: ['Lawn/Garden', 'Servant quarter', 'Parking', 'Park facing'],
  ),
  Property(
    id: 'p4',
    title: '1 Kanal Residential Plot',
    priceLabel: 'PKR 4.90 Crore',
    priceValue: 49000000,
    isRent: false,
    type: 'Residential Plot',
    area: 'DHA Phase 6',
    city: 'Lahore',
    sizeLabel: '1 Kanal',
    beds: 0,
    baths: 0,
    postedLabel: '3 days ago',
    status: 'Possession Available',
    description:
        'Level plot on a 40 ft road, all development charges paid. Clear title, ideal for building your dream home in a prime block.',
    sellerName: 'Usman Tariq',
    sellerType: 'Agent',
    sellerRating: 4.2,
    sellerJoined: 'Jun 2026',
    phoneMasked: '+92 302 XXX XXXX',
    phoneFull: '+92 302 2223344',
    icon: Icons.landscape_rounded,
    photoCount: 3,
    views: 48,
    amenities: ['Possession Available', 'Boundary Wall', 'Main Boulevard'],
  ),
  Property(
    id: 'p5',
    title: 'Hostel for Students — Bed Space',
    priceLabel: 'PKR 23,456 / mo',
    priceValue: 23456,
    isRent: true,
    type: 'Room / Hostel',
    area: 'Sargodha Road',
    city: 'Faisalabad',
    sizeLabel: 'Bed Space',
    beds: 1,
    baths: 1,
    postedLabel: '13 days ago',
    status: 'Ready to move',
    description:
        'Clean and secure hostel near the university with mess, laundry and Wi-Fi. Separate rooms for students and working professionals.',
    sellerName: 'Hassan Ali',
    sellerType: 'Property Owner',
    sellerRating: 3.8,
    sellerJoined: 'Aug 2026',
    phoneMasked: '+92 345 XXX XXXX',
    phoneFull: '+92 345 6667788',
    icon: Icons.bed_rounded,
    photoCount: 4,
    amenities: ['Furnished', 'Electricity Backup', 'Water Supply'],
  ),
  Property(
    id: 'p6',
    title: 'Shop in Busy Market',
    priceLabel: 'PKR 60,000 / mo',
    priceValue: 60000,
    isRent: true,
    type: 'Shop',
    area: 'Satiana Road',
    city: 'Faisalabad',
    sizeLabel: '450 Sq. Ft.',
    beds: 0,
    baths: 1,
    postedLabel: '6 days ago',
    status: 'Ready to move',
    description:
        'Corner shop on the main road with heavy footfall all day. Suitable for garments, mobile shop or food outlet.',
    sellerName: 'Marwa',
    sellerType: 'Property Owner',
    sellerRating: 3.0,
    sellerJoined: 'Oct 2026',
    phoneMasked: '+92 300 XXX XXXX',
    phoneFull: '+92 300 1112233',
    icon: Icons.storefront_rounded,
    photoCount: 2,
    amenities: ['Corner property', 'Main Boulevard', 'Electricity'],
  ),
  Property(
    id: 'p7',
    title: '3 Bed Sea-Facing Apartment',
    priceLabel: 'PKR 2.75 Crore',
    priceValue: 27500000,
    isRent: false,
    type: 'Flat / Apartment',
    area: 'Gulshan-e-Iqbal',
    city: 'Karachi',
    sizeLabel: '1,750 Sq. Ft.',
    beds: 3,
    baths: 3,
    postedLabel: '4 days ago',
    status: 'Ready to move',
    description:
        'Bright apartment with drawing, dining and a big terrace. Building has 24/7 security, lift and covered parking.',
    sellerName: 'Fatima Noor',
    sellerType: 'Agent',
    sellerRating: 4.7,
    sellerJoined: 'Feb 2026',
    phoneMasked: '+92 312 XXX XXXX',
    phoneFull: '+92 312 9990011',
    icon: Icons.location_city_rounded,
    photoCount: 7,
    amenities: [
      'Elevator/Lift',
      'Security Staff/CCTV',
      'Parking',
      'Electricity Backup',
    ],
  ),
  Property(
    id: 'p8',
    title: '1 Kanal Modern House',
    priceLabel: 'PKR 9.50 Crore',
    priceValue: 95000000,
    isRent: false,
    type: 'House',
    area: 'F-7/1',
    city: 'Islamabad',
    sizeLabel: '1 Kanal',
    beds: 5,
    baths: 6,
    postedLabel: '1 week ago',
    views: 142,
    status: 'Ready to move',
    description:
        'Architect-designed house near Margalla Hills with home theatre, basement and smart lighting throughout. A rare find in F-7.',
    sellerName: 'Ahmed Raza',
    sellerType: 'Agent',
    sellerRating: 4.5,
    sellerJoined: 'Mar 2026',
    phoneMasked: '+92 321 XXX XXXX',
    phoneFull: '+92 321 4445566',
    icon: Icons.castle_rounded,
    photoCount: 12,
    amenities: [
      'Central Air Conditioning',
      'Lawn/Garden',
      'Parking',
      'Fire Exit',
    ],
  ),
];

class PopularArea {
  const PopularArea({
    required this.city,
    required this.count,
    required this.areas,
  });
  final String city;
  final String count;
  final String areas;
}

const List<PopularArea> dummyAreas = [
  PopularArea(
    city: 'Faisalabad',
    count: '4 properties',
    areas: 'Faisalabad East · East Canal Road · Canal Road · Satiana Road',
  ),
  PopularArea(
    city: 'Karachi',
    count: '1 property',
    areas: 'Clifton · DHA · Gulshan-e-Iqbal · PECHS',
  ),
  PopularArea(
    city: 'Islamabad',
    count: '1 property',
    areas: 'Islamabad F Sectors · F-6/1 · Sector F-6 · F-7/1',
  ),
  PopularArea(
    city: 'Lahore',
    count: '0 properties listed',
    areas: 'DHA · Gulberg · Bahria Town · Johar Town',
  ),
];

class RoommateProfile {
  const RoommateProfile({
    required this.name,
    required this.title,
    required this.city,
    required this.area,
    required this.budgetLabel,
    required this.budgetValue,
    required this.nonSmoker,
    required this.roomType,
    required this.gender,
    required this.purpose,
    required this.postedLabel,
    required this.initial,
    this.views = 0,
  });
  final String name;
  final String title;
  final String city;
  final String area;
  final String budgetLabel;
  final int budgetValue;
  final bool nonSmoker;
  final String roomType;
  final String gender;
  final String purpose; // Need Room / Have Room
  final String postedLabel;
  final String initial;
  final int views;
}

const List<RoommateProfile> dummyRoommates = [
  RoommateProfile(
    name: 'Ali Hamza',
    title: 'Student looking for a shared room near FAST',
    city: 'Lahore',
    area: 'Johar Town',
    budgetLabel: 'PKR 18,000 / mo',
    budgetValue: 18000,
    nonSmoker: true,
    roomType: 'Shared Room (2 persons)',
    gender: 'Male',
    purpose: 'Need Room',
    postedLabel: '2 days ago',
    views: 231,
    initial: 'A',
  ),
  RoommateProfile(
    name: 'Zainab S.',
    title: 'One private room available in a girls hostel',
    city: 'Islamabad',
    area: 'G-13',
    budgetLabel: 'PKR 28,000 / mo',
    budgetValue: 28000,
    nonSmoker: true,
    roomType: 'Private Room',
    gender: 'Female',
    purpose: 'Have Room',
    postedLabel: '5 hours ago',
    views: 87,
    initial: 'Z',
  ),
  RoommateProfile(
    name: 'Danish K.',
    title: 'Working professional, bed space in DHA flat',
    city: 'Karachi',
    area: 'DHA Phase 5',
    budgetLabel: 'PKR 15,000 / mo',
    budgetValue: 15000,
    nonSmoker: false,
    roomType: 'Bed Space',
    gender: 'Male',
    purpose: 'Have Room',
    postedLabel: '1 week ago',
    views: 142,
    initial: 'D',
  ),
];

class Conversation {
  const Conversation({
    required this.id,
    required this.sellerName,
    required this.propertyTitle,
    required this.lastMessage,
    required this.timeLabel,
    required this.unread,
  });
  final String id;
  final String sellerName;
  final String propertyTitle;
  final String lastMessage;
  final String timeLabel;
  final int unread;
}

const List<Conversation> dummyConversations = [
  Conversation(
    id: 'c1',
    sellerName: 'Marwa',
    propertyTitle: '5 Marla Brand New House',
    lastMessage: 'Yes, the house is available. When do you want to visit?',
    timeLabel: '10:24 AM',
    unread: 2,
  ),
  Conversation(
    id: 'c2',
    sellerName: 'Ahmed Raza',
    propertyTitle: '2 Bed Luxury Apartment',
    lastMessage: 'Rent is final, but I can waive the first month maintenance.',
    timeLabel: 'Yesterday',
    unread: 0,
  ),
  Conversation(
    id: 'c3',
    sellerName: 'Fatima Noor',
    propertyTitle: '3 Bed Sea-Facing Apartment',
    lastMessage: 'I have shared the location pin with you.',
    timeLabel: 'Mon',
    unread: 0,
  ),
];

const List<String> dummyCities = [
  'Lahore',
  'Karachi',
  'Islamabad',
  'Rawalpindi',
  'Faisalabad',
  'Multan',
  'Peshawar',
  'Quetta',
  'Sialkot',
  'Gujranwala',
  'Hyderabad',
  'Bahawalpur',
  'Sargodha',
  'Sukkur',
  'Larkana',
  'Sheikhupura',
  'Rahim Yar Khan',
  'Jhang',
  'Dera Ghazi Khan',
  'Gujrat',
  'Sahiwal',
  'Wah Cantt',
  'Kasur',
  'Okara',
  'Mingora',
  'Chiniot',
  'Kamoke',
  'Hafizabad',
  'Sadiqabad',
  'Mirpur Khas',
  'Khanewal',
  'Kohat',
  'Abbottabad',
  'Muzaffargarh',
  'Mandi Bahauddin',
  'Dera Ismail Khan',
  'Jacobabad',
  'Murree',
  'Mirpur (AJK)',
  'Muzaffarabad',
  'Skardu',
  'Gilgit',
  'Gwadar',
  'Attock',
  'Jhelum',
];

const List<String> dummyPropertyTypes = [
  'House',
  'Flat / Apartment',
  'Upper Partition',
  'Lower Partition',
  'Farm House',
  'Room / Hostel',
  'Bed Space',
  'Penthouse',
  'Office',
  'Shop',
  'Warehouse',
  'Factory',
  'Building / Plaza',
  'Commercial Floor',
  'Residential Plot',
  'Commercial Plot',
  'Agricultural Land',
  'Industrial Land',
  'Plot File',
  'Plot Form',
];

const List<String> dummyAmenities = [
  'Parking',
  'Gas available',
  'Servant quarter',
  'Corner property',
  'Security Staff/CCTV',
  'Elevator/Lift',
  'Furnished',
  'Lawn/Garden',
  'Park facing',
  'Main Boulevard',
  'Possession Available',
  'Sewerage',
  'Electricity',
  'Water Supply',
  'Boundary Wall',
  'Electricity Backup',
  'Central Air Conditioning',
  'Fire Exit',
];

const List<String> dummySizeUnits = [
  'Marla (Normal)',
  'Marla (Lahori)',
  'Kanal',
  'Sq. Ft.',
  'Sq. Yd.',
  'Sq. M.',
];
