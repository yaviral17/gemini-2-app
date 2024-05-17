import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gemini/apikey.dart';
import 'package:gemini/msg_widget.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _thinking = false;
  List<MessageBubble> messages = [];

  TextEditingController messageController = TextEditingController();

  final model =
      GenerativeModel(model: 'gemini-1.5-flash-latest', apiKey: APIKey.apiKey);

  saveChats() async {
    SharedPreferences prefs =
        await SharedPreferences.getInstance() as SharedPreferences;
    List<String> chat = messages
        .map((e) => jsonEncode({
              'isMe': e.isMe,
              'message': e.message,
            }))
        .toList();

    prefs.setStringList('chat-3', chat);
  }

  fetchChats() async {
    SharedPreferences prefs =
        await SharedPreferences.getInstance() as SharedPreferences;

    List<String>? chat = prefs.getStringList('chat-3');
    if (chat == null) {
      return;
    }
    messages = chat
        .map((e) => jsonDecode(e))
        .map((e) => MessageBubble(
              isMe: e['isMe'],
              message: e['message'],
            ))
        .toList();

    setState(() {});
  }

  sendMessage() async {
    if (_thinking) {
      return;
    }
    String promtMsg = messageController.text;
    setState(() {
      messages.add(MessageBubble(isMe: true, message: messageController.text));
      messages.add(const MessageBubble(
        isMe: false,
        loading: true,
      ));
      messageController.clear();
    });
    final content = [
      messages.length < 4
          ? Content.text(promtMsg)
          : Content.text(
              "Your response :\n${messages[messages.length - 3].message ?? ""}\n\nTo My question ${messages[messages.length - 4].message ?? ""} now this my another response to this context:\n ${promtMsg}")
    ];
    if (messages.length > 4) {
      log("Your response :\n${messages[messages.length - 3].message ?? ""}\n\nTo My question ${messages[messages.length - 4].message ?? ""} now this my another response to this context:\n ${promtMsg}");
    }
    log('Sending message: ${promtMsg}');
    _thinking = false;
    // setState(() {});
    // return;
    GenerateContentResponse response = await model.generateContent(content);

    log(response.text!);
    setState(() {
      messages.last = MessageBubble(isMe: false, message: response.text!);
      saveChats();
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchChats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      bottomNavigationBar: Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.78,
                height: 80,
                child: TextField(
                  controller: messageController,
                  // enable next line
                  maxLines: 5,

                  decoration: const InputDecoration(
                    hintText: 'Type a message',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () async => await sendMessage(),
                icon: const Icon(Icons.send),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: ListView.builder(
          itemCount: messages.length,
          itemBuilder: (context, index) {
            return messages[index];
          },
        ),
      ),
    );
  }
}
