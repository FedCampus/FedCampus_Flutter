package com.cuhk.fedcampus.pigeon

import HuaweiAuthApi
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.util.Log
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
        val intent = Intent(activity as Activity, HealthKitAuthActivity::class.java)
        activity.startActivityForFlutterResult(intent, 1000, callback)
    }

    override fun cancelAuthenticate(callback: (Result<Boolean>) -> Unit) {
        val mConsentsController = HuaweiHiHealth.getConsentsController(
           activity
        )
        // 2. 是否删除用户数据,true为删除用户数据，false为不删除用户数据
        val clearUserData = true
        // 3. 取消应用全部授权，是否删除用户数据
        val task = mConsentsController.cancelAuthorization(clearUserData)
        task.addOnSuccessListener {
            Log.i(TAG, "cancelAuthorization success")
            if (clearUserData) {
                Log.i(TAG, "clearUserData success")
            }
            callback(Result.success(true))

            // TODO cancel the background server
//            val workManager = WorkManager.getInstance(this@HomeFragment.requireContext())
//            Log.i("workmanager", workManager.toString())

        }.addOnFailureListener {
            Log.e(TAG, "cancelAuthorization exception")
            callback(Result.success(false))

    }

}   companion object {
        const val TAG = "HuaweiAuthApiClass"
    }

}