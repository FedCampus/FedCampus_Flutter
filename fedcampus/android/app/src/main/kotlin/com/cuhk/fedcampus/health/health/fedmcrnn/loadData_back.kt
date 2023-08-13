//package com.cuhk.fedcampus.health.health.fedmcrnn
//
//import android.annotation.SuppressLint
//import android.content.Context
//import android.util.Log
//import com.cuhk.fedcampus.health.utils.Data
//import com.cuhk.fedcampus.health.utils.DateCalender
//import com.cuhk.fedcampus.health.utils.exercisedata.getExerciseData
//import com.cuhk.fedcampus.health.utils.exercisedata.getSleepEfficiencyData
//import com.cuhk.fedcampus.health.utils.exercisedata.getStepTimeData
//import com.huawei.hms.hihealth.HuaweiHiHealth.getDataController
//import com.huawei.hms.hihealth.data.DataType
//import com.huawei.hms.hihealth.data.Field
//import kotlinx.coroutines.*
//import org.eu.fedcampus.fed_kit.examples.fedmcrnn.Float2DArray
//import org.eu.fedcampus.fed_kit_train.FlowerClient
//import java.text.SimpleDateFormat
//import java.util.*
//
//
//suspend fun loadData(
//    context: Context,
//    flowerClient: FlowerClient<Float2DArray, FloatArray>,
//    @Suppress("UNUSED_PARAMETER") participantId: Int
//) {
//
//    val data = getAllDataAvailable(context)
//    val input = dataSlide(data)
//    dataCleaning(input)
//    for (sample in input) {
//        flowerClient.addSample(sample.first, sample.second, true)
//        // TODO: Legitimate ways to evaluate instead of using the training set.
//        flowerClient.addSample(sample.first, sample.second, false)
//    }
//}
//
//fun dataCleaning(input: MutableList<Pair<Array<FloatArray>, FloatArray>>) {
//    //TODO the elevation is ignored here
//    for (data in input) {
//        for (j in 0 until data.first[0].size) {
//            var avg = 0f
//            if (j == 4) {
//                // ignore the elevation
//                continue
//            }
//            for (i in 0 until data.first.size) {
//                if (data.first[i][j] == 0f) {
//                    // check if avg is calculated or not
//                    if (avg == 0f) {
//                        avg = calculateAverage(data.first, j)
//                    }
//                    data.first[i][j] = avg
//                }
//            }
//        }
//    }
//}
//
//lateinit var dataListTest: List<Data>
//
//fun calculateAverage(data: Array<FloatArray>, column: Int): Float {
//    var sum = 0f
//    var valid = 0
//    for (i in data.indices) {
//        if (data[i][column] != 0f) {
//            valid++
//            sum += data[i][column]
//        }
//
//    }
//    if (valid == 0) {
//        sum = 0f
//    } else {
//        sum /= valid
//    }
//    return sum
//}
//
//
////fun dataSlide(data: Pair<Array<FloatArray>, FloatArray>): MutableList<Pair<Array<FloatArray>, FloatArray>> {
////    val inputData = mutableListOf<Pair<Array<FloatArray>, FloatArray>>()
////    val day = 7
////    for ((index, element) in data.first.withIndex()) {
////        if (data.second[index] != 0f) {
////            //start to record the next 7 inputs
////            val input = Array(day) { FloatArray(element.size) }
////            val output = floatArrayOf(data.second[index])
////            for (i in 0 until day) {
////                if (index + i >= data.first.size) {
////                    input[i] = data.first[data.first.size - 1]
////                } else {
////                    input[i] = data.first[index + i].clone()
////                }
////            }
////            inputData.add(input to output)
////        }
////    }
////    return inputData
////}
//
//fun dataSlide(data: Pair<Array<FloatArray>, FloatArray>): MutableList<Pair<Array<FloatArray>, FloatArray>> {
//    val inputData = mutableListOf<Pair<Array<FloatArray>, FloatArray>>()
//    val day = 7
//    for ((index, element) in data.first.withIndex()) {
//        if (data.second[index] != 0f) {
//            //start to record the next 7 inputs
//            val input = Array(day) { FloatArray(element.size) }
//            val output = floatArrayOf(data.second[index])
//            for (i in 0 until day) {
//                if (index + i >= data.first.size) {
//                    input[i] = data.first[data.first.size - 1]
//                } else {
//                    input[i] = data.first[index + i].clone()
//                }
//            }
//            inputData.add(input to output)
//        }
//    }
//    return inputData
//}
//
//
//suspend fun getAllDataAvailable(context: Context): Pair<Array<FloatArray>, FloatArray> {
//    val maximumTime = 1
//    val interval = 25
//    var day = DateCalender.add(DateCalender.getCurrentDateNumber(), -1)
//    val dataArray = (1..maximumTime).mapNotNull {
//        val prevDay = DateCalender.add(day, -interval)
//        val startEnd = intArrayOf(prevDay, day)
//        day = DateCalender.add(prevDay, -1)
//        try {
//            getData(startEnd, context)
//        } catch (err: Throwable) {
//            Log.e(LOAD_DATA_TAG, "getAllDataAvailable: ${err.stackTraceToString()}")
//            null
//        }
//    }
//
//    return getDataAll(dataArray)
//}
//
//fun getDataAll(dataArr: List<Pair<Array<FloatArray>, FloatArray>>): Pair<Array<FloatArray>, FloatArray> {
//    val inputLength = dataArr.map { it.first.size }.sum()
//    val columnLength = dataArr[0].first[0].size
//
//    val input = Array(inputLength) { FloatArray(columnLength) }
//    val output = FloatArray(inputLength)
//
//    var index = 0
//    for (data in dataArr) {
//        for ((i, value) in data.first.withIndex()) {
//            input[index] = value
//            output[index] = data.second[i]
//            index++
//        }
//    }
//    return input to output
//}
//
//@Throws
//suspend fun getData(
//    startEnd: IntArray, context: Context
//): Pair<Array<FloatArray>, FloatArray> {
//    val exerciseDataArray = arrayOf(
//        Triple(
//            DataType.DT_CONTINUOUS_CALORIES_BURNT, Field.FIELD_CALORIES_TOTAL, "calorie"
//        ), Triple(
//            DataType.DT_CONTINUOUS_EXERCISE_INTENSITY_V2, Field.INTENSITY_MAP, "intensity"
//        ), Triple(
//            DataType.DT_CONTINUOUS_DISTANCE_DELTA, Field.FIELD_DISTANCE, "distance"
//        ), Triple(
//            DataType.DT_INSTANTANEOUS_ALTITUDE, Field.FIELD_ASCENT_TOTAL, "elevation"
//        ), Triple(
//            DataType.DT_INSTANTANEOUS_STRESS, Field.STRESS_AVG, "stress"
//        ), Triple(
//            DataType.DT_INSTANTANEOUS_HEART_RATE, Field.FIELD_AVG, "exercise_heart_rate"
//        ), Triple(
//            DataType.DT_INSTANTANEOUS_RESTING_HEART_RATE, Field.FIELD_AVG, "rest_heart_rate"
//        )
//    )
//    logger("loading Input 2D Array: time: ${startEnd[0]}-${startEnd[1]}")
//
//    val dataController = getDataController(context)
//    val dataList = coroutineScope {
//        val jobs = exerciseDataArray.map { (dt, field, tag) ->
//            async {
//                tryOrNull("getData") {
//                    getExerciseData(
//                        dt,
//                        field,
//                        tag,
//                        dataController,
//                        startEnd[0],
//                        startEnd[1],
//                    )
//                }
//            }
//        }.toMutableList()
//        jobs.add(async {
//            getStepTimeData("step_time", dataController, startEnd[0], startEnd[1])
//        })
//        jobs.add(async {
//            tryOrNull("getData") {
//                getSleepEfficiencyData(
//                    "sleep_efficiency",
//                    context,
//                    startEnd[0],
//                    DateCalender.add(startEnd[1], 1)
//                )
//            }
//        })
//
//        jobs.awaitAll().filterNotNull().flatten()
//    }
//
//    dataListTest = dataList
//
//
//    Log.i("data-length", dataList.size.toString())
//    return getInput2DArrayAndOutputArray(dataList, startEnd)
//}
//
//private suspend fun <T> tryOrNull(tag: String, call: suspend () -> T) = try {
//    call()
//} catch (err: Throwable) {
//    Log.e(LOAD_DATA_TAG, "$tag: ${err.stackTraceToString()}")
//    null
//}
//
//@SuppressLint("SimpleDateFormat")
//private fun getInput2DArrayAndOutputArray(
//    dataList: List<Data>, startEnd: IntArray
//): Pair<Array<FloatArray>, FloatArray> {
//    // TODO: This part is hard coded just for FedMCRNN
//    val sizeOfSingleColumn = DateCalender.IntervalDay(startEnd[0], startEnd[1]) + 1
//    val start = startEnd[0]
//    val input2DArray = Array(sizeOfSingleColumn) { FloatArray(TAG_LIST.size) }
//    val outputArray = FloatArray(sizeOfSingleColumn)
//    for (data in dataList) {
//        val time = SimpleDateFormat("yyyyMMdd").format(Date(data.startTime * 1000L)).toInt()
//        val rowIndex = sizeOfSingleColumn - 1 - DateCalender.IntervalDay(start, time)
//        if (data.name == "sleep_efficiency") {
//            try{
//            outputArray[rowIndex] = data.value.toFloat()}
//            catch (err: Exception){
//                print(time);
//                print(rowIndex);
//                print(data.toString());
//            }
//            continue
//        }
//        val columnIndex = TAG_LIST.indexOf(data.name)
//        input2DArray[rowIndex][columnIndex] = data.value.toFloat()
//    }
//    return input2DArray to outputArray
//}
//
//const val LOAD_DATA_TAG = "loadData"
//fun logger(msg: String) {
//    Log.i(LOAD_DATA_TAG, msg)
//}
//
//val TAG_LIST = arrayOf(
//    "calorie",
//    "distance",
//    "step_time",
//    "intensity",
//    "elevation",
//    "stress",
//    "exercise_heart_rate",
//    "rest_heart_rate"
//)
