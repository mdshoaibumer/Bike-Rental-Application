package com.aistudio.bikerental.pzkbyq.features.admin.ui.customers

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.aistudio.bikerental.pzkbyq.core.common.Result
import com.aistudio.bikerental.pzkbyq.core.common.UiState
import com.aistudio.bikerental.pzkbyq.features.admin.domain.AdminRepository
import com.aistudio.bikerental.pzkbyq.features.auth.domain.CustomerProfile
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class AdminCustomerProfileViewModel @Inject constructor(
    private val adminRepository: AdminRepository,
    savedStateHandle: SavedStateHandle
) : ViewModel() {

    private val customerId: String = checkNotNull(savedStateHandle["customerId"])

    private val _uiState = MutableStateFlow<UiState<CustomerProfile>>(UiState.Loading)
    val uiState: StateFlow<UiState<CustomerProfile>> = _uiState.asStateFlow()

    init {
        loadCustomerProfile()
    }

    private fun loadCustomerProfile() {
        viewModelScope.launch {
            _uiState.value = UiState.Loading
            when (val result = adminRepository.getCustomerById(customerId)) {
                is Result.Success -> _uiState.value = UiState.Success(result.data)
                is Result.Error -> _uiState.value = UiState.Error(result.message)
            }
        }
    }
}
