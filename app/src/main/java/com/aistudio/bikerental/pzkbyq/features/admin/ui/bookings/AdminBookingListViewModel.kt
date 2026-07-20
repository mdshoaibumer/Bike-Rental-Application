package com.aistudio.bikerental.pzkbyq.features.admin.ui.bookings

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.aistudio.bikerental.pzkbyq.core.common.Result
import com.aistudio.bikerental.pzkbyq.core.common.UiState
import com.aistudio.bikerental.pzkbyq.features.admin.domain.AdminRepository
import com.aistudio.bikerental.pzkbyq.features.booking.domain.BookingModel
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class AdminBookingListViewModel @Inject constructor(
    private val adminRepository: AdminRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow<UiState<List<BookingModel>>>(UiState.Loading)
    val uiState: StateFlow<UiState<List<BookingModel>>> = _uiState.asStateFlow()

    init {
        loadBookings()
    }

    fun loadBookings() {
        viewModelScope.launch {
            _uiState.value = UiState.Loading
            when (val result = adminRepository.getAllBookings()) {
                is Result.Success -> _uiState.value = UiState.Success(result.data)
                is Result.Error -> _uiState.value = UiState.Error(result.message)
            }
        }
    }
}
