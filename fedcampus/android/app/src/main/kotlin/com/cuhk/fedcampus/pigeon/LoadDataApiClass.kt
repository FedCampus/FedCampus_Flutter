package com.cuhk.fedcampus.pigeon

import Data
import LoadDataApi
import android.content.Context
import com.cuhk.fedcampus.health.health.fedmcrnn.*
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.launch

class LoadDataApiClass(val context: Context) : LoadDataApi {

    override fun loaddata(
        dataList: List<Data>,
        startTime: Long,
        endTime: Long,
        callback: (Result<Map<Any?, Any?>>) -> Unit
    ) {

        val scope = MainScope()
        println("starting to get data!")

        scope.launch {
            logger("start data fetching")
            val startEndArray = intArrayOf(startTime.toInt(), endTime.toInt())
            print(startEndArray[0].toString()+ " "+ startEndArray[1].toString())
            val data =getInput2DArrayAndOutputArray(dataList,startEndArray)
            logger("finish data fetching")

            logger("start data sliding")
            val input = dataSlide(data)
            logger("finish data sliding")
            logger("data cleaning")
            dataCleaning(input)
            logger("finish data cleaning")

            val inputFinal = mutableMapOf<List<List<Double>>, List<Double>>()
            for (entry in input) {
                val key = mutableListOf<List<Double>>()
                for (item in entry.key) {
                    val itemFinal = item.toList()
                    key.add(itemFinal)
                }
                val keyFinal = key.toList()
                val valueFinal = entry.value.toList()
                inputFinal[keyFinal] = valueFinal
            }
            val inputFinalFinal = inputFinal.toMap()

            callback(Result.success(inputFinalFinal as Map<Any?, Any?>))
        }
    }


}
