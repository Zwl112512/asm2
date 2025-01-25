import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:googleapis/dialogflow/v2.dart';
import 'package:googleapis_auth/auth_io.dart';

class DialogflowService {
  final String _projectId = '<YOUR_PROJECT_ID>'; // 替换为你的 Google Cloud 项目 ID
  final String _languageCode = 'en'; // 设置语言代码，例如 'en' 或 'zh-CN'

  Future<String> sendMessage(String message) async {
    try {
      // 加载服务账号 JSON 文件
      final serviceAccountJson = await rootBundle.loadString('assets/dialogflow_key.json');
      final credentials = ServiceAccountCredentials.fromJson(jsonDecode(serviceAccountJson));

      // 配置权限范围
      final scopes = [DialogflowApi.cloudPlatformScope];
      final client = await clientViaServiceAccount(credentials, scopes);

      // 初始化 Dialogflow API
      final dialogflow = DialogflowApi(client);

      // 设置会话 ID
      final sessionId = 'flutter-session';
      final sessionPath = 'projects/$_projectId/agent/sessions/$sessionId';

      // 构建请求
      final request = GoogleCloudDialogflowV2DetectIntentRequest(
        queryInput: GoogleCloudDialogflowV2QueryInput(
          text: GoogleCloudDialogflowV2TextInput(
            text: message,
            languageCode: _languageCode,
          ),
        ),
      );

      // 调用 API
      final response = await dialogflow.projects.agent.sessions.detectIntent(request, sessionPath);
      return response.queryResult?.fulfillmentText ?? 'No response from Dialogflow';
    } catch (e) {
      print('Dialogflow error: $e');
      return 'Error connecting to Dialogflow';
    }
  }
}
