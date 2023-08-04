package com.cuhk.fedcampus


import DataApi
import android.content.Intent
import android.util.Log
import com.cuhk.fedcampus.health.health.auth.HealthKitAuthActivity
import com.cuhk.fedcampus.health.utils.exercisedata.getExerciseData
import com.cuhk.fedcampus.pigeon.DataApiClass
import com.huawei.hms.hihealth.DataController
import com.huawei.hms.hihealth.HuaweiHiHealth
import com.huawei.hms.hihealth.data.DataType
import com.huawei.hms.hihealth.data.Field
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding

import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.launch
import org.eu.fedcampus.fed_kit.FlowerClient
import org.eu.fedcampus.fed_kit.Train
import org.eu.fedcampus.fed_kit.examples.cifar10.DATA_TYPE
import org.eu.fedcampus.fed_kit.examples.cifar10.Float3DArray
import org.eu.fedcampus.fed_kit.examples.cifar10.loadData
import org.eu.fedcampus.fed_kit.examples.cifar10.sampleSpec
import org.eu.fedcampus.fed_kit.helpers.deviceId
import org.eu.fedcampus.fed_kit.helpers.loadMappedFile

class MainActivity : FlutterActivity() {
    val scope = MainScope()
    lateinit var train: Train<Float3DArray, FloatArray>
    lateinit var flowerClient: FlowerClient<Float3DArray, FloatArray>
    var events: EventSink? = null

    lateinit var result: Result

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)


        DataApi.setUp(flutterEngine.dartExecutor.binaryMessenger, DataApiClass(this.activity));

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

    fun handle(call: MethodCall, result: Result) = scope.launch {

        this@MainActivity.result = result;

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
                "get_data" -> {
                    val dataController = HuaweiHiHealth.getDataController(this@MainActivity);
                    val data = getExerciseData(
                        DataType.DT_CONTINUOUS_STEPS_DELTA,
                        Field.FIELD_STEPS,
                        "step",
                        dataController,
                        20230802,
                        20230802
                    )
                    result.success(data.toString());
                }


                else -> result.notImplemented()
            }
        } catch (err: Throwable) {
            result.error("shit", "$err", err.stackTraceToString())
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == 1000) {
            if (resultCode == 200) {
                result.success("user authenticated")
            }

        }
    }

    suspend fun connect(
        partitionId: Int, host: String, backendUrl: String, startFresh: Boolean, result: Result
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

    fun train(result: Result) {
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

