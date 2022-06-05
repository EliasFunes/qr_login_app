import 'dart:async';

import 'package:stomp_dart_client/stomp.dart' show StompClient;
import 'package:stomp_dart_client/stomp_config.dart' show StompConfig;
import 'package:stomp_dart_client/stomp_frame.dart' show StompFrame;

StompClient stompClientF(String ipPort, String token, String qrId) {
  return StompClient(
      config: StompConfig.SockJS(
          url: 'http://$ipPort/wsc',
          onConnect: (StompClient client, StompFrame frame) =>
              onConnectCallback(client, frame, token, qrId),
          onWebSocketError: (dynamic error) =>
              print('WEBSOCKET ERROR =>  ${error.toString()}'),
          onStompError: onStompError,
          onDebugMessage: onMessageDebug,
          stompConnectHeaders: {
        'X-Authorization': 'Bearer $token',
        'username': 'username'
      },
          webSocketConnectHeaders: {
        'X-Authorization': 'Bearer $token',
        'username': 'username'
      }));
}

dynamic onConnectCallback(
    StompClient client, StompFrame connectFrame, String token, String qrId) {
  print('se conectooooo!! => token=> $token;; qrId $qrId');
  print('conected => ${connectFrame.toString()}');
  client.send(
    destination: '/app/hello_user',
    body: qrId,
  );
  Timer(const Duration(milliseconds: 1000), () => client.deactivate());
}

void onStompError(StompFrame errorFrame) {
  print('onStompError => ${errorFrame.headers}');
}

void onMessageDebug(String frame) {
  print('onStompError => ${frame}');
}
