package com.cuhk.fedcampus.train

import TrainFedmcrnn
import android.app.Activity
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.launch
import org.eu.fedcampus.fed_kit_examples.fedmcrnn.Float2DArray
import org.eu.fedcampus.fed_kit_examples.fedmcrnn.sampleSpec
import org.eu.fedcampus.fed_kit_train.FlowerClient
import org.eu.fedcampus.fed_kit_train.helpers.loadMappedFile
import org.eu.fedcampus.fed_kit_train.helpers.toFloatArray
import java.io.File

class FedmcrnnClient(val context: Activity) : TrainFedmcrnn {
    val scope = MainScope()
    lateinit var flowerClient: FlowerClient<Float2DArray, FloatArray>

    override fun initialize(
        modelDir: String, layersSizes: List<Long>, callback: (Result<Unit>) -> Unit
    ) = tryRun(callback) {
        val buffer = loadMappedFile(File(modelDir))
        flowerClient =
            FlowerClient(buffer, layersSizes.map { it.toInt() }.toIntArray(), sampleSpec())
    }

    override fun loadData(
        data: Map<List<List<Double>>, List<Double>>, callback: (Result<Unit>) -> Unit
    ) = tryRun(callback) {
        for ((features, labels) in data) {
            val x = features.map { it.toFloatArray() }.toTypedArray()
            val y = labels.toFloatArray()
            flowerClient.addSample(x, y, true)
            flowerClient.addSample(x, y, false)
        }
    }

    override fun getParameters(callback: (Result<List<ByteArray>>) -> Unit) {
        TODO("Not yet implemented")
    }

    override fun updateParameters(parameters: List<ByteArray>, callback: (Result<Unit>) -> Unit) {
        TODO("Not yet implemented")
    }

    override fun ready(): Boolean {
        TODO("Not yet implemented")
    }

    override fun fit(epochs: Long, batchSize: Long, callback: (Result<Unit>) -> Unit) {
        TODO("Not yet implemented")
    }

    override fun trainingSize(): Long {
        TODO("Not yet implemented")
    }

    override fun testSize(): Long {
        TODO("Not yet implemented")
    }

    override fun evaluate(callback: (Result<DoubleArray>) -> Unit) {
        TODO("Not yet implemented")
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
}
