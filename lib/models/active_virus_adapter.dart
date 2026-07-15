import 'package:hive/hive.dart';
import 'game_round.dart';
import 'player.dart';

class ActiveVirusAdapter extends TypeAdapter<ActiveVirus> {
  @override
  final int typeId = 5;

  @override
  ActiveVirus read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return ActiveVirus(
      id: fields[0] as String,
      text: fields[1] as String,
      assignedPlayer: (fields[2] is Player) ? fields[2] as Player : Player.fromMap(fields[2] as Map<String, dynamic>),
      startedAt: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ActiveVirus obj) {
    writer.writeByte(4);
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.text);
    writer.writeByte(2);
    writer.write(obj.assignedPlayer);
    writer.writeByte(3);
    writer.write(obj.startedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActiveVirusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
