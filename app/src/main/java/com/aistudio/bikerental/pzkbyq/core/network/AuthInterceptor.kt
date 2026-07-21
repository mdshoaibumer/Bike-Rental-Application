package com.aistudio.bikerental.pzkbyq.core.network

import okhttp3.Interceptor
import okhttp3.Response
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class AuthInterceptor @Inject constructor(
    // In a real app we would inject a TokenManager here
) : Interceptor {
    override fun intercept(chain: Interceptor.Chain): Response {
        val originalRequest = chain.request()
        
        // Example: Retrieve token from DataStore/SharedPreferences
        val token = "mock_jwt_token_for_now"
        
        val newRequest = originalRequest.newBuilder()
            .addHeader("Authorization", "Bearer $token")
            .build()
            
        return chain.proceed(newRequest)
    }
}
