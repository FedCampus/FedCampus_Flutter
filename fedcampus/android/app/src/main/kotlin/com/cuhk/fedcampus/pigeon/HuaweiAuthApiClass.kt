package com.cuhk.fedcampus.pigeon

import HuaweiAuthApi
import android.app.Activity
import android.content.Context
import android.content.Intent
import com.cuhk.fedcampus.MainActivity
import com.cuhk.fedcampus.health.health.auth.HealthKitAuthActivity
import com.huawei.hms.hihealth.DataController
import com.huawei.hms.hihealth.HuaweiHiHealth

class HuaweiAuthApiClass(activity: MainActivity) : HuaweiAuthApi{

    val activity:MainActivity

    init {
        this.activity=activity;
    }

    override fun getAuthenticate(callback: (Result<Boolean>) -> Unit) {
//        TODO("Not yet implemented")
        val intent = Intent(activity as Activity, HealthKitAuthActivity::class.java)
        activity.startActivityForFlutterResult(intent, 1000, callback)
    }

    override fun cancelAuthenticate(callback: (Result<Boolean>) -> Unit) {
//        TODO("Not yet implemented")
    }

}