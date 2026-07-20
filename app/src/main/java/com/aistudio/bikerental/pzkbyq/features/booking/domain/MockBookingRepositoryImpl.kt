package com.aistudio.bikerental.pzkbyq.features.booking.domain

import com.aistudio.bikerental.pzkbyq.core.common.Result
import com.aistudio.bikerental.pzkbyq.core.mock.MockDataProvider
import kotlinx.coroutines.delay
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class MockBookingRepositoryImpl @Inject constructor() : BookingRepository {

    private val mockBookings = mutableListOf<BookingModel>()
    private var bookingCounter = 1

    init {
        generateMockBookings()
    }

    private fun generateMockBookings() {
        val statuses = BookingStatus.values()
        val bikes = MockDataProvider.bikes
        
        for (i in 1..40) {
            val bike = bikes[i % bikes.size]
            val status = statuses[i % statuses.size]
            
            mockBookings.add(
                BookingModel(
                    bookingId = generateBookingId(),
                    customerId = "mock-customer-uuid",
                    bikeId = bike.uuid,
                    customerName = "Mock Customer",
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

    private fun generateBookingId(): String {
        val id = "BK2026${String.format("%05d", bookingCounter)}"
        bookingCounter++
        return id
    }

    override suspend fun createBooking(
        customerId: String,
        bikeId: String,
        pickupDate: String,
        returnDate: String,
        pickupTime: String,
        returnTime: String
    ): Result<BookingModel> {
        delay(1500) // Mock latency

        // Simplified mock validation
        if (pickupDate.isBlank() || returnDate.isBlank()) {
            return Result.Error("Dates cannot be empty")
        }

        // Mock overlapping validation (simplified)
        val hasOverlap = mockBookings.any { 
            it.bikeId == bikeId && 
            (it.status == BookingStatus.ACTIVE || it.status == BookingStatus.APPROVED) &&
            it.pickupDate == pickupDate 
        }

        if (hasOverlap) {
            return Result.Error("Bike is not available for selected dates")
        }

        val bike = MockDataProvider.bikes.find { it.uuid == bikeId } ?: return Result.Error("Bike not found")

        // Mock Days Calculation (using 1 day for simplicity in MVP)
        val rentalDays = 1 

        val newBooking = BookingModel(
            bookingId = generateBookingId(),
            customerId = customerId,
            bikeId = bikeId,
            customerName = "Current User",
            bikeName = bike.name,
            pickupDate = pickupDate,
            returnDate = returnDate,
            pickupTime = pickupTime,
            returnTime = returnTime,
            rentalDays = rentalDays,
            rentalAmount = bike.rentalPrice * rentalDays,
            securityDeposit = bike.securityDeposit,
            totalAmount = (bike.rentalPrice * rentalDays) + bike.securityDeposit,
            status = BookingStatus.PENDING_APPROVAL,
            createdDate = SimpleDateFormat("dd/MM/yyyy", Locale.getDefault()).format(Date()),
            updatedDate = SimpleDateFormat("dd/MM/yyyy", Locale.getDefault()).format(Date())
        )

        mockBookings.add(newBooking)
        return Result.Success(newBooking)
    }

    override suspend fun getCustomerBookings(customerId: String): Result<List<BookingModel>> {
        delay(1000)
        // In mock, return all bookings to show history easily
        return Result.Success(mockBookings.reversed()) 
    }

    override suspend fun getBookingById(bookingId: String): Result<BookingModel> {
        delay(500)
        val booking = mockBookings.find { it.bookingId == bookingId }
        return if (booking != null) Result.Success(booking) else Result.Error("Booking not found")
    }

    override suspend fun cancelBooking(bookingId: String): Result<Boolean> {
        delay(1000)
        val index = mockBookings.indexOfFirst { it.bookingId == bookingId }
        if (index != -1) {
            val booking = mockBookings[index]
            if (booking.status == BookingStatus.PENDING_APPROVAL) {
                mockBookings[index] = booking.copy(status = BookingStatus.CANCELLED)
                return Result.Success(true)
            }
            return Result.Error("Only pending bookings can be cancelled")
        }
        return Result.Error("Booking not found")
    }
}
