package com.aistudio.bikerental.pzkbyq.features.admin.ui.bookings

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.aistudio.bikerental.pzkbyq.core.common.Result
import com.aistudio.bikerental.pzkbyq.core.common.UiState
import com.aistudio.bikerental.pzkbyq.features.admin.domain.AdminRepository
import com.aistudio.bikerental.pzkbyq.features.booking.domain.BookingModel
import com.aistudio.bikerental.pzkbyq.features.booking.domain.BookingStatus
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class AdminBookingDetailsViewModel @Inject constructor(
    private val adminRepository: AdminRepository,
    savedStateHandle: SavedStateHandle
) : ViewModel() {

    private val bookingId: String = checkNotNull(savedStateHandle["bookingId"])

    private val _uiState = MutableStateFlow<UiState<BookingModel>>(UiState.Loading)
    val uiState: StateFlow<UiState<BookingModel>> = _uiState.asStateFlow()

    private val _actionState = MutableStateFlow<UiState<Boolean>>(UiState.Success(false))
    val actionState: StateFlow<UiState<Boolean>> = _actionState.asStateFlow()

    init {
        loadBookingDetails()
    }

    private fun loadBookingDetails() {
        viewModelScope.launch {
            _uiState.value = UiState.Loading
            when (val result = adminRepository.getAllBookings()) { // Reuse getAllBookings for mock filtering
                is Result.Success -> {
                    val booking = result.data.find { it.bookingId == bookingId }
                    if (booking != null) {
                        _uiState.value = UiState.Success(booking)
                    } else {
                        _uiState.value = UiState.Error("Booking not found")
                    }
                }
                is Result.Error -> _uiState.value = UiState.Error(result.message)
            }
        }
    }

    fun updateStatus(newStatus: BookingStatus) {
        viewModelScope.launch {
            _actionState.value = UiState.Loading
            when (val result = adminRepository.updateBookingStatus(bookingId, newStatus)) {
                is Result.Success -> {
                    _actionState.value = UiState.Success(true)
                    loadBookingDetails() // Reload to reflect changes
                }
                is Result.Error -> _actionState.value = UiState.Error(result.message)
            }
        }
    }
}
