package tech.soit.quiet

import android.content.Intent
import android.os.Bundle
import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant
import tech.soit.quiet.plugin.MediaPlayerPlugin
import tech.soit.quiet.plugin.PluginRegistrant
import tech.soit.quiet.service.QuietPlayerChannel

class MainActivity : FlutterActivity() {

    companion object {

        const val KEY_DESTINATION = "destination"

        const val DESTINATION_PLAYING_PAGE = "action_playing_page"

    }

    private lateinit var playerChannel: QuietPlayerChannel


    private val mediaPlayerPlugin: MediaPlayerPlugin
        get() = valuePublishedByPlugin<MediaPlayerPlugin>(MediaPlayerPlugin::class.java.canonicalName)

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(this)
        PluginRegistrant.registerWith(this)
        route(intent)
        mediaPlayerPlugin.connect()
    }

    override fun onDestroy() {
        playerChannel.destroy()
        mediaPlayerPlugin.destroy()
        super.onDestroy()
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        route(intent)
    }

    private fun route(intent: Intent) {
        when (intent.getStringExtra(KEY_DESTINATION)) {
            DESTINATION_PLAYING_PAGE -> {
                flutterView.pushRoute("/playing")
            }
        }
    }

}
