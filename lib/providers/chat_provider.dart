import 'package:flutter/material.dart';
import '../models/message.dart';
import '../services/api_service.dart';

class ChatProvider with ChangeNotifier {
  List<Message> _messages = [];
  bool _isLoading = false;

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;

  void addUserMessage(String text) {
    _messages.add(Message(content: text, isUser: true));
    notifyListeners();
  }

  void addBotMessage(String text) {
    _messages.add(Message(content: text, isUser: false));
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    _isLoading = true;
    notifyListeners();

    try {
      addUserMessage(text);
      final response = await ApiService.sendMessage(text);

      print("Bot response (cleaned): $response"); // 打印清理后的响应
      addBotMessage(response);
    } catch (e) {
      addBotMessage("Error: ${e.toString()}");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
