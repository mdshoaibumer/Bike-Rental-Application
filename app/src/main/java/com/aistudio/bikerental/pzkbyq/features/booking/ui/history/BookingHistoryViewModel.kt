package com.aistudio.bikerental.pzkbyq.features.booking.ui.history

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.aistudio.bikerental.pzkbyq.core.common.Result
import com.aistudio.bikerental.pzkbyq.core.common.UiState
import com.aistudio.bikerental.pzkbyq.features.booking.domain.BookingModel
import com.aistudio.bikerental.pzkbyq.features.booking.domain.BookingRepository
import com.aistudio.bikerental.pzkbyq.features.booking.domain.BookingStatus
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

enum class BookingFilterTab { UPCOMING, ACTIVE, COMPLETED, CANCELLED }

@HiltViewModel
class BookingHistoryViewModel @Inject constructor(
    private val bookingRepository: BookingRepository
) : ViewModel() {

    private var allBookings = listOf<BookingModel>()

    private val _uiState = MutableStateFlow<UiState<List<BookingModel>>>(UiState.Loading)
    val uiState: StateFlow<UiState<List<BookingModel>>> = _uiState.asStateFlow()

    private val _selectedTab = MutableStateFlow(BookingFilterTab.UPCOMING)
    val selectedTab: StateFlow<BookingFilterTab> = _selectedTab.asStateFlow()

    init {
        loadBookings()
    }

    fun loadBookings() {
        viewModelScope.launch {
            _uiState.value = UiState.Loading
            when (val result = bookingRepository.getCustomerBookings("mock-customer-uuid")) {
                is Result.Success -> {
                    allBookings = result.data
                    applyFilter(_selectedTab.value)
                }
                is Result.Error -> _uiState.value = UiState.Error(result.message)
            }
        }
    }

    fun setTab(tab: BookingFilterTab) {
        _selectedTab.value = tab
        applyFilter(tab)
    }

    private fun applyFilter(tab: BookingFilterTab) {
        val filtered = when (tab) {
            BookingFilterTab.UPCOMING -> allBookings.filter { it.status == BookingStatus.PENDING_APPROVAL || it.status == BookingStatus.APPROVED || it.status == BookingStatus.READY_FOR_PICKUP }
            BookingFilterTab.ACTIVE -> allBookings.filter { it.status == BookingStatus.ACTIVE }
            BookingFilterTab.COMPLETED -> allBookings.filter { it.status == BookingStatus.COMPLETED }
            BookingFilterTab.CANCELLED -> allBookings.filter { it.status == BookingStatus.CANCELLED || it.status == BookingStatus.REJECTED || it.status == BookingStatus.EXPIRED }
        }
        _uiState.value = UiState.Success(filtered)
    }
}
