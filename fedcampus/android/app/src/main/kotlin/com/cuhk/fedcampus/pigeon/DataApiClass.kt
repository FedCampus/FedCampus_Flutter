package com.cuhk.fedcampus.pigeon

import DataApi
import android.content.Context
import com.cuhk.fedcampus.health.utils.Data
import com.cuhk.fedcampus.health.utils.DateCalender
import com.cuhk.fedcampus.health.utils.exercisedata.CALORIE
import com.cuhk.fedcampus.health.utils.exercisedata.DISTANCE
import com.cuhk.fedcampus.health.utils.exercisedata.EXERCISE_HEART_RATE
import com.cuhk.fedcampus.health.utils.exercisedata.INTENSITY
import com.cuhk.fedcampus.health.utils.exercisedata.REST_HEART_RATE
import com.cuhk.fedcampus.health.utils.exercisedata.STEP
import com.cuhk.fedcampus.health.utils.exercisedata.STRESS
import com.cuhk.fedcampus.health.utils.exercisedata.getExerciseData
import com.cuhk.fedcampus.health.utils.exercisedata.getSleepEfficiencyData
import com.cuhk.fedcampus.health.utils.exercisedata.getStepTimeData
import com.huawei.hms.hihealth.DataController
import com.huawei.hms.hihealth.HuaweiHiHealth
import com.huawei.hms.hihealth.data.DataType
import com.huawei.hms.hihealth.data.Field
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.launch

class DataApiClass(context: Context) : DataApi {
    val dataController: DataController
    val context: Context

    init {
        this.context = context
        dataController = HuaweiHiHealth.getDataController(context)
    }

    override fun getData(
        name: String, startTime: Long, endTime: Long, callback: (Result<List<Data>>) -> Unit
    ) {
        //check if it is sleep
        val scope = MainScope()
        if (name == "sleep_efficiency") {
            scope.launch {
                try {
                    val data = getSleepEfficiencyData(
                        "sleep_efficiency",
                        context,
                        startTime.toInt(),
                        DateCalender.add(endTime.toInt(), 1)
                    )
                    callback(Result.success(data))
                } catch (err: Exception) {
                    callback(Result.failure(err))
                }
            }
            return
        }
        if (name == "step_time") {
            scope.launch {
                try {
                    val data =
                        getStepTimeData(name, dataController, startTime.toInt(), endTime.toInt())
                    callback(Result.success(data))
                } catch (e: Exception) {
                    callback(Result.failure(e))
                }
            }
            return
        }

        val inputTriple: Triple<DataType, Field, String>
        when (name) {
            "calorie" -> {
                inputTriple = CALORIE
            }

            "intensity" -> {
                inputTriple = INTENSITY
            }

            "distance" -> {
                inputTriple = DISTANCE
            }

            "stress" -> {
                inputTriple = STRESS
            }

            "exercise_heart_rate" -> {
                inputTriple = EXERCISE_HEART_RATE
            }

            "rest_heart_rate" -> {
                inputTriple = REST_HEART_RATE
            }

            "step" -> {
                inputTriple = STEP
            }

            else -> {
                throw Exception("Data Type \'$name\' not supported")
            }
        }

        scope.launch {
            try {
                val data = getExerciseData(
                    inputTriple.first,
                    inputTriple.second,
                    inputTriple.third,
                    dataController,
                    startTime.toInt(),
                    endTime.toInt()
                )
                callback(Result.success(data))
            } catch (e: Exception) {
                callback(Result.failure(e))
            }
        }
    }


}
