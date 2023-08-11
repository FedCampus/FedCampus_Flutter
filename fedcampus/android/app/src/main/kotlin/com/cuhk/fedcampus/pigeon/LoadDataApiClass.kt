package com.cuhk.fedcampus.pigeon

import LoadDataApi
import android.content.Context
import android.util.Log
import com.cuhk.fedcampus.health.health.fedmcrnn.getAllDataAvailable
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.launch

class LoadDataApiClass(val context: Context) : LoadDataApi {

    override fun loaddata(callback: (Result<Boolean>) -> Unit) {
//        TODO("Not yet implemented")
        val scope = MainScope();
        scope.launch {
            println("load data start")
            val data = getAllDataAvailable(context);
            Log.i("loaddata", "load data success");
            println(data.first.contentToString())
            for (arr in data.first) {
                print(arr.contentToString() + "\n");
            }
            println("----")
            println(data.second.contentToString())
            callback(Result.success(true))
        }
    }
}
