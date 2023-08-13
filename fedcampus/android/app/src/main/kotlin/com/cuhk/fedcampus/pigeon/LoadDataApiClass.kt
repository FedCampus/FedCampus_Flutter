package com.cuhk.fedcampus.pigeon

import LoadDataApi
import android.content.Context
import android.util.Log
import com.cuhk.fedcampus.health.health.fedmcrnn.dataCleaning
import com.cuhk.fedcampus.health.health.fedmcrnn.dataSlide
import com.cuhk.fedcampus.health.health.fedmcrnn.getAllDataAvailable
import com.cuhk.fedcampus.health.health.fedmcrnn.logger
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
    override fun loaddata(callback: (Result<Map<List<List<Double>>, List<Double>>>) -> Unit) {
//        TODO("Not yet implemented")
        val scope = MainScope();
        println("starting to get data!")

        scope.launch {
            logger("start data fetching")
            val data = getAllDataAvailable(context)
            logger("finish data fetching")


            logger("start data sliding")
            val input = dataSlide(data)
            logger("finish data sliding")
            logger("data cleaning");
            dataCleaning(input);
            logger("finish data cleaning")

            val inputFinal = mutableMapOf<List<List<Double>>,List<Double>>()
            for (entry in input){
                val key= mutableListOf<List<Double>>();
                for (item in entry.key){
                    val itemFinal = item.toList();
                    key.add(itemFinal)
                }
                val keyFinal = key.toList();
                val valueFinal = entry.value.toList();
                inputFinal[keyFinal] = valueFinal
            }
            val inputFinalFinal = inputFinal.toMap();

            callback(Result.success(inputFinalFinal))
        }

    }

    fun printInputList(input: List<List<Double>>){
        for (list in input){
            println(list.toDoubleArray().contentToString())
        }

    }

}
