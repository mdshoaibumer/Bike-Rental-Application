package com.aistudio.bikerental.pzkbyq.features.booking.ui.details

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.aistudio.bikerental.pzkbyq.core.common.Result
import com.aistudio.bikerental.pzkbyq.core.common.UiState
import com.aistudio.bikerental.pzkbyq.features.booking.domain.BookingModel
import com.aistudio.bikerental.pzkbyq.features.booking.domain.BookingRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class BookingDetailsViewModel @Inject constructor(
    private val bookingRepository: BookingRepository,
    savedStateHandle: SavedStateHandle
) : ViewModel() {

    private val bookingId: String = checkNotNull(savedStateHandle["bookingId"])

    private val _uiState = MutableStateFlow<UiState<BookingModel>>(UiState.Loading)
    val uiState: StateFlow<UiState<BookingModel>> = _uiState.asStateFlow()

    private val _cancelState = MutableStateFlow<UiState<Boolean>>(UiState.Success(false))
    val cancelState: StateFlow<UiState<Boolean>> = _cancelState.asStateFlow()

    init {
        loadBookingDetails()
    }

    fun loadBookingDetails() {
        viewModelScope.launch {
            _uiState.value = UiState.Loading
            when (val result = bookingRepository.getBookingById(bookingId)) {
                is Result.Success -> _uiState.value = UiState.Success(result.data)
                is Result.Error -> _uiState.value = UiState.Error(result.message)
            }
        }
    }

    fun cancelBooking() {
        viewModelScope.launch {
            _cancelState.value = UiState.Loading
            when (val result = bookingRepository.cancelBooking(bookingId)) {
                is Result.Success -> {
                    _cancelState.value = UiState.Success(true)
                    loadBookingDetails() // Reload to reflect cancelled state
                }
                is Result.Error -> _cancelState.value = UiState.Error(result.message)
            }
        }
    }
}
