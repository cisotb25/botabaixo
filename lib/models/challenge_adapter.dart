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

    // Handle both old format (category/difficulty/shots) and new format (type/sips/giveSips)
    final id = fields[0].toString();
    final type = fields[1].toString(); // old: category, new: type
    final textPT = fields[2].toString();
    final textEN = fields[3].toString();
    final sips = fields[4] is int ? fields[4] as int : int.tryParse(fields[4].toString()) ?? 0;
    final giveSips = fields[5] is bool ? fields[5] as bool : false;
    final giveSipsAmount = fields[6] is int ? fields[6] as int : 0;

    // Map old category names to new type names
    String mappedType = type;
    switch (type) {
      case 'bebida':
        mappedType = 'normal';
        break;
      case 'desafio':
        mappedType = 'normal';
        break;
      case 'verdade':
        mappedType = 'normal';
        break;
      case 'seria_ou_beberia':
        mappedType = 'normal';
        break;
      case 'penalidade_max':
        mappedType = 'bottoms_up';
        break;
      case 'regra':
        mappedType = 'normal';
        break;
      case 'grupo':
        mappedType = 'game';
        break;
      case 'coragem':
        mappedType = 'normal';
        break;
    }

    return Challenge(
      id: id,
      type: mappedType,
      textPT: textPT,
      textEN: textEN,
      sips: sips,
      giveSips: giveSips,
      giveSipsAmount: giveSipsAmount,
    );
  }

  @override
  void write(BinaryWriter writer, Challenge obj) {
    writer.writeByte(7); // number of fields
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.type);
    writer.writeByte(2);
    writer.write(obj.textPT);
    writer.writeByte(3);
    writer.write(obj.textEN);
    writer.writeByte(4);
    writer.write(obj.sips);
    writer.writeByte(5);
    writer.write(obj.giveSips);
    writer.writeByte(6);
    writer.write(obj.giveSipsAmount);
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
