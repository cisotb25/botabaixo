import 'package:hive/hive.dart';
import 'challenge.dart';

class ChallengeAdapter extends TypeAdapter<Challenge> {
  @override
  final int typeId = 1;

  @override
  Challenge read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return Challenge(
      id: fields[0] as String,
      category: fields[1] as String,
      difficulty: fields[2] as String,
      shots: fields[3] as int,
      textPT: fields[4] as String,
      textEN: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Challenge obj) {
    writer.writeByte(6); // number of fields
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.category);
    writer.writeByte(2);
    writer.write(obj.difficulty);
    writer.writeByte(3);
    writer.write(obj.shots);
    writer.writeByte(4);
    writer.write(obj.textPT);
    writer.writeByte(5);
    writer.write(obj.textEN);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChallengeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
