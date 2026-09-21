package com.ehgsmartwellness.app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private var bandPlugin: EHGBandAndroidPlugin? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        bandPlugin = EHGBandAndroidPlugin(this, flutterEngine.dartExecutor.binaryMessenger)
    }
}
