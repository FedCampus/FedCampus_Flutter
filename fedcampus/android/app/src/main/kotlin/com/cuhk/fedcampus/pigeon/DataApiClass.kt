package com.cuhk.fedcampus.pigeon

import DataApi
import android.content.Context
import com.cuhk.fedcampus.health.utils.Data
import com.cuhk.fedcampus.health.utils.exercisedata.getExerciseData
import com.huawei.hms.hihealth.DataController
import com.huawei.hms.hihealth.HuaweiHiHealth
import com.huawei.hms.hihealth.data.DataType
import com.huawei.hms.hihealth.data.Field
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.launch

class DataApiClass :DataApi{
    val dataController : DataController

    constructor(context: Context){
        dataController = HuaweiHiHealth.getDataController(context);
    }

    override fun getData(
        name: String,
        startTime: Long,
        endTime: Long,
        callback: (Result<List<Data>>) -> Unit
    ) {
//        TODO("Not yet implemented")
        val scope = MainScope();
        scope.launch {
            val data = getExerciseData(
                        DataType.DT_CONTINUOUS_STEPS_DELTA, Field.FIELD_STEPS, name,dataController,startTime.toInt(), endTime.toInt()
            )
            callback(Result.success(data))

        }
    }


}