package com.cuhk.fedcampus.health.utils

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import androidx.core.app.NotificationCompat
import com.cuhk.fedcampus.R

const val notificationID = 1
const val channelID = "channel1"
const val titleExtra = "titleExtra";
const val messageExtra = "messageExtra"



class Notification : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val notification = NotificationCompat.Builder(context, channelID)
            .setSmallIcon(R.drawable.health_kit_icon)
            .setContentTitle(intent.getStringExtra( titleExtra))
            .setContentText(intent.getStringExtra(messageExtra))
            .build()

        println("Receiving!!!!")
        // let the user start training
        println("start Training");

        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        manager.notify(notificationID, notification)
    }

}