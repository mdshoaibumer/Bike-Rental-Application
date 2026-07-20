package com.aistudio.bikerental.pzkbyq.features.admin.domain

import com.aistudio.bikerental.pzkbyq.core.common.Result
import com.aistudio.bikerental.pzkbyq.core.mock.MockDataProvider
import com.aistudio.bikerental.pzkbyq.features.auth.domain.CustomerProfile
import com.aistudio.bikerental.pzkbyq.features.bike.domain.BikeModel
import com.aistudio.bikerental.pzkbyq.features.bike.domain.BikeStatus
import com.aistudio.bikerental.pzkbyq.features.booking.domain.BookingModel
import com.aistudio.bikerental.pzkbyq.features.booking.domain.BookingStatus
import kotlinx.coroutines.delay
import java.util.UUID
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class MockAdminRepositoryImpl @Inject constructor() : AdminRepository {

    private val mockBikes = MockDataProvider.bikes.toMutableList()
    private val mockBookings = mutableListOf<BookingModel>()
    private val mockCustomers = mutableListOf<CustomerProfile>()

    init {
        generateMockData()
    }

    private fun generateMockData() {
        // Generate 60 customers
        for (i in 1..60) {
            mockCustomers.add(
                CustomerProfile(
                    uuid = UUID.randomUUID().toString(),
                    name = "Customer $i",
                    phone = "+91 98765${String.format("%04d", i)}",
                    email = "customer$i@example.com",
                    address = "$i, Random Street, India",
                    drivingLicenseNumber = "DL14${String.format("%04d", i)}"
                )
            )
        }

        // Generate 100 bookings
        val statuses = BookingStatus.values()
        for (i in 1..100) {
            val bike = mockBikes[i % mockBikes.size]
            val customer = mockCustomers[i % mockCustomers.size]
            val status = statuses[i % statuses.size]
            
            mockBookings.add(
                BookingModel(
                    bookingId = "BK2026${String.format("%05d", i)}",
                    customerId = customer.uuid,
                    bikeId = bike.uuid,
                    customerName = customer.name,
                    bikeName = bike.name,
                    pickupDate = "10/08/2026",
                    returnDate = "12/08/2026",
                    pickupTime = "10:00 AM",
                    returnTime = "10:00 AM",
                    rentalDays = 2,
                    rentalAmount = bike.rentalPrice * 2,
                    securityDeposit = bike.securityDeposit,
                    totalAmount = (bike.rentalPrice * 2) + bike.securityDeposit,
                    status = status,
                    createdDate = "01/08/2026",
                    updatedDate = "01/08/2026"
                )
            )
        }
    }

    override suspend fun getDashboardMetrics(): Result<AdminDashboardMetrics> {
        delay(800)
        val pending = mockBookings.count { it.status == BookingStatus.PENDING_APPROVAL }
        val active = mockBookings.count { it.status == BookingStatus.ACTIVE }
        val available = mockBikes.count { it.status == BikeStatus.AVAILABLE }
        val maintenance = mockBikes.count { it.status == BikeStatus.MAINTENANCE }
        
        // Mock revenue calculation (sum of completed/active total amounts)
        val revenue = mockBookings.filter { it.status == BookingStatus.COMPLETED || it.status == BookingStatus.ACTIVE }
            .sumOf { it.totalAmount }

        return Result.Success(
            AdminDashboardMetrics(
                todaysRevenue = revenue,
                pendingApprovals = pending,
                activeRentals = active,
                availableBikes = available,
                maintenanceBikes = maintenance
            )
        )
    }

    override suspend fun getRecentActivity(): Result<List<BookingModel>> {
        delay(500)
        return Result.Success(mockBookings.takeLast(10).reversed())
    }

    override suspend fun getAllBikes(): Result<List<BikeModel>> {
        delay(1000)
        return Result.Success(mockBikes.toList())
    }

    override suspend fun addBike(bike: BikeModel): Result<Boolean> {
        delay(800)
        mockBikes.add(bike)
        return Result.Success(true)
    }

    override suspend fun updateBike(bike: BikeModel): Result<Boolean> {
        delay(800)
        val index = mockBikes.indexOfFirst { it.uuid == bike.uuid }
        if (index != -1) {
            mockBikes[index] = bike
            return Result.Success(true)
        }
        return Result.Error("Bike not found")
    }

    override suspend fun deleteBike(bikeId: String): Result<Boolean> {
        delay(800)
        val removed = mockBikes.removeIf { it.uuid == bikeId }
        return if (removed) Result.Success(true) else Result.Error("Bike not found")
    }

    override suspend fun getAllBookings(): Result<List<BookingModel>> {
        delay(1000)
        return Result.Success(mockBookings.reversed())
    }

    override suspend fun updateBookingStatus(bookingId: String, newStatus: BookingStatus): Result<Boolean> {
        delay(800)
        val index = mockBookings.indexOfFirst { it.bookingId == bookingId }
        if (index != -1) {
            mockBookings[index] = mockBookings[index].copy(status = newStatus)
            return Result.Success(true)
        }
        return Result.Error("Booking not found")
    }

    override suspend fun getAllCustomers(): Result<List<CustomerProfile>> {
        delay(1000)
        return Result.Success(mockCustomers.toList())
    }

    override suspend fun getCustomerById(uuid: String): Result<CustomerProfile> {
        delay(500)
        val customer = mockCustomers.find { it.uuid == uuid }
        return if (customer != null) Result.Success(customer) else Result.Error("Customer not found")
    }
}
