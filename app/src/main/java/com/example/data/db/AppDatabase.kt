package com.example.data.db

import androidx.room.*
import com.example.data.model.*
import kotlinx.coroutines.flow.Flow

@Dao
interface UserDao {
    @Query("SELECT * FROM users WHERE id = :id")
    fun getUserById(id: String): Flow<UserEntity?>

    @Query("SELECT * FROM users WHERE phone = :phone LIMIT 1")
    suspend fun getUserByPhone(phone: String): UserEntity?

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertUser(user: UserEntity)

    @Update
    suspend fun updateUser(user: UserEntity)

    @Query("SELECT * FROM users WHERE role = 'Customer'")
    fun getAllCustomers(): Flow<List<UserEntity>>
}

@Dao
interface BikeDao {
    @Query("SELECT * FROM bikes")
    fun getAllBikes(): Flow<List<BikeEntity>>

    @Query("SELECT * FROM bikes WHERE category = :category")
    fun getBikesByCategory(category: String): Flow<List<BikeEntity>>

    @Query("SELECT * FROM bikes WHERE id = :id")
    fun getBikeById(id: String): Flow<BikeEntity?>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertBike(bike: BikeEntity)

    @Update
    suspend fun updateBike(bike: BikeEntity)

    @Delete
    suspend fun deleteBike(bike: BikeEntity)

    @Query("DELETE FROM bikes WHERE id = :id")
    suspend fun deleteBikeById(id: String)

    @Query("SELECT COUNT(*) FROM bikes")
    fun getBikesCount(): Flow<Int>
}

@Dao
interface BookingDao {
    @Query("SELECT * FROM bookings ORDER BY startTime DESC")
    fun getAllBookings(): Flow<List<BookingEntity>>

    @Query("SELECT * FROM bookings WHERE userId = :userId ORDER BY startTime DESC")
    fun getBookingsByUserId(userId: String): Flow<List<BookingEntity>>

    @Query("SELECT * FROM bookings WHERE userId = :userId AND status = 'Active' LIMIT 1")
    fun getActiveBookingByUserId(userId: String): Flow<BookingEntity?>

    @Query("SELECT * FROM bookings WHERE id = :id")
    fun getBookingById(id: String): Flow<BookingEntity?>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertBooking(booking: BookingEntity)

    @Update
    suspend fun updateBooking(booking: BookingEntity)
}

@Dao
interface NotificationDao {
    @Query("SELECT * FROM notifications WHERE userId = :userId ORDER BY timestamp DESC")
    fun getNotificationsByUserId(userId: String): Flow<List<NotificationEntity>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertNotification(notification: NotificationEntity)

    @Query("UPDATE notifications SET isRead = 1 WHERE id = :id")
    suspend fun markAsRead(id: String)
}

@Dao
interface SettingDao {
    @Query("SELECT * FROM settings WHERE `key` = :key LIMIT 1")
    fun getSetting(key: String): Flow<SettingEntity?>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertSetting(setting: SettingEntity)
}

@Database(
    entities = [
        UserEntity::class,
        BikeEntity::class,
        BookingEntity::class,
        NotificationEntity::class,
        SettingEntity::class
    ],
    version = 1,
    exportSchema = false
)
abstract class AppDatabase : RoomDatabase() {
    abstract fun userDao(): UserDao
    abstract fun bikeDao(): BikeDao
    abstract fun bookingDao(): BookingDao
    abstract fun notificationDao(): NotificationDao
    abstract fun settingDao(): SettingDao

    companion object {
        @Volatile
        private var INSTANCE: AppDatabase? = null

        fun getDatabase(context: android.content.Context): AppDatabase {
            return INSTANCE ?: synchronized(this) {
                val instance = Room.databaseBuilder(
                    context.applicationContext,
                    AppDatabase::class.java,
                    "bike_rental_db"
                )
                .fallbackToDestructiveMigration()
                .build()
                INSTANCE = instance
                instance
            }
        }
    }
}
