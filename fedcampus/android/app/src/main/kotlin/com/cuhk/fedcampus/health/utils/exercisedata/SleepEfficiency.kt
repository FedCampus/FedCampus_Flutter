package com.cuhk.fedcampus.health.utils.exercisedata

import Data
import android.annotation.SuppressLint
import android.content.Context
import com.huawei.hmf.tasks.Task
import com.huawei.hms.hihealth.HealthRecordController
import com.huawei.hms.hihealth.HuaweiHiHealth
import com.huawei.hms.hihealth.data.DataType
import com.huawei.hms.hihealth.data.Field
import com.huawei.hms.hihealth.data.HealthDataTypes
import com.huawei.hms.hihealth.options.HealthRecordReadOptions
import com.huawei.hms.hihealth.result.HealthRecordReply
import java.text.SimpleDateFormat
import java.util.*
import java.util.concurrent.TimeUnit
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException
import kotlin.coroutines.suspendCoroutine

@SuppressLint("SimpleDateFormat")
@Throws
/** Read the latest sleep record given the date */
suspend fun getSleepEfficiencyData(
    tag: String,
    context: Context,
    start: Int,
    end: Int
): List<Data> {
    /**
     *
     * the sleep time is a bit troublesome to specify
     * The date passed to the function, for example, 20230720, will get the sleep time from 20230719 19:00 - 20230720 19:00
     */
    val dateFormat = SimpleDateFormat("yyyyMMddHH:mm:ss")

    val startDate = dateFormat.parse((start).toString() + "19:00:00") as Date
    val endDate = dateFormat.parse(end.toString() + "19:00:00") as Date

    val healthRecordController: HealthRecordController =
        HuaweiHiHealth.getHealthRecordController(context)

    val subDataTypeList: MutableList<DataType> = ArrayList()
    subDataTypeList.add(DataType.DT_CONTINUOUS_SLEEP)
    val healthRecordReadOptions: HealthRecordReadOptions =
        HealthRecordReadOptions.Builder()
            .setTimeInterval(startDate.time, endDate.time, TimeUnit.MILLISECONDS)
            .readHealthRecordsFromAllApps()
            .readByDataType(HealthDataTypes.DT_HEALTH_RECORD_SLEEP)
            .setSubDataTypeList(subDataTypeList)
            .build()

    val task: Task<HealthRecordReply> =
        healthRecordController.getHealthRecord(healthRecordReadOptions)
    val healthRecordList = readSleepScore(task)

    var sleepScore: Float
    val data = mutableListOf<Data>()
    for (healthRecord in healthRecordList) {
        when (healthRecord.getFieldValue(Field.SLEEP_TYPE).asIntValue()) {
            1 -> {
                sleepScore = healthRecord.getFieldValue(Field.SLEEP_SCORE).asIntValue().toFloat()
                data.add(
                    Data(
                        tag,
                        sleepScore.toDouble(),
                        healthRecord.getStartTime(TimeUnit.SECONDS),
                        healthRecord.getEndTime(TimeUnit.SECONDS)
                    )
                )
            }
        }
    }
    return data
}

@Throws
private suspend fun readSleepScore(readReplyTask: Task<HealthRecordReply>) =
    suspendCoroutine { continuation ->
        readReplyTask.addOnSuccessListener { it ->
            continuation.resume(it.healthRecords)
        }.addOnFailureListener {
            continuation.resumeWithException(it)
        }
    }
