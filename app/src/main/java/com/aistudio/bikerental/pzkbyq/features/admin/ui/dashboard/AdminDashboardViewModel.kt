package com.aistudio.bikerental.pzkbyq.features.admin.ui.dashboard

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.aistudio.bikerental.pzkbyq.core.common.Result
import com.aistudio.bikerental.pzkbyq.core.common.UiState
import com.aistudio.bikerental.pzkbyq.features.admin.domain.AdminDashboardMetrics
import com.aistudio.bikerental.pzkbyq.features.admin.domain.AdminRepository
import com.aistudio.bikerental.pzkbyq.features.booking.domain.BookingModel
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

data class DashboardState(
    val metrics: AdminDashboardMetrics,
    val recentActivity: List<BookingModel>
)

@HiltViewModel
class AdminDashboardViewModel @Inject constructor(
    private val adminRepository: AdminRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow<UiState<DashboardState>>(UiState.Loading)
    val uiState: StateFlow<UiState<DashboardState>> = _uiState.asStateFlow()

    init {
        loadDashboard()
    }

    fun loadDashboard() {
        viewModelScope.launch {
            _uiState.value = UiState.Loading
            val metricsResult = adminRepository.getDashboardMetrics()
            val activityResult = adminRepository.getRecentActivity()

            if (metricsResult is Result.Success && activityResult is Result.Success) {
                _uiState.value = UiState.Success(
                    DashboardState(
                        metrics = metricsResult.data,
                        recentActivity = activityResult.data
                    )
                )
            } else {
                _uiState.value = UiState.Error("Failed to load dashboard")
            }
        }
    }
}
