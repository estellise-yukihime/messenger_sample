import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:messenger_sample/firestore_model/message.dart';
import 'package:messenger_sample/id.dart';

// TODO:
// - Separate into smaller widgets

class Messenger extends StatefulWidget {
  const Messenger({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MessengerState();
  }
}

class _MessengerState extends State<Messenger> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final Stream<QuerySnapshot> _snapshot = FirebaseFirestore.instance.collection('messages').orderBy('created').snapshots();
  final Map<DateTime, List<Message>> _messages = {};
  final GlobalKey _visibilityKey = GlobalKey();
  final FocusNode _focusNode = FocusNode();

  bool _visibilityVisible = true;
  double _visibilitySizePermanent = 0;
  double _visibilitySize = 0;

  void sendMessage() async {
    if (_messageController.text != '') {
      var newMessage = Message(id: localId, message: _messageController.text, created: DateTime.now());

      _messageController.clear();
      _focusNode.unfocus();

      setState(() {
        _visibilitySize = _visibilitySizePermanent;
      });

      Future.delayed(const Duration(milliseconds: 200), () {
        setState(() {
          _visibilityVisible = true;
        });
      });

      await FirebaseFirestore.instance.collection('messages').add(newMessage.toJson());
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _visibilitySizePermanent = (_visibilityKey.currentContext?.findRenderObject() as RenderBox).size.width;
      _visibilitySize = _visibilitySizePermanent;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox.expand(
          child: Column(
            children: <Widget>[
              Expanded(
                flex: 1,
                // Can be made into ListView for optimization.
                child: SingleChildScrollView(
                  reverse: true,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Column(
                      children: <Widget>[
                        StreamBuilder<QuerySnapshot>(
                          stream: _snapshot,
                          builder: (context, snapshot) {
                            if (snapshot.data?.docChanges != null) {
                              var messages = <Message>[];

                              for (final data in snapshot.data!.docs) {
                                messages.add(Message.fromJson(data.data() as Map<String, dynamic>));
                              }

                              messages.fold(_messages, (previousValue, element) {
                                var header = element.date;

                                if (_messages.containsKey(header)) {
                                  if (!_messages[header]!.any((e) => e.message == element.message)) {
                                    _messages[header]!.add(element);
                                  }
                                } else {
                                  _messages[header] = <Message>[element];
                                }

                                return _messages;
                              });
                            }

                            return Column(
                              children: <Widget>[
                                for (final dataKeys in _messages.keys) ...[
                                  Text(
                                    DateFormat.yMMMd('en_US').format(_messages[dataKeys]!.first.date),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  for (final data in _messages[dataKeys]!)
                                    Align(
                                      alignment: data.id == localId ? Alignment.centerRight : Alignment.centerLeft,
                                      child: Card(
                                        color: data.id == localId ? Colors.blue[200] : Colors.white70,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(data.id == localId ? 15 : 0),
                                            topRight: Radius.circular(data.id == localId ? 0 : 15),
                                            bottomLeft: Radius.circular(data.id == localId ? 10 : 20),
                                            bottomRight: Radius.circular(data.id == localId ? 20 : 10),
                                          ),
                                        ),
                                        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 3),
                                        child: Padding(
                                          padding: const EdgeInsets.all(15),
                                          child: Text(
                                            data.message!,
                                            textAlign: data.id == localId ? TextAlign.right : TextAlign.left,
                                          ),
                                        ),
                                      ),
                                    ),
                                ]
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              IntrinsicHeight(
                child: Container(
                  color: Colors.red[200],
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 5),
                          constraints: const BoxConstraints(
                            minHeight: 40,
                            maxHeight: 400,
                          ),
                          padding: const EdgeInsets.all(15),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(35),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 2,
                              horizontal: 15,
                            ),
                            child: TextField(
                              focusNode: _focusNode,
                              controller: _messageController,
                              onTap: () {
                                setState(() {
                                  _visibilityVisible = false;
                                });

                                WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                                  setState(() {
                                    _visibilitySize = 0;
                                  });
                                });
                              },
                              minLines: 1,
                              maxLines: 6,
                              maxLength: 255,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                counterText: '',
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: ClipOval(
                            child: Material(
                              color: Colors.transparent,
                              child: Padding(
                                padding: const EdgeInsets.all(5),
                                child: IconButton(
                                  icon: const Icon(Icons.send),
                                  iconSize: 36,
                                  onPressed: sendMessage,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        key: _visibilityKey,
                        visible: _visibilityVisible,
                        replacement: AnimatedSize(
                          duration: const Duration(milliseconds: 200),
                          child: SizedBox(
                            width: _visibilitySize,
                          ),
                        ),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 15),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Row(
                              children: <Widget>[
                                ClipOval(
                                  child: Material(
                                    color: Colors.transparent,
                                    child: Padding(
                                      padding: const EdgeInsets.all(5),
                                      child: IconButton(
                                        onPressed: () {},
                                        iconSize: 36,
                                        icon: const Icon(Icons.add),
                                      ),
                                    ),
                                  ),
                                ),
                                ClipOval(
                                  child: Material(
                                    color: Colors.transparent,
                                    child: Padding(
                                      padding: const EdgeInsets.all(5),
                                      child: IconButton(
                                        onPressed: () {},
                                        iconSize: 36,
                                        icon: const Icon(Icons.apps),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              // const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
