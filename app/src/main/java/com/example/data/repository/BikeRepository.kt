package com.example.data.repository

import com.example.data.db.*
import com.example.data.model.*
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.flow
import java.util.UUID
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

class BikeRepository(private val db: AppDatabase) {

    private val userDao = db.userDao()
    private val bikeDao = db.bikeDao()
    private val bookingDao = db.bookingDao()
    private val notificationDao = db.notificationDao()
    private val settingDao = db.settingDao()

    // Flows for UI updates
    val allBikes: Flow<List<BikeEntity>> = bikeDao.getAllBikes()
    val allBookings: Flow<List<BookingEntity>> = bookingDao.getAllBookings()
    val allCustomers: Flow<List<UserEntity>> = userDao.getAllCustomers()

    // Get count reactively
    val bikesCount: Flow<Int> = bikeDao.getBikesCount()

    init {
        // Seed initial mock data in a background coroutine
        // This runs once when the app is instantiated
    }

    suspend fun seedInitialDataIfEmpty() {
        withContext(Dispatchers.IO) {
            val bikesList = bikeDao.getAllBikes().first()
            if (bikesList.isEmpty()) {
                // Seed Owners
                val owner = UserEntity(
                    id = "owner-uuid-1",
                    name = "Alice Owner",
                    email = "owner@bikerental.com",
                    phone = "9999999999",
                    role = "Owner",
                    avatarUrl = "https://images.unsplash.com/photo-1494790108377-be9c29b29330"
                )
                userDao.insertUser(owner)

                // Seed Default Customer
                val customer = UserEntity(
                    id = "customer-uuid-1",
                    name = "Bob Rider",
                    email = "bob.rider@bikerental.com",
                    phone = "1234567890",
                    role = "Customer",
                    avatarUrl = "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde"
                )
                userDao.insertUser(customer)

                // Seed Bikes
                val initialBikes = listOf(
                    BikeEntity(
                        id = UUID.randomUUID().toString(),
                        name = "Volt Flyer E-100",
                        model = "VeloVolt 2026",
                        category = "Electric",
                        chargePerHour = 12.50,
                        location = "Central Park Terminal",
                        imageType = "electric",
                        isAvailable = true,
                        batteryPercent = 94,
                        rangeKm = 95,
                        ownerId = "owner-uuid-1"
                    ),
                    BikeEntity(
                        id = UUID.randomUUID().toString(),
                        name = "AeroGlide S-9",
                        model = "Specialized Road",
                        category = "Road",
                        chargePerHour = 8.00,
                        location = "Hudson River Pier",
                        imageType = "road",
                        isAvailable = true,
                        batteryPercent = 0, // No battery for non-electric
                        rangeKm = 0,
                        ownerId = "owner-uuid-1"
                    ),
                    BikeEntity(
                        id = UUID.randomUUID().toString(),
                        name = "Summit Boulder MTX",
                        model = "Trek Trail",
                        category = "Mountain",
                        chargePerHour = 10.00,
                        location = "Prospect Park Forest",
                        imageType = "mountain",
                        isAvailable = true,
                        batteryPercent = 0,
                        rangeKm = 0,
                        ownerId = "owner-uuid-1"
                    ),
                    BikeEntity(
                        id = UUID.randomUUID().toString(),
                        name = "Breeze Coastal Pro",
                        model = "Schwinn Cruiser",
                        category = "Cruiser",
                        chargePerHour = 6.50,
                        location = "Coney Island Boardwalk",
                        imageType = "cruiser",
                        isAvailable = true,
                        batteryPercent = 0,
                        rangeKm = 0,
                        ownerId = "owner-uuid-1"
                    ),
                    BikeEntity(
                        id = UUID.randomUUID().toString(),
                        name = "Volt Cruiser Elite",
                        model = "Super73 E-Cruiser",
                        category = "Electric",
                        chargePerHour = 15.00,
                        location = "Times Square Hub",
                        imageType = "electric",
                        isAvailable = true,
                        batteryPercent = 82,
                        rangeKm = 75,
                        ownerId = "owner-uuid-1"
                    )
                )

                for (bike in initialBikes) {
                    bikeDao.insertBike(bike)
                }

                // Add pre-seed settings
                settingDao.insertSetting(SettingEntity("base_deposit", "50.0"))
                settingDao.insertSetting(SettingEntity("terms_accepted", "true"))

                // Preseed some historic bookings
                val historicBooking = BookingEntity(
                    id = UUID.randomUUID().toString(),
                    userId = "customer-uuid-1",
                    bikeId = initialBikes[1].id,
                    startTime = System.currentTimeMillis() - 86400000 * 2, // 2 days ago
                    endTime = System.currentTimeMillis() - 86400000 * 2 + 7200000, // +2 hours
                    totalCost = 16.00,
                    status = "Completed"
                )
                bookingDao.insertBooking(historicBooking)

                // Add historic notification
                notificationDao.insertNotification(
                    NotificationEntity(
                        id = UUID.randomUUID().toString(),
                        userId = "customer-uuid-1",
                        title = "Welcome to Bike Rental!",
                        message = "You can browse and book premium bikes near you in New York City.",
                        timestamp = System.currentTimeMillis() - 86400000 * 2
                    )
                )
            }
        }
    }

    // USER SERVICES
    suspend fun getUserByPhone(phone: String): UserEntity? {
        return withContext(Dispatchers.IO) {
            userDao.getUserByPhone(phone)
        }
    }

    suspend fun createCustomer(name: String, email: String, phone: String): UserEntity {
        return withContext(Dispatchers.IO) {
            val newUser = UserEntity(
                id = UUID.randomUUID().toString(),
                name = name,
                email = email,
                phone = phone,
                role = "Customer"
            )
            userDao.insertUser(newUser)
            newUser
        }
    }

    suspend fun updateUserProfile(user: UserEntity) {
        withContext(Dispatchers.IO) {
            userDao.updateUser(user)
        }
    }

    fun observeUser(userId: String): Flow<UserEntity?> {
        return userDao.getUserById(userId)
    }

    // BIKE SERVICES
    fun getBikesByCategory(category: String): Flow<List<BikeEntity>> {
        return if (category == "All") allBikes else bikeDao.getBikesByCategory(category)
    }

    fun getBikeById(id: String): Flow<BikeEntity?> {
        return bikeDao.getBikeById(id)
    }

    suspend fun addBike(name: String, model: String, category: String, chargePerHour: Double, location: String, imageType: String) {
        withContext(Dispatchers.IO) {
            val newBike = BikeEntity(
                id = UUID.randomUUID().toString(),
                name = name,
                model = model,
                category = category,
                chargePerHour = chargePerHour,
                location = location,
                imageType = imageType,
                isAvailable = true,
                batteryPercent = if (category == "Electric") 100 else 0,
                rangeKm = if (category == "Electric") 85 else 0,
                ownerId = "owner-uuid-1"
            )
            bikeDao.insertBike(newBike)
        }
    }

    suspend fun updateBikeDetails(bike: BikeEntity) {
        withContext(Dispatchers.IO) {
            bikeDao.updateBike(bike)
        }
    }

    suspend fun removeBike(id: String) {
        withContext(Dispatchers.IO) {
            bikeDao.deleteBikeById(id)
        }
    }

    // BOOKING SERVICES
    fun getBookingsForUser(userId: String): Flow<List<BookingEntity>> {
        return bookingDao.getBookingsByUserId(userId)
    }

    fun getActiveBooking(userId: String): Flow<BookingEntity?> {
        return bookingDao.getActiveBookingByUserId(userId)
    }

    suspend fun bookBike(userId: String, bikeId: String, hours: Int): BookingEntity? {
        return withContext(Dispatchers.IO) {
            val bike = bikeDao.getBikeById(bikeId).first()
            if (bike != null && bike.isAvailable) {
                // Update bike availability
                val updatedBike = bike.copy(isAvailable = false)
                bikeDao.updateBike(updatedBike)

                // Generate booking
                val startTime = System.currentTimeMillis()
                val endTime = startTime + (hours * 3600000L)
                val totalCost = bike.chargePerHour * hours
                val booking = BookingEntity(
                    id = UUID.randomUUID().toString(),
                    userId = userId,
                    bikeId = bikeId,
                    startTime = startTime,
                    endTime = endTime,
                    totalCost = totalCost,
                    status = "Active"
                )
                bookingDao.insertBooking(booking)

                // Insert user notification
                notificationDao.insertNotification(
                    NotificationEntity(
                        id = UUID.randomUUID().toString(),
                        userId = userId,
                        title = "Booking Confirmed! 🚲",
                        message = "You have rented '${bike.name}' for $hours hours. Enjoy your ride!"
                    )
                )
                booking
            } else {
                null
            }
        }
    }

    suspend fun cancelActiveBooking(bookingId: String, userId: String) {
        withContext(Dispatchers.IO) {
            val booking = bookingDao.getBookingById(bookingId).first()
            if (booking != null && booking.status == "Active") {
                // Update booking status
                val updatedBooking = booking.copy(status = "Cancelled", endTime = System.currentTimeMillis())
                bookingDao.insertBooking(updatedBooking)

                // Restore bike availability
                val bike = bikeDao.getBikeById(booking.bikeId).first()
                if (bike != null) {
                    val updatedBike = bike.copy(isAvailable = true)
                    bikeDao.updateBike(updatedBike)
                }

                // Add notification
                notificationDao.insertNotification(
                    NotificationEntity(
                        id = UUID.randomUUID().toString(),
                        userId = userId,
                        title = "Ride Cancelled",
                        message = "Your booking for '${bike?.name ?: "Bike"}' was successfully cancelled. Refund processed."
                    )
                )
            }
        }
    }

    suspend fun completeActiveBooking(bookingId: String, userId: String) {
        withContext(Dispatchers.IO) {
            val booking = bookingDao.getBookingById(bookingId).first()
            if (booking != null && booking.status == "Active") {
                // Complete booking
                val endTime = System.currentTimeMillis()
                val durationMs = endTime - booking.startTime
                val durationHrs = Math.ceil(durationMs.toDouble() / 3600000.0).coerceAtLeast(1.0)
                
                val bike = bikeDao.getBikeById(booking.bikeId).first()
                val actualCost = (bike?.chargePerHour ?: booking.totalCost / 2) * durationHrs

                val updatedBooking = booking.copy(
                    status = "Completed",
                    endTime = endTime,
                    totalCost = actualCost
                )
                bookingDao.insertBooking(updatedBooking)

                // Restore bike
                if (bike != null) {
                    // Reduce battery as a fun simulation
                    val updatedBattery = if (bike.category == "Electric") {
                        (bike.batteryPercent - (durationHrs * 15).toInt()).coerceIn(10, 100)
                    } else {
                        0
                    }
                    val updatedBike = bike.copy(
                        isAvailable = true,
                        batteryPercent = updatedBattery,
                        rangeKm = if (bike.category == "Electric") (updatedBattery * 1.1).toInt() else 0
                    )
                    bikeDao.updateBike(updatedBike)
                }

                // Add notification
                notificationDao.insertNotification(
                    NotificationEntity(
                        id = UUID.randomUUID().toString(),
                        userId = userId,
                        title = "Ride Completed! 🎉",
                        message = "You rode '${bike?.name ?: "Bike"}' for ${String.format("%.1f", durationHrs)} hours. Total cost: \$${String.format("%.2f", actualCost)}."
                    )
                )
            }
        }
    }

    // NOTIFICATION SERVICES
    fun getNotificationsForUser(userId: String): Flow<List<NotificationEntity>> {
        return notificationDao.getNotificationsByUserId(userId)
    }

    suspend fun markNotificationRead(id: String) {
        withContext(Dispatchers.IO) {
            notificationDao.markAsRead(id)
        }
    }

    // ANALYTICS / REPORTS FOR OWNER/ADMIN
    fun getAnalyticsReport(): Flow<AnalyticsSummary> = flow {
        while(true) {
            val bikes = bikeDao.getAllBikes().first()
            val bookings = bookingDao.getAllBookings().first()
            val users = userDao.getAllCustomers().first()

            val activeBookings = bookings.filter { it.status == "Active" }
            val completedBookings = bookings.filter { it.status == "Completed" }
            val totalRevenue = completedBookings.sumOf { it.totalCost }

            val availableCount = bikes.count { it.isAvailable }
            val rentedCount = bikes.count { !it.isAvailable }

            // Category metrics
            val revenueByCategory = completedBookings.groupBy { booking ->
                bikes.find { it.id == booking.bikeId }?.category ?: "Other"
            }.mapValues { entry -> entry.value.sumOf { it.totalCost } }

            val popularBikeId = bookings.groupBy { it.bikeId }
                .maxByOrNull { it.value.size }?.key
            val popularBikeName = bikes.find { it.id == popularBikeId }?.name ?: "N/A"

            emit(
                AnalyticsSummary(
                    totalRevenue = totalRevenue,
                    activeBookingsCount = activeBookings.size,
                    totalBookingsCount = bookings.size,
                    availableFleet = availableCount,
                    rentedFleet = rentedCount,
                    totalUsers = users.size,
                    revenueByCategory = revenueByCategory,
                    popularBikeName = popularBikeName
                )
            )
            // Simulates real-time analytics updates
            kotlinx.coroutines.delay(10000)
        }
    }
}

data class AnalyticsSummary(
    val totalRevenue: Double,
    val activeBookingsCount: Int,
    val totalBookingsCount: Int,
    val availableFleet: Int,
    val rentedFleet: Int,
    val totalUsers: Int,
    val revenueByCategory: Map<String, Double>,
    val popularBikeName: String
)
