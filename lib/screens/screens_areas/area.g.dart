// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'area.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AreaAdapter extends TypeAdapter<Area> {
  @override
  final int typeId = 0;

  @override
  Area read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Area(
      empleado: fields[0] as String,
      area: fields[1] as String,
      cultivo: fields[2] as String,
      actividad: fields[3] as String,
      estado: fields[4] as String,
      progreso: fields[5] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Area obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.empleado)
      ..writeByte(1)
      ..write(obj.area)
      ..writeByte(2)
      ..write(obj.cultivo)
      ..writeByte(3)
      ..write(obj.actividad)
      ..writeByte(4)
      ..write(obj.estado)
      ..writeByte(5)
      ..write(obj.progreso);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AreaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
