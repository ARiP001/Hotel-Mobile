import 'package:hive/hive.dart';
part 'transaction.g.dart';

@HiveType(typeId: 3)
class Transaction extends HiveObject {
  @HiveField(0)
  String username;

  @HiveField(1)
  String hotelKey;

  @HiveField(2)
  String hotelName;

  @HiveField(3)
  DateTime checkin;

  @HiveField(4)
  DateTime checkout;

  @HiveField(5)
  int day;

  @HiveField(6)
  double price;

  @HiveField(7)
  double total;

  @HiveField(8)
  DateTime bookingTime;

  Transaction({
    required this.username,
    required this.hotelKey,
    required this.hotelName,
    required this.checkin,
    required this.checkout,
    required this.day,
    required this.price,
    required this.total,
    required this.bookingTime,
  });
} 