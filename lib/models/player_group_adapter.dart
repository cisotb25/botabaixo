import 'package:hive/hive.dart';
import 'player_group.dart';

class PlayerGroupAdapter extends TypeAdapter<PlayerGroup> {
  @override
  final int typeId = 4;

  @override
  PlayerGroup read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return PlayerGroup(
      id: fields[0] as String,
      name: fields[1] as String,
      playerIds: (fields[2] as List).cast<String>(),
      createdAt: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, PlayerGroup obj) {
    writer.writeByte(4);
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.name);
    writer.writeByte(2);
    writer.write(obj.playerIds);
    writer.writeByte(3);
    writer.write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerGroupAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
