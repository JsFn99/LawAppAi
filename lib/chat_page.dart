import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_markdown/flutter_markdown.dart';

class ChatPage extends StatefulWidget {
  @override
  State<ChatPage> createState() => _ChatBotState();
}

class _ChatBotState extends State<ChatPage> {
  List<Map<String, String>> messages = [
    {"message": "Hello", "type": "user"},
    {"message": "How can I help you?", "type": "assistant"},
  ];

  TextEditingController queryController = TextEditingController();
  ScrollController scrollController = ScrollController();
  String? errorMessage;
  bool isTyping = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Chat Bot",
          style: TextStyle(color: Theme.of(context).indicatorColor),
        ),
        backgroundColor: Colors.green[800],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                controller: scrollController,
                itemCount: messages.length + (isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == messages.length && isTyping) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10),
                            margin: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "Typing...",
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  bool isUser = messages[index]['type'] == "user";
                  return Column(
                    children: [
                      ListTile(
                        leading: isUser ? null : Icon(Icons.computer),
                        trailing: isUser ? Icon(Icons.person) : null,
                        title: Row(
                          children: [
                            SizedBox(width: isUser ? 100 : 0),
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.all(10),
                                margin: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isUser ? Colors.green[400] : Colors.amber[100],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: isUser
                                    ? Text(
                                  messages[index]['message']!,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                )
                                    : MarkdownBody(
                                  data: messages[index]['message']!,
                                  styleSheet: MarkdownStyleSheet(
                                    p: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                    h1: TextStyle(
                                      color: Colors.black,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    h2: TextStyle(
                                      color: Colors.black,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    h3: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    strong: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    em: TextStyle(
                                      fontStyle: FontStyle.italic,
                                    ),
                                    code: TextStyle(
                                      color: Colors.red,
                                      fontFamily: 'monospace',
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: isUser ? 0 : 100),
                          ],
                        ),
                      ),
                      Divider(
                        height: 1,
                        color: Theme.of(context).primaryColor,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          if (errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                errorMessage!,
                style: TextStyle(color: Colors.red),
              ),
            ),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: queryController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(width: 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () async {
                  String query = queryController.text;
                  if (query.isNotEmpty) {
                    setState(() {
                      messages.add({"message": query, "type": "user"});
                      errorMessage = null;
                      isTyping = true;
                    });

                    queryController.clear();

                    var llamaUri = Uri.parse('http://10.0.2.2:11434/api/generate');
                    Map<String, String> headers = {
                      "Content-Type": "application/json",
                    };
                    var payload = {
                      "model": "llama3",
                      "prompt": query,
                    };

                    try {
                      var response = await http.post(
                        llamaUri,
                        headers: headers,
                        body: json.encode(payload),
                      );

                      if (response.statusCode == 200) {
                        var responseLines = response.body.split('\n');
                        String responseContent = '';
                        for (var line in responseLines) {
                          if (line.trim().isNotEmpty) {
                            try {
                              var llmResponse = json.decode(line) as Map<String, dynamic>;
                              responseContent += llmResponse['response'];
                              if (llmResponse['done'] == true) {
                                break;
                              }
                            } catch (e) {
                              print('JSON parsing error: $e');
                            }
                          }
                        }
                        setState(() {
                          messages.add({
                            "message": responseContent,
                            "type": "assistant"
                          });
                          isTyping = false;
                          scrollController.jumpTo(
                              scrollController.position.maxScrollExtent + 500);
                        });
                      } else {
                        setState(() {
                          errorMessage =
                          "Failed to get response from API. Status code: ${response.statusCode}";
                          isTyping = false;
                        });
                      }
                    } catch (error) {
                      setState(() {
                        errorMessage = "An error occurred: $error";
                        isTyping = false;
                      });
                    }
                  }
                },
                icon: Icon(Icons.send),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
