// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransactionAdapter extends TypeAdapter<Transaction> {
  @override
  final int typeId = 3;

  @override
  Transaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Transaction(
      username: fields[0] as String,
      hotelKey: fields[1] as String,
      hotelName: fields[2] as String,
      checkin: fields[3] as DateTime,
      checkout: fields[4] as DateTime,
      day: fields[5] as int,
      price: fields[6] as double,
      total: fields[7] as double,
      bookingTime: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Transaction obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.username)
      ..writeByte(1)
      ..write(obj.hotelKey)
      ..writeByte(2)
      ..write(obj.hotelName)
      ..writeByte(3)
      ..write(obj.checkin)
      ..writeByte(4)
      ..write(obj.checkout)
      ..writeByte(5)
      ..write(obj.day)
      ..writeByte(6)
      ..write(obj.price)
      ..writeByte(7)
      ..write(obj.total)
      ..writeByte(8)
      ..write(obj.bookingTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
