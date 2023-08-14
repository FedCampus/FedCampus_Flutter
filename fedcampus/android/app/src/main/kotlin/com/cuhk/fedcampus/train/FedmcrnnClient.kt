package com.cuhk.fedcampus.train

import TrainFedmcrnn

class FedmcrnnClient : TrainFedmcrnn {
    override fun loadData(
        data: Map<List<List<Double>>, List<Double>>,
        callback: (Result<Unit>) -> Unit
    ) {
        TODO("Not yet implemented")
    }

    override fun getParameters(callback: (Result<List<ByteArray>>) -> Unit) {
        TODO("Not yet implemented")
    }

    override fun updateParameters(parameters: List<ByteArray>, callback: (Result<Unit>) -> Unit) {
        TODO("Not yet implemented")
    }

    override fun ready(): Boolean {
        TODO("Not yet implemented")
    }

    override fun fit(epochs: Long, batchSize: Long, callback: (Result<Unit>) -> Unit) {
        TODO("Not yet implemented")
    }

    override fun trainingSize(): Long {
        TODO("Not yet implemented")
    }

    override fun testSize(): Long {
        TODO("Not yet implemented")
    }

    override fun evaluate(callback: (Result<DoubleArray>) -> Unit) {
        TODO("Not yet implemented")
    }
}
