// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_audio_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LocalAudioRecordAdapter extends TypeAdapter<LocalAudioRecord> {
  @override
  final int typeId = 0;

  @override
  LocalAudioRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocalAudioRecord(
      id: fields[0] as String,
      userAudioPath: fields[1] as String,
      aiAudioPath: fields[2] as String?,
      userAudioDurationMs: fields[3] as int,
      aiAudioDurationMs: fields[4] as int,
      createdAt: fields[5] as DateTime,
      conversationId: fields[6] as String,
      isOnboarding: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, LocalAudioRecord obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userAudioPath)
      ..writeByte(2)
      ..write(obj.aiAudioPath)
      ..writeByte(3)
      ..write(obj.userAudioDurationMs)
      ..writeByte(4)
      ..write(obj.aiAudioDurationMs)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.conversationId)
      ..writeByte(7)
      ..write(obj.isOnboarding);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalAudioRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
