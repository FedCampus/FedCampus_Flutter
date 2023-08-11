package com.cuhk.fedcampus


import DataApi
import HuaweiAuthApi
import LoadDataApi
import android.content.Intent
import android.util.Log
import com.cuhk.fedcampus.health.health.auth.HealthKitAuthActivity
import com.cuhk.fedcampus.pigeon.DataApiClass
import com.cuhk.fedcampus.pigeon.HuaweiAuthApiClass
import com.cuhk.fedcampus.pigeon.LoadDataApiClass
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.launch
import org.eu.fedcampus.fed_kit.Train
import org.eu.fedcampus.fed_kit_examples.cifar10.DATA_TYPE
import org.eu.fedcampus.fed_kit_examples.cifar10.Float3DArray
import org.eu.fedcampus.fed_kit_examples.cifar10.loadData
import org.eu.fedcampus.fed_kit_examples.cifar10.sampleSpec
import org.eu.fedcampus.fed_kit_train.FlowerClient
import org.eu.fedcampus.fed_kit_train.helpers.deviceId
import org.eu.fedcampus.fed_kit_train.helpers.loadMappedFile
import kotlin.Result
import io.flutter.plugin.common.MethodChannel.Result as ResultFlutter

class MainActivity : FlutterActivity() {
    val scope = MainScope()
    lateinit var train: Train<Float3DArray, FloatArray>
    lateinit var flowerClient: FlowerClient<Float3DArray, FloatArray>
    var events: EventSink? = null

    lateinit var callback: (Result<Boolean>) -> Unit

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // setup the pigeon file
        DataApi.setUp(flutterEngine.dartExecutor.binaryMessenger, DataApiClass(this.activity))
        HuaweiAuthApi.setUp(flutterEngine.dartExecutor.binaryMessenger, HuaweiAuthApiClass(this))
        LoadDataApi.setUp(flutterEngine.dartExecutor.binaryMessenger, LoadDataApiClass(this))


        val messager = flutterEngine.dartExecutor.binaryMessenger
        MethodChannel(messager, "fed_kit_flutter").setMethodCallHandler(::handle)
        EventChannel(messager, "fed_kit_flutter_events").setStreamHandler(object :
            EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, eventSink: EventSink?) {
                if (eventSink === null) {
                    Log.e(TAG, "onListen: eventSink is null.")
                } else {
                    events = eventSink
                    Log.d(TAG, "onListen: initialized events.")
                }
            }

            override fun onCancel(arguments: Any?) {
                events = null
            }
        })
    }

    fun handle(call: MethodCall, result: ResultFlutter) = scope.launch {


        try {
            when (call.method) {
                "getPlatformVersion" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
                "connect" -> {
                    val partitionId = call.argument<Int>("partitionId")!!
                    val host = call.argument<String>("host")!!
                    val backendUrl = call.argument<String>("backendUrl")!!
                    val startFresh = call.argument<Boolean>("startFresh")!!
                    connect(partitionId, host, backendUrl, startFresh, result)
                }

                "train" -> train(result)

                "huawei_authenticate" -> {
                    val intent = Intent(this@MainActivity, HealthKitAuthActivity::class.java)
                    startActivityForResult(intent, 1000)
                }

                else -> result.notImplemented()
            }
        } catch (err: Throwable) {
            result.error("error when decoding call method", "$err", err.stackTraceToString())
        }
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

        }
    }

    suspend fun connect(
        partitionId: Int,
        host: String,
        backendUrl: String,
        startFresh: Boolean,
        result: ResultFlutter
    ) {
        // TODO: Adapt for the actual workflow.
        train = Train(this, backendUrl, sampleSpec())
        train.enableTelemetry(deviceId(this))
        val modelFile = train.prepareModel(DATA_TYPE)
        val serverData = train.getServerInfo(startFresh)
        if (serverData.port == null) {
            return result.error(
                TAG, "Flower server port not available", "status ${serverData.status}"
            )
        }
        flowerClient =
            train.prepare(loadMappedFile(modelFile), "dns:///$host:${serverData.port}", false)
        try {
            // TODO: Load data from Huawei Health.
            loadData(this, flowerClient, partitionId)
        } catch (err: Throwable) {
            return result.error(TAG, "Failed to load data", err.stackTraceToString())
        }
        result.success(serverData.port)
    }

    fun train(result: ResultFlutter) {
        train.start {
            runOnUiThread {
                events?.success(it)
            }
        }
        result.success(null)
    }

    companion object {
        const val TAG = "MainActivity"
    }
}
