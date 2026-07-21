package com.aistudio.bikerental.pzkbyq.features.home.ui

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.aistudio.bikerental.pzkbyq.core.common.Result
import com.aistudio.bikerental.pzkbyq.core.common.UiState
import com.aistudio.bikerental.pzkbyq.features.bike.domain.BikeModel
import com.aistudio.bikerental.pzkbyq.features.bike.domain.BikeRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

data class HomeState(
    val featuredBikes: List<BikeModel> = emptyList(),
    val popularBikes: List<BikeModel> = emptyList(),
    val recentBikes: List<BikeModel> = emptyList()
)

@HiltViewModel
class HomeViewModel @Inject constructor(
    private val bikeRepository: BikeRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow<UiState<HomeState>>(UiState.Loading)
    val uiState: StateFlow<UiState<HomeState>> = _uiState.asStateFlow()

    private val _isRefreshing = MutableStateFlow(false)
    val isRefreshing: StateFlow<Boolean> = _isRefreshing.asStateFlow()

    init {
        loadHomeData()
    }

    fun loadHomeData() {
        viewModelScope.launch {
            _uiState.value = UiState.Loading
            fetchData()
        }
    }

    fun refreshData() {
        viewModelScope.launch {
            _isRefreshing.value = true
            fetchData()
            _isRefreshing.value = false
        }
    }

    private suspend fun fetchData() {
        val featuredResult = bikeRepository.getFeaturedBikes()
        val popularResult = bikeRepository.getPopularBikes()
        val recentResult = bikeRepository.getRecentlyAddedBikes()

        if (featuredResult is Result.Success && popularResult is Result.Success && recentResult is Result.Success) {
            _uiState.value = UiState.Success(
                HomeState(
                    featuredBikes = featuredResult.data,
                    popularBikes = popularResult.data,
                    recentBikes = recentResult.data
                )
            )
        } else {
            _uiState.value = UiState.Error("Failed to load home data")
        }
    }
}
