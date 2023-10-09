package com.cuhk.fedcampus


import AlarmApi
import DataApi
import HuaweiAuthApi
import LoadDataApi
import TrainFedmcrnn
import AppUsageStats
import android.content.Intent
import com.cuhk.fedcampus.pigeon.AlarmApiClass
import com.cuhk.fedcampus.pigeon.DataApiClass
import com.cuhk.fedcampus.pigeon.HuaweiAuthApiClass
import com.cuhk.fedcampus.pigeon.LoadDataApiClass
import com.cuhk.fedcampus.pigeon.AppUsageStatsClass
import com.cuhk.fedcampus.train.FedmcrnnClient
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    lateinit var callback: (Result<Boolean>) -> Unit

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // setup the pigeon file
        val messenger = flutterEngine.dartExecutor.binaryMessenger
        DataApi.setUp(messenger, DataApiClass(this.activity))
        HuaweiAuthApi.setUp(messenger, HuaweiAuthApiClass(this))
        LoadDataApi.setUp(messenger, LoadDataApiClass(this))
        AlarmApi.setUp(messenger, AlarmApiClass(this))
        TrainFedmcrnn.setUp(messenger, FedmcrnnClient(this, messenger))
        AppUsageStats.setUp(messenger, AppUsageStatsClass(this))
    }

    fun startActivityForFlutterResult(
        intent: Intent, requestCode: Int, callback: (Result<Boolean>) -> Unit
    ) {
        this.callback = callback
        startActivityForResult(intent, requestCode)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == 1000) {
            if (resultCode == 200) {
                this.callback(Result.success(true))
            } else {
                this.callback(Result.success(false))
            }
        } else if (requestCode == 1001) {
            if (resultCode == 200) {
                this.callback(Result.success(true))
            }
        }
    }
}
