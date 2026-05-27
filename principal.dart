import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

void main() async {
  final String token = '8734645709:AAGw7G2Y1dyP_zjmyWErG4yEHvh0QJAMg_M';

  print('🚀 Bot iniciado...');

  int offset = 0;

  while (true) {
    try {
      final url = Uri.parse(
          'https://api.telegram.org/bot$8734645709:AAGw7G2Y1dyP_zjmyWErG4yEHvh0QJAMg_M/getUpdates?offset=$offset');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        for (var update in data['result']) {
          offset = update['update_id'] + 1;

          if (update['message'] != null) {
            final message = update['message'];
            final chatId = message['chat']['id'];
            final texto = message['text'] ?? '';

          if (texto == '/start') {
            await sendMessage(
              token,
              chatId,
              '👋 Seja Bem vindo(a) ao verificador de CPF!\n\nDigite seu CPF abaixo.\nEx: 000 000 000 00'
            );
          }

            print('📩 Mensagem recebida: $texto');

            if (texto.isNotEmpty && !texto.startsWith('/')) {
              if (validarCPF(texto)) {
                await sendMessage(token, chatId,
                    '✅ O CPF $texto é VÁLIDO! Até logo');
              } else {
                await sendMessage(
                    token, chatId, '❌ O CPF $texto é INVÁLIDO. Tente Novamente!');
              }
            }
          }
        }
      } else {
        print('Erro HTTP: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro: $e');
    }

    await Future.delayed(Duration(seconds: 2));
  }
}

Future<void> sendMessage(String token, int chatId, String text) async {
  final url =
      Uri.parse('https://api.telegram.org/bot$token/sendMessage');

  await http.post(
    url,
    body: {
      'chat_id': chatId.toString(),
      'text': text,
    },
  );
}

bool validarCPF(String cpf) {
  cpf = cpf.replaceAll(RegExp(r'[^0-9]'), '');

  if (cpf.length != 11 ||
      RegExp(r'^(\d)\1*$').hasMatch(cpf)) return false;

  List<int> numbers =
      cpf.split('').map((e) => int.parse(e)).toList();

  for (int j = 9; j <= 10; j++) {
    int sum = 0;

    for (int i = 0; i < j; i++) {
      sum += numbers[i] * ((j + 1) - i);
    }

    int res = (sum * 10) % 11;
    if (res == 10) res = 0;

    if (res != numbers[j]) return false;
  }

  return true;
}
