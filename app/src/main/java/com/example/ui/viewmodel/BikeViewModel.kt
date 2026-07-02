package com.example.ui.viewmodel

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.example.data.db.AppDatabase
import com.example.data.model.*
import com.example.data.repository.*
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import java.util.UUID

class BikeViewModel(
    application: Application,
    private val repository: BikeRepository
) : AndroidViewModel(application) {

    // Auth State
    private val _currentUser = MutableStateFlow<UserEntity?>(null)
    val currentUser: StateFlow<UserEntity?> = _currentUser.asStateFlow()

    private val _isOtpSent = MutableStateFlow(false)
    val isOtpSent: StateFlow<Boolean> = _isOtpSent.asStateFlow()

    private val _authError = MutableStateFlow<String?>(null)
    val authError: StateFlow<String?> = _authError.asStateFlow()

    // Filters and Search
    private val _selectedCategory = MutableStateFlow("All")
    val selectedCategory: StateFlow<String> = _selectedCategory.asStateFlow()

    private val _searchQuery = MutableStateFlow("")
    val searchQuery: StateFlow<String> = _searchQuery.asStateFlow()

    // List of available bikes (reactive filter)
    val filteredBikes: StateFlow<List<BikeEntity>> = combine(
        repository.allBikes,
        _selectedCategory,
        _searchQuery
    ) { bikes, category, query ->
        bikes.filter { bike ->
            val matchesCategory = (category == "All" || bike.category.equals(category, ignoreCase = true))
            val matchesSearch = bike.name.contains(query, ignoreCase = true) ||
                    bike.model.contains(query, ignoreCase = true) ||
                    bike.location.contains(query, ignoreCase = true)
            matchesCategory && matchesSearch
        }
    }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), emptyList())

    // Selected Bike Details
    private val _selectedBikeId = MutableStateFlow<String?>(null)
    val selectedBike: StateFlow<BikeEntity?> = _selectedBikeId.flatMapLatest { id ->
        if (id != null) repository.getBikeById(id) else flowOf(null)
    }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), null)

    // Current Active Booking for the logged-in User
    val activeBooking: StateFlow<BookingEntity?> = _currentUser.flatMapLatest { user ->
        if (user != null) repository.getActiveBooking(user.id) else flowOf(null)
    }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), null)

    // Bookings history for the logged in User
    val userBookings: StateFlow<List<BookingEntity>> = _currentUser.flatMapLatest { user ->
        if (user != null) repository.getBookingsForUser(user.id) else flowOf(emptyList())
    }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), emptyList())

    // All notifications for the current User
    val userNotifications: StateFlow<List<NotificationEntity>> = _currentUser.flatMapLatest { user ->
        if (user != null) repository.getNotificationsForUser(user.id) else flowOf(emptyList())
    }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), emptyList())

    // Owner specific: Analytics summary
    val analyticsSummary: StateFlow<AnalyticsSummary?> = repository.getAnalyticsReport()
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), null)

    // Owner specific: All bikes
    val allBikes: StateFlow<List<BikeEntity>> = repository.allBikes
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), emptyList())

    // Owner specific: All bookings
    val allBookings: StateFlow<List<BookingEntity>> = repository.allBookings
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), emptyList())

    // Owner specific: Customer base
    val allCustomers: StateFlow<List<UserEntity>> = repository.allCustomers
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), emptyList())

    init {
        viewModelScope.launch {
            // Populate database if it's currently empty
            repository.seedInitialDataIfEmpty()
        }
    }

    // AUTH ACTIONS
    fun initiateLogin(phone: String) {
        viewModelScope.launch {
            _authError.value = null
            if (phone.length < 10) {
                _authError.value = "Please enter a valid 10-digit mobile number."
                return@launch
            }
            // Simulates SMS gateway transmitting an OTP code
            _isOtpSent.value = true
        }
    }

    fun verifyOtp(phone: String, otpCode: String) {
        viewModelScope.launch {
            _authError.value = null
            if (otpCode != "1234") { // For demo/simulated convenience
                _authError.value = "Incorrect OTP. Please use '1234' for verification."
                return@launch
            }

            val existingUser = repository.getUserByPhone(phone)
            if (existingUser != null) {
                _currentUser.value = existingUser
            } else {
                // Auto-register as Customer for new numbers
                val emailName = phone.takeLast(4)
                val newUser = repository.createCustomer(
                    name = "Rider $emailName",
                    email = "rider.$emailName@bikerental.com",
                    phone = phone
                )
                _currentUser.value = newUser
            }
            _isOtpSent.value = false
        }
    }

    fun loginAsOwnerDirectly() {
        viewModelScope.launch {
            _authError.value = null
            val ownerUser = repository.getUserByPhone("9999999999")
            if (ownerUser != null) {
                _currentUser.value = ownerUser
            }
        }
    }

    fun logout() {
        _currentUser.value = null
        _isOtpSent.value = false
        _authError.value = null
    }

    // SEARCH & FILTER ACTIONS
    fun selectCategory(category: String) {
        _selectedCategory.value = category
    }

    fun updateSearchQuery(query: String) {
        _searchQuery.value = query
    }

    fun viewBikeDetails(bikeId: String?) {
        _selectedBikeId.value = bikeId
    }

    // BIKE BOOKING ACTIONS
    fun rentSelectedBike(hours: Int, onSuccess: () -> Unit, onError: (String) -> Unit) {
        val user = _currentUser.value ?: return
        val bike = selectedBike.value ?: return

        viewModelScope.launch {
            val booking = repository.bookBike(user.id, bike.id, hours)
            if (booking != null) {
                onSuccess()
            } else {
                onError("This bike is no longer available.")
            }
        }
    }

    fun cancelActiveRental(bookingId: String) {
        val user = _currentUser.value ?: return
        viewModelScope.launch {
            repository.cancelActiveBooking(bookingId, user.id)
        }
    }

    fun completeActiveRental(bookingId: String) {
        val user = _currentUser.value ?: return
        viewModelScope.launch {
            repository.completeActiveBooking(bookingId, user.id)
        }
    }

    // NOTIFICATION ACTIONS
    fun markNotificationAsRead(id: String) {
        viewModelScope.launch {
            repository.markNotificationRead(id)
        }
    }

    // PROFILE ACTIONS
    fun updateProfile(name: String, email: String) {
        val user = _currentUser.value ?: return
        viewModelScope.launch {
            val updatedUser = user.copy(name = name, email = email)
            repository.updateUserProfile(updatedUser)
            _currentUser.value = updatedUser
        }
    }

    // OWNER ACTIONS (FLEET MANAGEMENT)
    fun addNewBike(name: String, model: String, category: String, chargePerHour: Double, location: String, imageType: String) {
        viewModelScope.launch {
            repository.addBike(name, model, category, chargePerHour, location, imageType)
        }
    }

    fun editBike(bike: BikeEntity) {
        viewModelScope.launch {
            repository.updateBikeDetails(bike)
        }
    }

    fun deleteBike(bikeId: String) {
        viewModelScope.launch {
            repository.removeBike(bikeId)
        }
    }
}

// ViewModel Factory to properly instantiate database in a clean manner
class BikeViewModelFactory(private val application: Application) : ViewModelProvider.Factory {
    override fun <T : ViewModel> create(modelClass: Class<T>): T {
        if (modelClass.isAssignableFrom(BikeViewModel::class.java)) {
            val db = AppDatabase.getDatabase(application)
            val repository = BikeRepository(db)
            @Suppress("UNCHECKED_CAST")
            return BikeViewModel(application, repository) as T
        }
        throw IllegalArgumentException("Unknown ViewModel class")
    }
}
