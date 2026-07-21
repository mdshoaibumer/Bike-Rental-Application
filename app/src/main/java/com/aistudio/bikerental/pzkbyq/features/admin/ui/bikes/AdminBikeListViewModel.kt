package com.aistudio.bikerental.pzkbyq.features.admin.ui.bikes

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.aistudio.bikerental.pzkbyq.core.common.Result
import com.aistudio.bikerental.pzkbyq.core.common.UiState
import com.aistudio.bikerental.pzkbyq.features.admin.domain.AdminRepository
import com.aistudio.bikerental.pzkbyq.features.bike.domain.BikeModel
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class AdminBikeListViewModel @Inject constructor(
    private val adminRepository: AdminRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow<UiState<List<BikeModel>>>(UiState.Loading)
    val uiState: StateFlow<UiState<List<BikeModel>>> = _uiState.asStateFlow()

    init {
        loadBikes()
    }

    fun loadBikes() {
        viewModelScope.launch {
            _uiState.value = UiState.Loading
            when (val result = adminRepository.getAllBikes()) {
                is Result.Success -> _uiState.value = UiState.Success(result.data)
                is Result.Error -> _uiState.value = UiState.Error(result.message)
            }
        }
    }
}
