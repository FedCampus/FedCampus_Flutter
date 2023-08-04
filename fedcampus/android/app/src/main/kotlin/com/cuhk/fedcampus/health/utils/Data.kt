package com.cuhk.fedcampus.health.utils

data class Data(var value: Double, var name: String, var startTime: Long, var endTime: Long){
    companion object {
        @Suppress("UNCHECKED_CAST")
        fun fromList(list: List<Any?>): Data {
            val name = list[0] as String
            val value = list[1] as Double
            val startTime = list[2].let { if (it is Int) it.toLong() else it as Long }
            val endTime = list[3].let { if (it is Int) it.toLong() else it as Long }
            return Data(value.toDouble(), name, startTime, endTime)
        }
    }
    fun toList(): List<Any?> {
        return listOf<Any?>(
            name,
            value,
            startTime,
            endTime,
        )
    }
}
