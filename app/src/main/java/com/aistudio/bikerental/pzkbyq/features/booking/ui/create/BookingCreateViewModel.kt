package com.aistudio.bikerental.pzkbyq.features.booking.ui.create

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.aistudio.bikerental.pzkbyq.core.common.Result
import com.aistudio.bikerental.pzkbyq.core.common.UiState
import com.aistudio.bikerental.pzkbyq.features.bike.domain.BikeModel
import com.aistudio.bikerental.pzkbyq.features.bike.domain.BikeRepository
import com.aistudio.bikerental.pzkbyq.features.booking.domain.BookingModel
import com.aistudio.bikerental.pzkbyq.features.booking.domain.BookingRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class BookingCreateViewModel @Inject constructor(
    private val bikeRepository: BikeRepository,
    private val bookingRepository: BookingRepository,
    savedStateHandle: SavedStateHandle
) : ViewModel() {

    val bikeId: String = checkNotNull(savedStateHandle["bikeId"])

    private val _bikeState = MutableStateFlow<UiState<BikeModel>>(UiState.Loading)
    val bikeState: StateFlow<UiState<BikeModel>> = _bikeState.asStateFlow()

    private val _pickupDate = MutableStateFlow("")
    val pickupDate: StateFlow<String> = _pickupDate.asStateFlow()
    
    private val _returnDate = MutableStateFlow("")
    val returnDate: StateFlow<String> = _returnDate.asStateFlow()

    private val _pickupTime = MutableStateFlow("10:00 AM")
    val pickupTime: StateFlow<String> = _pickupTime.asStateFlow()
    
    private val _returnTime = MutableStateFlow("10:00 AM")
    val returnTime: StateFlow<String> = _returnTime.asStateFlow()

    private val _createState = MutableStateFlow<UiState<BookingModel>>(UiState.Success(null as BookingModel?))
    val createState: StateFlow<UiState<BookingModel>> = _createState.asStateFlow()

    init {
        loadBikeDetails()
    }

    private fun loadBikeDetails() {
        viewModelScope.launch {
            _bikeState.value = UiState.Loading
            when (val result = bikeRepository.getBikeById(bikeId)) {
                is Result.Success -> _bikeState.value = UiState.Success(result.data)
                is Result.Error -> _bikeState.value = UiState.Error(result.message)
            }
        }
    }

    fun updatePickupDate(date: String) { _pickupDate.value = date }
    fun updateReturnDate(date: String) { _returnDate.value = date }
    fun updatePickupTime(time: String) { _pickupTime.value = time }
    fun updateReturnTime(time: String) { _returnTime.value = time }

    fun confirmBooking(customerId: String) {
        viewModelScope.launch {
            _createState.value = UiState.Loading
            val result = bookingRepository.createBooking(
                customerId = customerId,
                bikeId = bikeId,
                pickupDate = _pickupDate.value,
                returnDate = _returnDate.value,
                pickupTime = _pickupTime.value,
                returnTime = _returnTime.value
            )
            when (result) {
                is Result.Success -> _createState.value = UiState.Success(result.data)
                is Result.Error -> _createState.value = UiState.Error(result.message)
            }
        }
    }

    fun resetCreateState() {
        _createState.value = UiState.Success(null as BookingModel?)
    }
}
