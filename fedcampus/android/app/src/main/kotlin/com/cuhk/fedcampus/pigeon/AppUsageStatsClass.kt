package com.cuhk.fedcampus.pigeon

import AppUsageStats
import Data
import android.app.Activity
import android.app.AppOpsManager
import android.app.usage.UsageStats
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Process
import android.provider.Settings
import android.util.Log
import androidx.appcompat.app.AppCompatActivity
import java.time.LocalDate
import java.time.ZoneId
import java.util.*
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.launch

class AppUsageStatsClass(activity: Activity) : AppUsageStats {
  private val activity: Activity
  private val filterList = listOf("com.android.launcher")

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
    scope.launch {
      try {
        val response = getAppUsage(startTime, endTime)
        val data = listOf(Data("total_time_foreground", response, startTime, endTime))
        callback(Result.success(data))
      } catch (err: Exception) {
        Log.e("App", err.toString())
        callback(Result.failure(err))
      }
    }
  }

  override fun getAuthenticate(callback: (Result<Unit>) -> Unit) {
    val scope = MainScope()
    scope.launch {
      try {
        Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS).apply {
          activity.startActivity(
              this,
          )
        }
      } catch (err: Exception) {
        callback(Result.failure(err))
      }
    }
  }

  private fun getAppUsage(
      startTime: Long,
      endTime: Long,
  ): Double {
    Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS).apply {
      activity.startActivity(
          activity.intent,
      )
    }
    if (!checkUsageStatsPermission()) {
      throw Exception("No PACKAGE_USAGE_STATS granted")
    }
    val dcode1: Long = startTime
    val dcode2: Long = endTime
    val date =
        LocalDate.of(
            (dcode1 / 10000).toInt(),
            ((dcode1 % 10000) / 100).toInt(),
            (dcode1 % 100).toInt()
        )
    val date2 =
        LocalDate.of(
            (dcode2 / 10000).toInt(),
            ((dcode2 % 10000) / 100).toInt(),
            (dcode2 % 100).toInt()
        )
    val zoneId: ZoneId = ZoneId.systemDefault()
    val epoch1: Long = (date.atStartOfDay(zoneId).toEpochSecond() + 43200) * 1000
    val epoch2: Long = (date2.atStartOfDay(zoneId).toEpochSecond() - 39600) * 1000
    println(epoch1)
    println(epoch2)

    val usageStatsManager =
        activity.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager

    val usageEvents: List<UsageStats> = usageStatsManager.queryUsageStats(0, epoch1, epoch2)

    var totalTimeInForeground = 0

    if (usageEvents.isEmpty()) {
      Log.e("App", "No time foreground")
      return 0.toDouble()
    }

    for (e in usageEvents) {
      Log.e(
          "App",
          "${e.packageName} ${e.lastTimeUsed} ${e.firstTimeStamp} ${e.lastTimeStamp} ${e.totalTimeInForeground / 60000} ${e.totalTimeVisible / 60000}"
      )

      if (!filterPackageName(e.packageName)) {
        totalTimeInForeground += (e.totalTimeVisible / 60000).toInt()
      }
    }
    Log.e("App", totalTimeInForeground.toString())
    return totalTimeInForeground.toDouble()
  }

  private fun filterPackageName(packageName: String): Boolean {
    return filterList.contains(packageName)
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
