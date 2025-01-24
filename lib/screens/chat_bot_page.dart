import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import '../services/dialogflow_service.dart'; // 导入 DialogflowService

class ChatBotPage extends StatefulWidget {
  const ChatBotPage({Key? key}) : super(key: key);

  @override
  State<ChatBotPage> createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  final DialogflowService _dialogflowService = DialogflowService(); // 实例化服务
  final ChatUser _currentUser = ChatUser(id: '1', firstName: 'User');
  final ChatUser _botUser = ChatUser(id: '2', firstName: 'Bot');
  List<ChatMessage> _messages = [];

  void _sendMessage(ChatMessage message) async {
    setState(() {
      _messages.insert(0, message);
    });

    final response = await _dialogflowService.sendMessage(message.text); // 调用 Dialogflow

    setState(() {
      _messages.insert(
        0,
        ChatMessage(
          user: _botUser,
          text: response,
          createdAt: DateTime.now(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat with Dialogflow')),
      body: DashChat(
        currentUser: _currentUser,
        messages: _messages,
        onSend: _sendMessage, // 调用发送消息方法
      ),
    );
  }
}
