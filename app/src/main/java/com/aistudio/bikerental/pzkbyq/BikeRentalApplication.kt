package com.aistudio.bikerental.pzkbyq

import android.app.Application
import dagger.hilt.android.HiltAndroidApp
import timber.log.Timber

@HiltAndroidApp
class BikeRentalApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        // Initialize Timber for logging
        Timber.plant(Timber.DebugTree())
    }
}
