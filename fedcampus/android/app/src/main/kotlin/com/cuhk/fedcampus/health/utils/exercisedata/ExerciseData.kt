package com.cuhk.fedcampus.health.utils.exercisedata

import com.cuhk.fedcampus.health.utils.Data
import com.huawei.hms.hihealth.DataController
import com.huawei.hms.hihealth.data.DataType
import com.huawei.hms.hihealth.data.Field
import com.huawei.hms.hihealth.data.MapValue
import com.huawei.hms.hihealth.data.Value
import java.util.concurrent.TimeUnit
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException
import kotlin.coroutines.suspendCoroutine

@Throws
suspend fun getExerciseData(
    dataType: DataType,
    field: Field,
    tag: String,
    dataController: DataController,
    start: Int,
    end: Int,
): List<Data> {
    val sampleSet =
        dataController.readDaySummation(dataType, start, end)


    return sampleSet.samplePoints.map {
        Data(
            it.getFieldValue(field).toFloat().toDouble(),
            tag,
            it.getStartTime(TimeUnit.SECONDS),
            it.getEndTime(TimeUnit.SECONDS)
        )
    }
}

/**
 * Written by inspecting decompiled class file.
 */
@Throws
fun Value.toFloat() = when (format) {
    1 -> asIntValue().toFloat()
    2 -> asFloatValue()
    3 -> throw Error("${asStringValue()} is a string")
    4 -> {
        map!!.values.fold(0f) { acc, mapValue -> mapValue.toFloat() + acc }
    }
    5 -> asLongValue().toFloat()
    else -> throw Error("Unreachable format $format of $this")
}

/**
 * Written by inspecting decompiled class file.
 */
@Throws
fun MapValue.toFloat() = when (format) {
    1 -> asIntValue().toFloat()
    2 -> asFloatValue()
    3 -> throw Error("${asStringValue()} is a string")
    5 -> asLongValue().toFloat()
    else -> throw Error("Unreachable format $format of $this")
}

suspend fun DataController.readDaySummation(dataType: DataType, start: Int, end: Int) =
    suspendCoroutine { continuation ->
        readDailySummation(dataType, start, end).addOnSuccessListener {
            continuation.resume(it)
        }.addOnFailureListener {
            continuation.resumeWithException(it)
        }
    }


val CALORIE =
    Triple(
        DataType.DT_CONTINUOUS_CALORIES_BURNT, Field.FIELD_CALORIES_TOTAL, "calorie"
    )

val INTENSITY = Triple(
    DataType.DT_CONTINUOUS_EXERCISE_INTENSITY_V2, Field.INTENSITY_MAP, "intensity"
)
val DISTANCE =
    Triple(
        DataType.DT_CONTINUOUS_DISTANCE_DELTA, Field.FIELD_DISTANCE, "distance"
    )

val ELEVATION = Triple(
    DataType.DT_INSTANTANEOUS_ALTITUDE, Field.FIELD_ASCENT_TOTAL, "elevation"
)

val STRESS = Triple(
    DataType.DT_INSTANTANEOUS_STRESS, Field.STRESS_AVG, "stress"
)
val EXERCISE_HEART_RATE = Triple(
    DataType.DT_INSTANTANEOUS_HEART_RATE, Field.FIELD_AVG, "exercise_heart_rate"
)

val REST_HEART_RATE = Triple(
    DataType.DT_INSTANTANEOUS_RESTING_HEART_RATE, Field.FIELD_AVG, "rest_heart_rate"
)

fun getExerciseTriple(tag: String) =
    when (tag) {
        "calorie" -> CALORIE
        "intensity" -> INTENSITY
        "distance" -> DISTANCE
        "elevation" -> ELEVATION
        "stress" -> STRESS
        "exercise_heart_rate" -> EXERCISE_HEART_RATE
        "rest_heart_rate" -> REST_HEART_RATE
        else -> throw Error("tag is not in the list")
    }


