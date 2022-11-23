import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore_odm/cloud_firestore_odm.dart';

part 'message.g.dart';

const firestoreSerializable = JsonSerializable(
  converters: firestoreJsonConverters,
  explicitToJson: true,
  createFieldMap: true,
);

@firestoreSerializable
class Message {
  const Message({
    this.id,
    this.message,
    this.created,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return _$MessageFromJson(json);
  }

  final String? message;
  final String? id;
  final DateTime? created;

  DateTime get date {
    if (created != null) {
      return DateTime(created!.year, created!.month, created!.day);
    }

    return DateTime(1997, 1, 1);
  }

  Map<String, dynamic> toJson() {
    return _$MessageToJson(this);
  }
}
