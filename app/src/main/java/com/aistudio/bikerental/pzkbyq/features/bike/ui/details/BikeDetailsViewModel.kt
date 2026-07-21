package com.aistudio.bikerental.pzkbyq.features.bike.ui.details

import androidx.lifecycle.SavedStateHandle
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

@HiltViewModel
class BikeDetailsViewModel @Inject constructor(
    private val bikeRepository: BikeRepository,
    savedStateHandle: SavedStateHandle
) : ViewModel() {

    private val bikeId: String = checkNotNull(savedStateHandle["bikeId"])

    private val _uiState = MutableStateFlow<UiState<BikeModel>>(UiState.Loading)
    val uiState: StateFlow<UiState<BikeModel>> = _uiState.asStateFlow()

    init {
        loadBikeDetails()
    }

    private fun loadBikeDetails() {
        viewModelScope.launch {
            _uiState.value = UiState.Loading
            when (val result = bikeRepository.getBikeById(bikeId)) {
                is Result.Success -> _uiState.value = UiState.Success(result.data)
                is Result.Error -> _uiState.value = UiState.Error(result.message)
            }
        }
    }
}
