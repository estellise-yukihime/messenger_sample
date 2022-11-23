// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
      id: json['id'] as String?,
      message: json['message'] as String?,
      created: _$JsonConverterFromJson<Timestamp, DateTime>(
          json['created'], const FirestoreDateTimeConverter().fromJson),
    );

const _$MessageFieldMap = <String, String>{
  'message': 'message',
  'id': 'id',
  'created': 'created',
};

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
      'message': instance.message,
      'id': instance.id,
      'created': _$JsonConverterToJson<Timestamp, DateTime>(
          instance.created, const FirestoreDateTimeConverter().toJson),
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);
