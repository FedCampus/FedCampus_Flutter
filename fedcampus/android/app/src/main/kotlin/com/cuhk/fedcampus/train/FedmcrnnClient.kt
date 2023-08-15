package com.cuhk.fedcampus.train

import LossAccuracy
import TrainFedmcrnn
import android.app.Activity
import android.util.Log
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.launch
import org.eu.fedcampus.fed_kit_examples.fedmcrnn.Float2DArray
import org.eu.fedcampus.fed_kit_examples.fedmcrnn.sampleSpec
import org.eu.fedcampus.fed_kit_train.FlowerClient
import org.eu.fedcampus.fed_kit_train.helpers.loadMappedFile
import org.eu.fedcampus.fed_kit_train.helpers.toFloatArray
import java.io.File
import java.nio.ByteBuffer

class FedmcrnnClient(val context: Activity, messenger: BinaryMessenger) : TrainFedmcrnn {
    val scope = MainScope()
    lateinit var flowerClient: FlowerClient<Float2DArray, FloatArray>
    var events: EventChannel.EventSink? = null

    init {
        EventChannel(
            messenger, "org.eu.fedcampus.train.FedmcrnnClient.EventChannel"
        ).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, eventSink: EventChannel.EventSink?) {
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

    override fun initialize(
        modelDir: String, layersSizes: List<Long>, callback: (Result<Unit>) -> Unit
    ) = tryRun(callback) {
        val buffer = loadMappedFile(File(modelDir))
        flowerClient =
            FlowerClient(buffer, layersSizes.map { it.toInt() }.toIntArray(), sampleSpec())
    }

    @Suppress("NAME_SHADOWING")
    override fun loadData(
        data: Map<List<List<Double>>, List<Double>>, callback: (Result<Unit>) -> Unit
    ) = tryRun(callback) {
        /// TODO: Remove the following line and use the data passed in.
        val data = com.cuhk.fedcampus.health.health.fedmcrnn.loadData(context)
        Log.d(TAG, "loadData: data size: ${data.size}.")
        for ((features, labels) in data) {
            val x = features.map { it.toFloatArray() }.toTypedArray()
            val y = labels.toFloatArray()
            flowerClient.addSample(x, y, true)
            flowerClient.addSample(x, y, false)
        }
    }

    override fun getParameters(callback: (Result<List<ByteArray>>) -> Unit) = tryRun(callback) {
        flowerClient.getParameters().map { it.array() }
    }

    override fun updateParameters(parameters: List<ByteArray>, callback: (Result<Unit>) -> Unit) =
        tryRun(callback) {
            flowerClient.updateParameters(parameters.map { ByteBuffer.wrap(it) }.toTypedArray())
        }

    override fun ready() =
        flowerClient.trainingSamples.isNotEmpty() && flowerClient.testSamples.isNotEmpty()

    override fun fit(epochs: Long, batchSize: Long, callback: (Result<Unit>) -> Unit) =
        tryRun(callback) {
            flowerClient.fit(
                epochs.toInt(), batchSize.toInt()
            ) { context.runOnUiThread { events?.success(it) } }
        }

    override fun trainingSize() = flowerClient.trainingSamples.size.toLong()

    override fun testSize() = flowerClient.testSamples.size.toLong()

    override fun evaluate(callback: (Result<LossAccuracy>) -> Unit) = tryRun(callback) {
        val (loss, accuracy) = flowerClient.evaluate()
        LossAccuracy(loss.toDouble(), accuracy.toDouble())
    }

    private fun <T> tryRun(callback: (Result<T>) -> Unit, block: suspend () -> T) {
        tryLaunch(callback, block)
    }

    private fun <T> tryLaunch(callback: (Result<T>) -> Unit, block: suspend () -> T) =
        scope.launch(Dispatchers.Default) {
            try {
                val result = block()
                context.runOnUiThread { callback(Result.success(result)) }
            } catch (err: Throwable) {
                context.runOnUiThread { callback(Result.failure(err)) }
            }
        }

    companion object {
        const val TAG = "FedmcrnnClient"
    }
}
