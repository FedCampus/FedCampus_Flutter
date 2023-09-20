package com.cuhk.fedcampus.pigeon

import AppUsageStats
import Data
import android.util.Log
import com.cuhk.fedcampus.MainActivity
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.launch

class AppUsageStatsClass(activity: MainActivity) : AppUsageStats {
    val activity: MainActivity

    init {
        this.activity = activity
    }

    override fun getData(
            name: String,
            startTime: Long,
            endTime: Long,
            callback: (Result<List<Data>>) -> Unit
    ) {
        val scope = MainScope()
        Log.i("APP", "hello")
        val data = listOf(Data("test", 1.0, 1, 1))
        scope.launch { callback(Result.success(data)) }
    }
}
