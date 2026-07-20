package com.aistudio.bikerental.pzkbyq.features.auth.domain

import com.aistudio.bikerental.pzkbyq.core.common.Result
import com.aistudio.bikerental.pzkbyq.core.network.RetrofitClient
import kotlinx.coroutines.delay
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class ApiAuthRepositoryImpl @Inject constructor(
    private val retrofitClient: RetrofitClient
) : AuthRepository {
    override suspend fun sendOtp(phoneNumber: String): Result<Boolean> {
        delay(500)
        return Result.Success(true)
    }

    override suspend fun verifyOtp(phoneNumber: String, otp: String): Result<CustomerProfile> {
        delay(500)
        return Result.Success(CustomerProfile(
            uuid = "api-customer-uuid",
            name = "API User",
            phone = phoneNumber,
            email = null,
            address = null,
            drivingLicenseNumber = null
        ))
    }

    override suspend fun adminLogin(email: String, password: String): Result<Boolean> {
        delay(500)
        return Result.Success(true)
    }

    override suspend fun logout(): Result<Boolean> {
        delay(200)
        return Result.Success(true)
    }
}
