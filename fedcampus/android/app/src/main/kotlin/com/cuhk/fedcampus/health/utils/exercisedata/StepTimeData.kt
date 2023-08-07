package com.cuhk.fedcampus.health.utils.exercisedata

import android.annotation.SuppressLint
import android.util.Log
import com.cuhk.fedcampus.health.utils.Data
import com.cuhk.fedcampus.health.utils.DateCalender
import com.huawei.hmf.tasks.Task
import com.huawei.hms.hihealth.DataController
import com.huawei.hms.hihealth.data.DataType
import com.huawei.hms.hihealth.options.ReadOptions
import com.huawei.hms.hihealth.result.ReadReply
import kotlinx.coroutines.async
import kotlinx.coroutines.awaitAll
import kotlinx.coroutines.coroutineScope
import java.text.SimpleDateFormat
import java.util.Date
import java.util.concurrent.TimeUnit
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException
import kotlin.coroutines.suspendCoroutine

suspend fun getStepTimeData(
    tag: String,
    dataController: DataController,
    start: Int,
    end: Int,
): List<Data> = coroutineScope {
    val interval = DateCalender.IntervalDay(start, end)
    (0..interval).map {
        async {
            try {
                getStepTimeDatum(tag, dataController, start, it)
            } catch (err: Throwable) {
                Log.i(STEP_TIME_DATA_TAG, err.stackTraceToString())
                null
            }
        }
    }.awaitAll().filterNotNull()
}

@SuppressLint("SimpleDateFormat")
private suspend fun getStepTimeDatum(
    tag: String,
    dataController: DataController,
    start: Int,
    index: Int
): Data {
    val date = DateCalender.add(start, index)
    val startDate =
        SimpleDateFormat("yyyyMMddHH:mm:ss").parse(date.toString() + "00:00:00") as Date
    val endDate =
        SimpleDateFormat("yyyyMMddHH:mm:ss").parse(date.toString() + "23:59:59") as Date

    val readOptions =
        ReadOptions.Builder().read(DataType.DT_CONTINUOUS_STEPS_DELTA)
            .setTimeRange(startDate.time, endDate.time, TimeUnit.MILLISECONDS)
            .build()

    val readReplyTask: Task<ReadReply> = dataController.read(readOptions)
    val time =
        readStepTime(readReplyTask)

    return Data(
        time.toDouble(),
        tag,
        startDate.time / 1000,
        endDate.time / 1000
    )
}

private suspend fun readStepTime(readReplyTask: Task<ReadReply>) =
    suspendCoroutine { continuation ->
        readReplyTask.addOnSuccessListener { it ->
            continuation.resume(it.sampleSets[0].samplePoints.size)
        }.addOnFailureListener {
            continuation.resumeWithException(it)
        }
    }

const val STEP_TIME_DATA_TAG = "getStepTimeData"
