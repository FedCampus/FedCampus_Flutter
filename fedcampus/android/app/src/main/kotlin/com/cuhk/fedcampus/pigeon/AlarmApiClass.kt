package com.cuhk.fedcampus.pigeon

import AlarmApi
import android.app.Activity
import android.content.Intent
import com.cuhk.fedcampus.MainActivity
import com.cuhk.fedcampus.NotificationActivity

class AlarmApiClass(activity: MainActivity) : AlarmApi {
    val activity: MainActivity

    init {
        this.activity = activity;
    }

    override fun setAlarm(callback: (Result<Boolean>) -> Unit) {
//        TODO("Not yet implemented")
        val intent = Intent(activity as Activity, NotificationActivity::class.java)
        activity.startActivityForFlutterResult(intent, 1001, callback);
    }
}