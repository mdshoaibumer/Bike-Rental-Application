package com.aistudio.bikerental.pzkbyq.features.admin.domain

import com.aistudio.bikerental.pzkbyq.core.common.Result
import com.aistudio.bikerental.pzkbyq.features.auth.domain.CustomerProfile
import com.aistudio.bikerental.pzkbyq.features.bike.domain.BikeModel
import com.aistudio.bikerental.pzkbyq.features.booking.domain.BookingModel
import com.aistudio.bikerental.pzkbyq.features.booking.domain.BookingStatus

data class AdminDashboardMetrics(
    val todaysRevenue: Int,
    val pendingApprovals: Int,
    val activeRentals: Int,
    val availableBikes: Int,
    val maintenanceBikes: Int
)

interface AdminRepository {
    // Dashboard
    suspend fun getDashboardMetrics(): Result<AdminDashboardMetrics>
    suspend fun getRecentActivity(): Result<List<BookingModel>>

    // Bike CRUD
    suspend fun getAllBikes(): Result<List<BikeModel>>
    suspend fun addBike(bike: BikeModel): Result<Boolean>
    suspend fun updateBike(bike: BikeModel): Result<Boolean>
    suspend fun deleteBike(bikeId: String): Result<Boolean>

    // Booking Operations
    suspend fun getAllBookings(): Result<List<BookingModel>>
    suspend fun updateBookingStatus(bookingId: String, newStatus: BookingStatus): Result<Boolean>

    // Customer Management
    suspend fun getAllCustomers(): Result<List<CustomerProfile>>
    suspend fun getCustomerById(uuid: String): Result<CustomerProfile>
}
