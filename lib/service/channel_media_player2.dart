import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

MethodChannel get testChannel => _channel;

const MethodChannel _channel = MethodChannel("tech.soit.quiet/player2");

class PlayerPlugin {
  static PlayerPlugin _plugin = PlayerPlugin._internal();

  factory PlayerPlugin() => _plugin;

  PlayerPlugin._internal() {
    _listenNative();
  }

  void _listenNative() {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case "onPlaylistLoaded":
          debugPrint("onPlaylistLoaded : ${call.arguments}");
          break;
      }
      debugPrint("call.method : $call");
    });
  }
}
