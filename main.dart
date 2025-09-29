import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChatPage(),
    );
  }
}

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> messages = [];

  Future<void> sendMessage() async {
    String userMsg = _controller.text;
    if (userMsg.isEmpty) return;

    setState(() {
      messages.add({"sender": "me", "text": userMsg});
      _controller.clear();
    });

    final response = await http.post(
      Uri.parse("http://10.0.2.2:3000/chat"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"message": userMsg}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      String reply = data["reply"];
      setState(() {
        messages.add({"sender": "ai", "text": reply});
      });
    } else {
      setState(() {
        messages.add({"sender": "ai", "text": "حصل خطأ في السيرفر"});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("AI Chat")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return Container(
                  alignment: msg["sender"] == "me"
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  padding: EdgeInsets.all(8),
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: msg["sender"] == "me"
                          ? Colors.blue[200]
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(msg["text"] ?? ""),
                  ),
                );
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: "اكتب رسالتك...",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: sendMessage,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
