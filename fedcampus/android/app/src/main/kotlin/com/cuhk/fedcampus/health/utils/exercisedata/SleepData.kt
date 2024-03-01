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
import com.huawei.hms.hihealth.data.HealthRecord
import com.huawei.hms.hihealth.data.Value
import com.huawei.hms.hihealth.options.HealthRecordReadOptions
import com.huawei.hms.hihealth.result.HealthRecordReply
import java.text.SimpleDateFormat
import java.time.LocalDate
import java.util.*
import java.util.concurrent.TimeUnit
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException
import kotlin.coroutines.suspendCoroutine

val fieldMap: Map<String, Field> =
    mapOf(
        "fall_asleep_time" to Field.FALL_ASLEEP_TIME,
        "wakeup_time" to Field.WAKE_UP_TIME,
        "sleep_time" to Field.ALL_SLEEP_TIME,
        "sleep_efficiency" to Field.SLEEP_SCORE
    )

val convertionMap: Map<String, (Value) -> Double> =
    mapOf(
        "fall_asleep_time" to { x -> extractMinutes(x.asLongValue()) },
        "wakeup_time" to { x -> extractMinutes(x.asLongValue()) },
        "sleep_time" to { x -> x.asIntValue().toDouble() },
        "sleep_efficiency" to { x -> x.asIntValue().toDouble() }
    )

fun extractMinutes(timestamp: Long): Double {
    return (timestamp / (60 * 1000) % 1440).toDouble()
}

fun intDateOneDayPrev(date: Int): Int {
    val dateString = date.toString()
    val year = dateString.substring(0, 4).toInt()
    val month = dateString.substring(4, 6).toInt()
    val day = dateString.substring(6, 8).toInt()

    val localDate = LocalDate.of(year, month, day)
    val previousDay = localDate.minusDays(1)

    val newDate =
        (previousDay.year * 10000) + (previousDay.monthValue * 100) + previousDay.dayOfMonth
    return newDate
}

suspend fun getSleepData(dataType: String, context: Context, start: Int, end: Int): List<Data> {
    val result: List<Data>
    if (dataType == "sleep_duration") {
        val startList = getSleepData("fall_asleep_time", context, start, end)
        val endList = getSleepData("wakeup_time", context, start, end)
        result =
            startList.zip(endList) { first, second ->
                Data(dataType, first.value * 10000 + second.value, first.startTime, first.endTime)
            }
    } else {
        result = getSleepDataRaw(dataType, context, start, end)
    }

    return result
}

suspend fun getSleepDataRaw(dataType: String, context: Context, start: Int, end: Int): List<Data> {
    var healthRecordList =
        buildHealthRecordList(context, intDateOneDayPrev(start), intDateOneDayPrev(end))
    // SLEEP_SCORE only available when SLEEP_TYPE is 1 (TruSleep)
    // https://developer.huawei.com/consumer/en/doc/HMSCore-Guides/sleep-record-0000001135051288
    if (dataType == "sleep_efficiency")
        healthRecordList =
            healthRecordList.filter { it.getFieldValue(Field.SLEEP_TYPE).asIntValue() == 1 }
    val data =
        healthRecordList.map {
            Data(
                dataType,
                convertionMap[dataType]!!.invoke(it.getFieldValue(fieldMap[dataType])),
                it.getStartTime(TimeUnit.SECONDS),
                it.getEndTime(TimeUnit.SECONDS)
            )
        }
    return data
}

suspend fun buildHealthRecordList(context: Context, start: Int, end: Int): List<HealthRecord> {
    /**
     * the sleep time is a bit troublesome to specify The date passed to the function, for example,
     * 20230720, will get the sleep time from 20230719 19:00 - 20230720 19:00
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

    return healthRecordList
}

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
     * the sleep time is a bit troublesome to specify The date passed to the function, for example,
     * 20230720, will get the sleep time from 20230719 19:00 - 20230720 19:00
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
        readReplyTask
            .addOnSuccessListener { it -> continuation.resume(it.healthRecords) }
            .addOnFailureListener { continuation.resumeWithException(it) }
    }
