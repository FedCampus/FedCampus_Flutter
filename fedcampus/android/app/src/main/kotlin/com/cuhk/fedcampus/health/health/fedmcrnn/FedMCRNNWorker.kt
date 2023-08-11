package com.cuhk.fedcampus.health.health.fedmcrnn

import android.content.Context
import android.util.Log
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.WorkManager
import androidx.work.WorkerParameters
import com.cuhk.fedcampus.R
import org.eu.fedcampus.fed_kit.background.BaseTrainWorker
import org.eu.fedcampus.fed_kit.background.fastTrainWorkRequest
import org.eu.fedcampus.fed_kit.background.trainWorkerData
import org.eu.fedcampus.fed_kit.examples.fedmcrnn.DATA_TYPE
import org.eu.fedcampus.fed_kit.examples.fedmcrnn.Float2DArray
import org.eu.fedcampus.fed_kit.examples.fedmcrnn.sampleSpec
import org.eu.fedcampus.fed_kit_train.helpers.deviceId

class FedMCRNNWorker(context: Context, params: WorkerParameters) :
    BaseTrainWorker<Float2DArray, FloatArray>(
        context,
        params,
        R.drawable.ic_launcher_foreground,
        sampleSpec(),
        DATA_TYPE,
        ::loadData,
        ::logTrain
    ) {
    companion object {
        const val TAG = "FedMCRNNWorker"
    }
}

fun logTrain(msg: String) {
    Log.i(FedMCRNNWorker.TAG, msg)
}

fun schedule(context: Context) {
    val deviceId = deviceId(context)
    val inputData = trainWorkerData("http://$HOST:8000", deviceId, HOST, 0)
    val work = fastTrainWorkRequest<FedMCRNNWorker, Float2DArray, FloatArray>(inputData)
    val workManager = WorkManager.getInstance(context)

    workManager.enqueueUniquePeriodicWork(
        FedMCRNNWorker.TAG,
        ExistingPeriodicWorkPolicy.UPDATE,
        work
    )
    val workImmediate = OneTimeWorkRequestBuilder<FedMCRNNWorker>().addTag(FedMCRNNWorker.TAG)
        .setInputData(inputData).build()
    workManager.enqueue(workImmediate)
    Log.d(FedMCRNNWorker.TAG, "Submitted training work request $work.")
}

const val HOST = "fed-ml.dukekunshan.edu.cn"
