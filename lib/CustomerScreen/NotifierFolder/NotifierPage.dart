// lib/providers/packer_mover_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:delivery_mvp_app/data/Model/CreatePickersAndMoverBooking.dart';

final deliveryTypeProvider = StateProvider<String>((ref) => "within_city"); // "within_city" ya "between_city"

final pickupLocationProvider = StateProvider<Dropoff?>((ref) => null);
final dropoffLocationProvider = StateProvider<Dropoff?>((ref) => null);

final selectedProductsProvider = StateProvider<List<Product>>((ref) => []);

final selectedDateProvider = StateProvider<DateTime?>((ref) => null);
final selectedTimeProvider = StateProvider<String?>((ref) => null);

final selectedAddOnsProvider = StateProvider<AddOns?>((ref) => null);

final serviceLiftPickupProvider   = StateProvider<bool>((ref) => false);
final serviceLiftDropProvider     = StateProvider<bool>((ref) => false);

final floorPickupProvider = StateProvider<int>((ref) => 0);
final floorDropProvider   = StateProvider<int>((ref) => 0);

final totalAmountProvider = StateProvider<int>((ref) => 0); // price calculation ke baad update hoga