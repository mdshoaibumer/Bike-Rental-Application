package com.example.data.model

import androidx.room.Entity
import androidx.room.PrimaryKey
import androidx.room.Index

@Entity(
    tableName = "users",
    indices = [Index(value = ["phone"], unique = true)]
)
data class UserEntity(
    @PrimaryKey val id: String,
    val name: String,
    val email: String,
    val phone: String,
    val role: String, // "Customer" or "Owner"
    val avatarUrl: String? = null
)

@Entity(tableName = "bikes")
data class BikeEntity(
    @PrimaryKey val id: String,
    val name: String,
    val model: String,
    val category: String, // "Electric", "Mountain", "Road", "Cruiser"
    val chargePerHour: Double,
    val location: String,
    val imageType: String, // "electric", "mountain", "road", "cruiser" (to draw dynamically or display custom vector icons)
    val isAvailable: Boolean = true,
    val batteryPercent: Int = 100,
    val rangeKm: Int = 80,
    val ownerId: String? = null
)

@Entity(
    tableName = "bookings",
    indices = [Index(value = ["userId"]), Index(value = ["bikeId"])]
)
data class BookingEntity(
    @PrimaryKey val id: String,
    val userId: String,
    val bikeId: String,
    val startTime: Long,
    val endTime: Long,
    val totalCost: Double,
    val status: String // "Active", "Completed", "Cancelled"
)

@Entity(
    tableName = "notifications",
    indices = [Index(value = ["userId"])]
)
data class NotificationEntity(
    @PrimaryKey val id: String,
    val userId: String,
    val title: String,
    val message: String,
    val timestamp: Long = System.currentTimeMillis(),
    val isRead: Boolean = false
)

@Entity(tableName = "settings")
data class SettingEntity(
    @PrimaryKey val key: String,
    val value: String
)
