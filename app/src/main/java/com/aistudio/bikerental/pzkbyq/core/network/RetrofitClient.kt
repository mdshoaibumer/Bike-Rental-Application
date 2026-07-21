package com.aistudio.bikerental.pzkbyq.core.network

import okhttp3.OkHttpClient
import retrofit2.Retrofit
import java.util.concurrent.TimeUnit
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class RetrofitClient @Inject constructor(
    private val authInterceptor: AuthInterceptor
) {
    // We would typically use KotlinxSerializationConverterFactory here.
    // For this boilerplate, we'll just expose the OkHttpClient for now.

    val okHttpClient: OkHttpClient by lazy {
        OkHttpClient.Builder()
            .addInterceptor(authInterceptor)
            .connectTimeout(30, TimeUnit.SECONDS)
            .readTimeout(30, TimeUnit.SECONDS)
            .build()
    }

    // val retrofit = Retrofit.Builder()
    //     .baseUrl("http://10.0.2.2:8080/api/")
    //     .client(okHttpClient)
    //     .addConverterFactory(...)
    //     .build()
}
