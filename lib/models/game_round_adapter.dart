import 'package:hive/hive.dart';
import 'game_round.dart';
import 'player.dart';
import 'challenge.dart';

class GameRoundAdapter extends TypeAdapter<GameRound> {
  @override
  final int typeId = 2;

  @override
  GameRound read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return GameRound(
      id: fields[0] as String,
      players: (fields[1] as List).cast<Player>().toList(),
      challenges: (fields[2] as List).cast<RoundChallenge>().toList(),
      startedAt: fields[3] as DateTime,
      endedAt: fields[4] as DateTime?,
      isActive: fields[5] as bool,
      activeViruses: fields[6] != null
          ? (fields[6] as List).cast<ActiveVirus>().toList()
          : [],
    );
  }

  @override
  void write(BinaryWriter writer, GameRound obj) {
    writer.writeByte(7); // number of fields
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.players);
    writer.writeByte(2);
    writer.write(obj.challenges);
    writer.writeByte(3);
    writer.write(obj.startedAt);
    writer.writeByte(4);
    writer.write(obj.endedAt);
    writer.writeByte(5);
    writer.write(obj.isActive);
    writer.writeByte(6);
    writer.write(obj.activeViruses);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameRoundAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RoundChallengeAdapter extends TypeAdapter<RoundChallenge> {
  @override
  final int typeId = 3;

  @override
  RoundChallenge read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return RoundChallenge(
      challenge: (fields[0] is Challenge) ? fields[0] as Challenge : Challenge.fromMap(fields[0] as Map<String, dynamic>),
      assignedPlayer: (fields[1] is Player) ? fields[1] as Player : Player.fromMap(fields[1] as Map<String, dynamic>),
      isCompleted: fields[2] as bool,
      completedAt: fields[3] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, RoundChallenge obj) {
    writer.writeByte(4); // number of fields
    writer.writeByte(0);
    writer.write(obj.challenge);
    writer.writeByte(1);
    writer.write(obj.assignedPlayer);
    writer.writeByte(2);
    writer.write(obj.isCompleted);
    writer.writeByte(3);
    writer.write(obj.completedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoundChallengeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
