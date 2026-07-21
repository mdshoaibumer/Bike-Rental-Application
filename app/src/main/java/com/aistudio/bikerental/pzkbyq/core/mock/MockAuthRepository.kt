package com.aistudio.bikerental.pzkbyq.core.mock

import com.aistudio.bikerental.pzkbyq.core.common.Result
import com.aistudio.bikerental.pzkbyq.features.auth.domain.AdminProfile
import com.aistudio.bikerental.pzkbyq.features.auth.domain.CustomerProfile
import kotlinx.coroutines.delay
import java.util.UUID
import javax.inject.Inject
import javax.inject.Singleton

sealed class Result<out T> {
    data class Success<T>(val data: T) : Result<T>()
    data class Error(val message: String) : Result<Nothing>()
}

@Singleton
class MockAuthRepository @Inject constructor() {
    
    // Hardcoded mock credentials for Admin
    private val adminEmail = "admin@bikerental.in"
    private val adminPassword = "Password123"

    suspend fun requestOtp(phoneNumber: String): Result<Boolean> {
        delay(1500) // Simulate network latency
        if (phoneNumber.length != 10) {
            return Result.Error("Invalid phone number")
        }
        return Result.Success(true)
    }

    suspend fun verifyOtp(phoneNumber: String, otp: String): Result<CustomerProfile> {
        delay(1500)
        // Mock validation: accept '1234' or '000000' (depending on 4 or 6 digit UI)
        if (otp == "1234" || otp == "000000") {
            return Result.Success(
                CustomerProfile(
                    uuid = UUID.randomUUID().toString(),
                    name = "Mock Customer",
                    phone = "+91 $phoneNumber",
                    email = "customer@example.com",
                    address = "123, MG Road, Bangalore"
                )
            )
        }
        return Result.Error("Invalid OTP")
    }

    suspend fun loginAdmin(email: String, password: String): Result<AdminProfile> {
        delay(2000)
        if (email == adminEmail && password == adminPassword) {
            return Result.Success(
                AdminProfile(
                    uuid = UUID.randomUUID().toString(),
                    name = "Admin User",
                    email = email,
                    phone = "+91 9999999999",
                    businessName = "Premium Rentals",
                    role = "Fleet Owner"
                )
            )
        }
        return Result.Error("Invalid credentials")
    }
}
