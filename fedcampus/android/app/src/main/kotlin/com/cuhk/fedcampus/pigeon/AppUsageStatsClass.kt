package com.cuhk.fedcampus.pigeon

import AppUsageStats
import Data
import android.app.Activity
import android.app.AppOpsManager
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Process
import android.provider.Settings
import android.util.Log
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat.startActivity
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.launch

class AppUsageStatsClass(activity: Activity) : AppUsageStats {
  val activity: Activity

  init {
    this.activity = activity
  }

  override fun getData(
      name: String,
      startTime: Long,
      endTime: Long,
      callback: (Result<List<Data>>) -> Unit,
  ) {
    val scope = MainScope()
    Log.i("APP", "hello")
    getAppUsage()
    val data = listOf(Data("test", 1.0, 1, 1))
    scope.launch { callback(Result.success(data)) }
  }

  private fun getAppUsage() {
    Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS).apply {
      activity.startActivity(
          activity.intent,
      )
    }
    if (checkUsageStatsPermission()) {
      // Implement further app logic here
    } else {
      // Navigate the user to the permission settings
      Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS).apply {
        activity.startActivity(
            this,
        )
      }
    }

    var foregroundAppPackageName: String? = null
    val currentTime = System.currentTimeMillis()
    // The `queryEvents` method takes in the `beginTime` and `endTime` to retrieve the usage
    // events.
    // In our case, beginTime = currentTime - 10 minutes ( 1000 * 60 * 10 milliseconds )
    // and endTime = currentTime
    val usageStatsManager =
        activity.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager

    Log.e("APP", currentTime.toString())

    val usageEvents = usageStatsManager.queryUsageStats(0, 1693065600000, currentTime)
    val usageEvent = UsageEvents.Event()

    for (e in usageEvents) {
      Log.e(
          "App",
          "${e.packageName} ${e.lastTimeUsed} ${e.firstTimeStamp} ${e.lastTimeStamp} ${e.totalTimeInForeground / 60000} ${e.totalTimeVisible / 60000}"
      )
    }
  }

  private fun checkUsageStatsPermission(): Boolean {
    val appOpsManager =
        activity.getSystemService(AppCompatActivity.APP_OPS_SERVICE) as AppOpsManager
    // `AppOpsManager.checkOpNoThrow` is deprecated from Android Q
    val mode =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
          appOpsManager.unsafeCheckOpNoThrow(
              "android:get_usage_stats",
              Process.myUid(),
              activity.packageName
          )
        } else {
          appOpsManager.checkOpNoThrow(
              "android:get_usage_stats",
              Process.myUid(),
              activity.packageName
          )
        }
    Log.e("App", mode.toString())
    return mode == AppOpsManager.MODE_ALLOWED
  }
}
