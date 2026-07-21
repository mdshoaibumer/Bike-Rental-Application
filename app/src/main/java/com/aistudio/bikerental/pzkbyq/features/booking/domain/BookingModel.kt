package com.aistudio.bikerental.pzkbyq.features.booking.domain

import kotlinx.serialization.Serializable

@Serializable
data class BookingModel(
    val bookingId: String,
    val customerId: String,
    val bikeId: String,
    val customerName: String,
    val bikeName: String,
    val pickupDate: String, // ISO format or generic string for MVP
    val returnDate: String,
    val pickupTime: String,
    val returnTime: String,
    val rentalDays: Int,
    val rentalAmount: Int,
    val securityDeposit: Int,
    val totalAmount: Int,
    val status: BookingStatus,
    val createdDate: String,
    val updatedDate: String
)

enum class BookingStatus {
    PENDING_APPROVAL,
    APPROVED,
    REJECTED,
    READY_FOR_PICKUP,
    ACTIVE,
    COMPLETED,
    CANCELLED,
    EXPIRED
}
