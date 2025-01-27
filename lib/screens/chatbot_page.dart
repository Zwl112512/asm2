import 'package:asm2/consts.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';

class ChatBotPage extends StatefulWidget {
  const ChatBotPage({super.key});

  @override
  State<ChatBotPage> createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  final _openAI = OpenAI.instance.build(
    token: OPENAI_API_KEY, // 确保在 consts.dart 中正确定义
    baseOption: HttpSetup(
      receiveTimeout: const Duration(seconds: 5),
    ),
    enableLog: true,
  );

  final ChatUser _currentUser = ChatUser(id: '1', firstName: 'Jack', lastName: 'cxk');
  final ChatUser _gptChatUser = ChatUser(id: '2', firstName: 'Chat', lastName: 'GPT');
  List<ChatMessage> _messages = <ChatMessage>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: Row(
          children: [
            Icon(Icons.chat, color: Colors.teal),
            const SizedBox(width: 10),
            const Text(
              'Chat Bot',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFE0F7FA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: DashChat(
          currentUser: _currentUser,
          messageOptions: const MessageOptions(
            currentUserContainerColor: Colors.teal,
            currentUserTextColor: Colors.white,
            containerColor: Colors.white,
            textColor: Colors.black,
            borderRadius: 18, // 设置聊天气泡的圆角
          ),
          inputOptions: const InputOptions(
            inputDecoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: 'Type a message...',
              prefixIcon: Icon(Icons.message, color: Colors.teal),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(25)),
                borderSide: BorderSide(color: Colors.teal),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(25)),
                borderSide: BorderSide(color: Colors.teal, width: 2),
              ),
            ),
          ),
          onSend: (ChatMessage m) {
            getChatResponse(m);
          },
          messages: _messages,
        ),
      ),
    );
  }

  Future<void> getChatResponse(ChatMessage m) async {
    setState(() {
      _messages.insert(0, m);
    });

    List<Map<String, dynamic>> _messagesHistory = _messages.reversed.map((msg) {
      if (msg.user == _currentUser) {
        return {"role": "user", "content": msg.text};
      } else {
        return {"role": "assistant", "content": msg.text};
      }
    }).toList();

    final request = ChatCompleteText(
      model: Gpt4oMini2024ChatModel(),
      messages: _messagesHistory,
      maxToken: 200,
    );

    try {
      final response = await _openAI.onChatCompletion(request: request);
      final botMessage = response?.choices[0].message?.content ?? "No response";

      setState(() {
        _messages.insert(
          0,
          ChatMessage(
            user: _gptChatUser,
            text: botMessage,
            createdAt: DateTime.now(),
          ),
        );
      });
    } catch (e) {
      setState(() {
        _messages.insert(
          0,
          ChatMessage(
            user: _gptChatUser,
            text: "Error: ${e.toString()}",
            createdAt: DateTime.now(),
          ),
        );
      });
    }
  }
}
