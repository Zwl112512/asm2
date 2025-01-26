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
        backgroundColor: const Color.fromRGBO(0, 166, 126, 1),
        title: const Text(
          'GPT Chat',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: DashChat(
        currentUser: _currentUser,
        messageOptions: const MessageOptions(
          currentUserContainerColor: Colors.black,
          containerColor: Color.fromRGBO(0, 166, 126, 1),
          textColor: Colors.white,
        ),
        onSend: (ChatMessage m) {
          getChatResponse(m);
        },
        messages: _messages,
      ),
    );
  }

  Future<void> getChatResponse(ChatMessage m) async {
    // 插入用户消息
    setState(() {
      _messages.insert(0, m);
    });

    // 构造消息历史记录
    List<Map<String, dynamic>> _messagesHistory = _messages.reversed.map((msg) {
      if (msg.user == _currentUser) {
        return {"role": "user", "content": msg.text};
      } else {
        return {"role": "assistant", "content": msg.text};
      }
    }).toList();

    // 构建请求
    final request = ChatCompleteText(
      model: Gpt4oMini2024ChatModel(),
      messages: _messagesHistory,
      maxToken: 200,
    );

    // 调用 OpenAI API 并获取响应
    try {
      final response = await _openAI.onChatCompletion(request: request);
      final botMessage = response?.choices[0].message?.content ?? "No response";

      // 插入 GPT 回复
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
      // 处理错误
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
