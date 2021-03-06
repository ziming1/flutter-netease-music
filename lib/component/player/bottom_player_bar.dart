library player;

import 'package:flutter/material.dart';
import 'package:quiet/component/utils/utils.dart';
import 'package:quiet/material/playing_indicator.dart';
import 'package:quiet/pages/page_playing_list.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository/cached_image.dart';

@visibleForTesting
class DisableBottomController extends StatelessWidget {
  final Widget child;

  const DisableBottomController({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class BoxWithBottomPlayerController extends StatelessWidget {
  BoxWithBottomPlayerController(this.child);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (context.ancestorWidgetOfExactType(DisableBottomController) != null) {
      return child;
    }

    //fixme 可能会有问题
    final media = MediaQueryData.fromWindow(WidgetsBinding.instance.window);

    //hide bottom player controller when view inserts
    //bottom too height (such as typing with soft keyboard)
    bool hide = isSoftKeyboardDisplay(media);
    return Column(
      children: <Widget>[
        Expanded(child: child),
        hide ? Container() : BottomControllerBar(bottomPadding: media.viewPadding.bottom),
      ],
    );
  }
}

///底部当前音乐播放控制栏
class BottomControllerBar extends StatelessWidget {
  final double bottomPadding;

  const BottomControllerBar({Key key, this.bottomPadding = 0}) : super(key: key);

  Widget _buildSubtitle(BuildContext context, Music music) {
    final playingLyric = PlayingLyric.of(context);
    if (!playingLyric.hasLyric) {
      return Text(music.subTitle);
    }
    final line = playingLyric.lyric
        .getLineByTimeStamp(
          PlayerState.of(context).position.inMilliseconds,
          0,
        )
        ?.line;
    if (line == null || line.isEmpty) {
      return Text(music.subTitle);
    }
    return Text(line);
  }

  @override
  Widget build(BuildContext context) {
    var music = PlayerState.of(context).current;
    if (music == null) {
      return Container();
    }
    return InkWell(
      onTap: () {
        if (music != null) {
          Navigator.pushNamed(context, ROUTE_PAYING);
        }
      },
      child: Card(
        margin: const EdgeInsets.all(0),
        shape: const RoundedRectangleBorder(
            borderRadius:
                const BorderRadius.only(topLeft: const Radius.circular(4.0), topRight: const Radius.circular(4.0))),
        child: Container(
          height: 56 + bottomPadding,
          padding: EdgeInsets.only(bottom: bottomPadding),
          child: Row(
            children: <Widget>[
              Hero(
                tag: "album_cover",
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(3)),
                      child: music.description.iconUri == null
                          ? Container(color: Colors.grey)
                          : Image(
                              fit: BoxFit.cover,
                              image: CachedImage(music.description.iconUri.toString()),
                            ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: DefaultTextStyle(
                  style: TextStyle(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Spacer(),
                      Text(
                        music.title,
                        style: Theme.of(context).textTheme.body1,
                      ),
                      Padding(padding: const EdgeInsets.only(top: 2)),
                      DefaultTextStyle(
                        child: _buildSubtitle(context, music),
                        maxLines: 1,
                        style: Theme.of(context).textTheme.caption,
                      ),
                      Spacer(),
                    ],
                  ),
                ),
              ),
              _PauseButton(),
              IconButton(
                  tooltip: "当前播放列表",
                  icon: Icon(Icons.menu),
                  onPressed: () {
                    showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return PlayingListDialog();
                        });
                  }),
            ],
          ),
        ),
      ),
    );
  }
}

class _PauseButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PlayingIndicator(
      playing: IconButton(
          icon: Icon(Icons.pause),
          onPressed: () {
            quiet.pause();
          }),
      pausing: IconButton(
          icon: Icon(Icons.play_arrow),
          onPressed: () {
            quiet.play();
          }),
      buffering: Container(
        height: 24,
        width: 24,
        //to fit  IconButton min width 48
        margin: EdgeInsets.only(right: 12),
        padding: EdgeInsets.all(4),
        child: CircularProgressIndicator(),
      ),
    );
  }
}
