package com.aistudio.bikerental.pzkbyq.features.booking.domain

import com.aistudio.bikerental.pzkbyq.core.common.Result

interface BookingRepository {
    suspend fun createBooking(
        customerId: String,
        bikeId: String,
        pickupDate: String,
        returnDate: String,
        pickupTime: String,
        returnTime: String
    ): Result<BookingModel>

    suspend fun getCustomerBookings(customerId: String): Result<List<BookingModel>>
    
    suspend fun getBookingById(bookingId: String): Result<BookingModel>
    
    suspend fun cancelBooking(bookingId: String): Result<Boolean>
}
