// // GENERATED CODE - DO NOT MODIFY BY HAND

// part of 'user_model.dart';

// // **************************************************************************
// // TypeAdapterGenerator
// // **************************************************************************

// class UserAdapter extends TypeAdapter<User> {
//   @override
//   final int typeId = 0;

//   @override
//   User read(BinaryReader reader) {
//     final numOfFields = reader.readByte();
//     final fields = <int, dynamic>{
//       for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
//     };
//     return User(
//       name: fields[0] as String,
//       imagePath: fields[1] as String,
//       embedding: (fields[2] as List).cast<double>(),
//     );
//   }

//   @override
//   void write(BinaryWriter writer, User obj) {
//     writer
//       ..writeByte(3)
//       ..writeByte(0)
//       ..write(obj.name)
//       ..writeByte(1)
//       ..write(obj.imagePath)
//       ..writeByte(2)
//       ..write(obj.embedding);
//   }

//   @override
//   int get hashCode => typeId.hashCode;

//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) ||
//       other is UserAdapter &&
//           runtimeType == other.runtimeType &&
//           typeId == other.typeId;
// }
