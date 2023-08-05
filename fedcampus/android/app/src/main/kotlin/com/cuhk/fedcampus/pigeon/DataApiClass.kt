package com.cuhk.fedcampus.pigeon

import DataApi
import android.content.Context
import com.cuhk.fedcampus.health.utils.Data
import com.cuhk.fedcampus.health.utils.exercisedata.*
import com.huawei.hms.hihealth.DataController
import com.huawei.hms.hihealth.HuaweiHiHealth
import com.huawei.hms.hihealth.data.DataType
import com.huawei.hms.hihealth.data.Field
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.launch

class DataApiClass(context: Context) : DataApi {
    val dataController: DataController

    init {
        dataController = HuaweiHiHealth.getDataController(context)
    }

    override fun getData(
        name: String,
        startTime: Long,
        endTime: Long,
        callback: (Result<List<Data>>) -> Unit
    ) {
//        TODO("Not yet implemented")

        //check


        val scope = MainScope();
        val inputTriple:Triple<DataType, Field, String>;
        when (name){
            "calorie" -> {
                inputTriple =  CALORIE
            }
            "intensity" ->{
                inputTriple = INTENSITY
            }
            "distance"-> {
                inputTriple = DISTANCE
            }
            "stress" -> {
                inputTriple = STRESS
            }
            "exercise_heart_rate" -> {
                inputTriple = EXERCISE_HEART_RATE
            }
            "rest_heart_rate" ->{
                inputTriple = REST_HEART_RATE
            }
            "step" ->{
                inputTriple = STEP;
            }
            else ->{
                throw Exception("Data Type \'$name\' not supported")
            }
        }

        scope.launch {
            val data = getExerciseData(
                inputTriple.first,
                inputTriple.second,
                inputTriple.third,
                dataController,
                startTime.toInt(),
                endTime.toInt()
            )
            callback(Result.success(data))
        }
    }


}