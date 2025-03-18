// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pioneerhub_info.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PioneerHubInfoAdapter extends TypeAdapter<PioneerHubInfo> {
  @override
  final int typeId = 0;

  @override
  PioneerHubInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PioneerHubInfo(
      id: fields[0] as int,
      name: fields[1] as String,
      email: fields[2] as String,
      logo: fields[3] as String,
      address: fields[4] as String,
      phone: fields[5] as String,
      website: fields[6] as String,
      description: fields[7] as String,
      createdAt: fields[8] as String,
      updatedAt: fields[9] as String,
      courses: fields[10] as int,
      internships: fields[11] as int,
      projects: fields[12] as int,
      instructors: fields[13] as int,
    );
  }

  @override
  void write(BinaryWriter writer, PioneerHubInfo obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.logo)
      ..writeByte(4)
      ..write(obj.address)
      ..writeByte(5)
      ..write(obj.phone)
      ..writeByte(6)
      ..write(obj.website)
      ..writeByte(7)
      ..write(obj.description)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.updatedAt)
      ..writeByte(10)
      ..write(obj.courses)
      ..writeByte(11)
      ..write(obj.internships)
      ..writeByte(12)
      ..write(obj.projects)
      ..writeByte(13)
      ..write(obj.instructors);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PioneerHubInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
