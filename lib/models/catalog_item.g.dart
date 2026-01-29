// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CatalogItemAdapter extends TypeAdapter<CatalogItem> {
  @override
  final int typeId = 0;

  @override
  CatalogItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CatalogItem(
      id: fields[0] as String,
      title: fields[1] as String,
      category: fields[2] as String,
      description: fields[3] as String,
      imagePath: fields[4] as String?,
      isFavorite: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, CatalogItem obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.imagePath)
      ..writeByte(5)
      ..write(obj.isFavorite);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CatalogItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
