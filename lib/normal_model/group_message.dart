import 'package:messenger_sample/firestore_model/message.dart';

class GroupMessage {
  const GroupMessage({this.date, this.messages});

  final String? date;
  final List<Message>? messages;
}
