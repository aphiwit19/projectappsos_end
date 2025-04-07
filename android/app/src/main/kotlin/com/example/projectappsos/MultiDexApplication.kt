package com.example.projectappsos

import android.app.Application
import androidx.multidex.MultiDex
import android.content.Context

class MultiDexApplication : Application() {
    override fun attachBaseContext(base: Context) {
        super.attachBaseContext(base)
        MultiDex.install(this)
    }
} 