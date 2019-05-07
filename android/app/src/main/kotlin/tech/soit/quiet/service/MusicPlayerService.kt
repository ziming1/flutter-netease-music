package tech.soit.quiet.service

import android.app.PendingIntent
import android.net.Uri
import android.os.Bundle
import android.support.v4.media.MediaBrowserCompat.MediaItem
import android.support.v4.media.MediaDescriptionCompat
import android.support.v4.media.MediaMetadataCompat
import android.support.v4.media.session.MediaControllerCompat
import android.support.v4.media.session.MediaSessionCompat
import androidx.media.MediaBrowserServiceCompat
import com.google.android.exoplayer2.C
import com.google.android.exoplayer2.ExoPlayer
import com.google.android.exoplayer2.ExoPlayerFactory
import com.google.android.exoplayer2.Player
import com.google.android.exoplayer2.audio.AudioAttributes
import com.google.android.exoplayer2.ext.mediasession.MediaSessionConnector
import com.google.android.exoplayer2.ext.mediasession.TimelineQueueNavigator
import tech.soit.quiet.player.PlayerPersistence
import tech.soit.quiet.utils.log
import tech.soit.quiet.utils.toMediaItem
import java.io.File


/**
 * music player service of Application
 */
class MusicPlayerService : MediaBrowserServiceCompat() {

    companion object {

        private val audioAttribute = AudioAttributes.Builder()
                .setContentType(C.CONTENT_TYPE_MUSIC)
                .setUsage(C.USAGE_MEDIA)
                .build()

        private const val ROOT = "/"

    }

    private val mediaSession by lazy {
        val sessionIntent = packageManager?.getLaunchIntentForPackage(packageName)
        val sessionPendingIntent = PendingIntent.getActivity(this, 0, sessionIntent, 0)
        return@lazy MediaSessionCompat(this, "MusicService").apply {
            setSessionActivity(sessionPendingIntent)
            isActive = true
        }
    }

    private val playerPersistence by lazy { PlayerPersistence() }

    // Wrap a SimpleExoPlayer with a decorator to handle audio focus for us.
    private val exoPlayer: ExoPlayer by lazy {
        ExoPlayerFactory.newSimpleInstance(this).apply {
            setAudioAttributes(audioAttribute, true)
        }
    }

    //the current playing media list
    private val playList = ArrayList<MediaItem>()

    override fun onCreate() {
        super.onCreate()

        sessionToken = mediaSession.sessionToken

        MediaControllerCompat(this, mediaSession).also {
            it.registerCallback(MediaControllerCallback())
        }

        MediaSessionConnector(mediaSession).also {
            //TODO add custom playback preparer
            it.setPlayer(exoPlayer, null)
            it.setQueueNavigator(object : TimelineQueueNavigator(mediaSession) {
                override fun getMediaDescription(player: Player, windowIndex: Int): MediaDescriptionCompat {
                    return MediaDescriptionCompat.Builder()
                            .setTitle("title")
                            .setSubtitle("subtitle")
                            .setMediaId("124245")
                            .setMediaUri(Uri.fromFile(File("sdcard/summer.mp3")))
                            .build()
                }
            })
        }

    }

    override fun onCustomAction(action: String, extras: Bundle?, result: Result<Bundle>) {
        when (action) {
            "setPlaylist" -> setPlaylist(extras, result)
        }
    }

    private fun setPlaylist(extras: Bundle?, result: Result<Bundle>) {
        extras ?: return
        playList.clear()

        val medias = extras.getParcelableArrayList<MediaDescriptionCompat>("playlist")
        log { medias }
        if (medias != null) {
            playList.addAll(medias.map { it.toMediaItem() })
        }

        notifyChildrenChanged(ROOT)
        result.sendResult(null)
    }


    override fun onLoadChildren(parentId: String, result: Result<MutableList<MediaItem>>) {
        if (parentId != ROOT) return

        //We only have a playlist which user has played from UI
        //load playing playlist we save
        result.sendResult(playList)
    }

    override fun onGetRoot(clientPackageName: String, clientUid: Int, rootHints: Bundle?): BrowserRoot? {
        //TODO validate call of client
        return BrowserRoot(ROOT, null)
    }

    private inner class MediaControllerCallback : MediaControllerCompat.Callback() {
        override fun onMetadataChanged(metadata: MediaMetadataCompat?) {
            if (metadata == null) return
            log { "on metadata changed : ${metadata.description.title}" }
        }
    }

}