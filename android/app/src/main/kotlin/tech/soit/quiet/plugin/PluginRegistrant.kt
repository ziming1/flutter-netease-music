package tech.soit.quiet.plugin

import io.flutter.plugin.common.PluginRegistry

object PluginRegistrant {

    fun registerWith(registry: PluginRegistry) {
        if (alreadyRegisteredWith(registry)) {
            return
        }
        MediaPlayerPlugin.registerWith(registry.registrarFor(MediaPlayerPlugin::class.java.canonicalName))
    }

    private fun alreadyRegisteredWith(registry: PluginRegistry): Boolean {
        val key = PluginRegistrant::class.java.canonicalName
        if (registry.hasPlugin(key)) {
            return true
        }
        registry.registrarFor(key)
        return false
    }

}