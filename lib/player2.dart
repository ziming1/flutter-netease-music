import 'package:flutter/material.dart';

import 'model/model.dart';
import 'service/channel_media_player2.dart';

List<Music> musics = [
  Music(
      id: 1,
      title: "hello",
      url: "sdcard/summer.mp3",
      album: Album(),
      artist: [],
      mvId: 0),
  Music(
      id: 2,
      title: "hello2",
      url: "sdcard/summer.mp3",
      album: Album(),
      artist: [],
      mvId: 0),
  Music(
      id: 3,
      title: "hello3",
      url: "sdcard/summer.mp3",
      album: Album(),
      artist: [],
      mvId: 0),
  Music(
      id: 4,
      title: "hello4",
      url: "sdcard/summer.mp3",
      album: Album(),
      artist: [],
      mvId: 0),
  Music(
      id: 5,
      title: "hello5",
      url: "sdcard/summer.mp3",
      album: Album(),
      artist: [],
      mvId: 0),
];

class Play2Test extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    PlayerPlugin();
    return Column(
      children: <Widget>[
        FlatButton(
            onPressed: () {
              testChannel.invokeMethod("skipToNext");
            },
            child: Text("skipToNext")),
        FlatButton(
            onPressed: () {
              testChannel.invokeMethod("playWithQinDing", {'id': 1});
            },
            child: Text("play")),
        FlatButton(
          onPressed: () {
            testChannel.invokeMethod(
                "setPlayList", musics.map((m) => m.toMap()).toList());
          },
          child: Text("set playlist"),
        )
      ],
    );
  }
}
