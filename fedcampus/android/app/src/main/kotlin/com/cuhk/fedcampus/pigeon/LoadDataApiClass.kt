package com.cuhk.fedcampus.pigeon

import LoadDataApi
import android.content.Context
import android.util.Log
import com.cuhk.fedcampus.health.health.fedmcrnn.dataSlide
import com.cuhk.fedcampus.health.health.fedmcrnn.getAllDataAvailable
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.launch

class LoadDataApiClass(val context: Context) : LoadDataApi {

    //    override fun loaddata(callback: (Result<Boolean>) -> Unit) {
////        TODO("Not yet implemented")
//        val scope = MainScope();
//        scope.launch {
//            println("load data start")
//            val data = getAllDataAvailable(context)
//            val input = dataSlide(data)
//            Log.i("loaddata", "load data success");
//            println(data.first.contentToString())
//            for (arr in data.first) {
//                print(arr.contentToString() + "\n");
//            }
//            println("----")
//            println(data.second.contentToString())
//            callback(Result.success(true))
//        }
//    }
    override fun loaddata(callback: (Result<List<Map<List<List<Double>>, List<Double>>>>) -> Unit) {
//        TODO("Not yet implemented")
        val scope = MainScope();
        println("starting to get data!")

        scope.launch {
            val data = getAllDataAvailable(context)
            val input = dataSlide(data)
            input.forEach { entry ->
                println("input:")
                printInputList(entry.key)
                print("sleep: ${entry.value[0]}")
                println("----------")
            }
            Result.success(input);
        }

    }

    fun printInputList(input: List<List<Double>>){
        for (list in input){
            println(list.toDoubleArray().contentToString())
        }

    }

}
