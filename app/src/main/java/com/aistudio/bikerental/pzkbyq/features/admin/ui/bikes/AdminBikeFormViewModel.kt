package com.aistudio.bikerental.pzkbyq.features.admin.ui.bikes

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.aistudio.bikerental.pzkbyq.core.common.Result
import com.aistudio.bikerental.pzkbyq.core.common.UiState
import com.aistudio.bikerental.pzkbyq.features.admin.domain.AdminRepository
import com.aistudio.bikerental.pzkbyq.features.bike.domain.BikeModel
import com.aistudio.bikerental.pzkbyq.features.bike.domain.BikeStatus
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import java.util.UUID
import javax.inject.Inject

@HiltViewModel
class AdminBikeFormViewModel @Inject constructor(
    private val adminRepository: AdminRepository,
    savedStateHandle: SavedStateHandle
) : ViewModel() {

    private val bikeId: String? = savedStateHandle["bikeId"]
    val isEditMode = bikeId != null

    private val _uiState = MutableStateFlow<UiState<Boolean>>(UiState.Success(false))
    val uiState: StateFlow<UiState<Boolean>> = _uiState.asStateFlow()

    private val _name = MutableStateFlow("")
    val name: StateFlow<String> = _name.asStateFlow()
    
    private val _brand = MutableStateFlow("")
    val brand: StateFlow<String> = _brand.asStateFlow()

    private val _rentalPrice = MutableStateFlow("")
    val rentalPrice: StateFlow<String> = _rentalPrice.asStateFlow()

    init {
        if (isEditMode) {
            loadBikeDetails()
        }
    }

    private fun loadBikeDetails() {
        viewModelScope.launch {
            _uiState.value = UiState.Loading
            when (val result = adminRepository.getAllBikes()) { // In a real app we'd have getBikeById in admin repo or reuse bike repo
                is Result.Success -> {
                    val bike = result.data.find { it.uuid == bikeId }
                    if (bike != null) {
                        _name.value = bike.name
                        _brand.value = bike.brand
                        _rentalPrice.value = bike.rentalPrice.toString()
                        _uiState.value = UiState.Success(false)
                    } else {
                        _uiState.value = UiState.Error("Bike not found")
                    }
                }
                is Result.Error -> _uiState.value = UiState.Error(result.message)
            }
        }
    }

    fun updateName(n: String) { _name.value = n }
    fun updateBrand(b: String) { _brand.value = b }
    fun updateRentalPrice(p: String) { _rentalPrice.value = p }

    fun saveBike() {
        viewModelScope.launch {
            _uiState.value = UiState.Loading
            val newBike = BikeModel(
                uuid = bikeId ?: UUID.randomUUID().toString(),
                name = _name.value,
                brand = _brand.value,
                category = "Unknown",
                rentalPrice = _rentalPrice.value.toIntOrNull() ?: 0,
                securityDeposit = 1000,
                status = BikeStatus.AVAILABLE,
                engineCc = 100,
                fuelType = "Petrol",
                description = "Mock description"
            )
            val result = if (isEditMode) {
                adminRepository.updateBike(newBike)
            } else {
                adminRepository.addBike(newBike)
            }

            when (result) {
                is Result.Success -> _uiState.value = UiState.Success(true) // true = saved
                is Result.Error -> _uiState.value = UiState.Error(result.message)
            }
        }
    }
}
