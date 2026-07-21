package com.aistudio.bikerental.pzkbyq.features.auth.ui.customer

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.aistudio.bikerental.pzkbyq.core.common.Result
import com.aistudio.bikerental.pzkbyq.core.common.UiState
import com.aistudio.bikerental.pzkbyq.core.common.UserRole
import com.aistudio.bikerental.pzkbyq.core.mock.MockAuthRepository
import com.aistudio.bikerental.pzkbyq.core.storage.SessionManager
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class CustomerAuthViewModel @Inject constructor(
    private val authRepository: MockAuthRepository,
    private val sessionManager: SessionManager
) : ViewModel() {

    private val _phoneNumber = MutableStateFlow("")
    val phoneNumber: StateFlow<String> = _phoneNumber.asStateFlow()

    private val _otpState = MutableStateFlow<UiState<Boolean>>(UiState.Success(false))
    val otpState: StateFlow<UiState<Boolean>> = _otpState.asStateFlow()

    private val _loginState = MutableStateFlow<UiState<Boolean>>(UiState.Success(false))
    val loginState: StateFlow<UiState<Boolean>> = _loginState.asStateFlow()

    fun updatePhoneNumber(number: String) {
        if (number.length <= 10 && number.all { it.isDigit() }) {
            _phoneNumber.value = number
        }
    }

    fun requestOtp() {
        if (_phoneNumber.value.length != 10) {
            _otpState.value = UiState.Error("Please enter a valid 10-digit mobile number")
            return
        }

        _otpState.value = UiState.Loading
        viewModelScope.launch {
            when (val result = authRepository.requestOtp(_phoneNumber.value)) {
                is Result.Success -> _otpState.value = UiState.Success(true)
                is Result.Error -> _otpState.value = UiState.Error(result.message)
            }
        }
    }

    fun verifyOtp(otp: String) {
        if (otp.length != 4) {
            _loginState.value = UiState.Error("OTP must be 4 digits")
            return
        }

        _loginState.value = UiState.Loading
        viewModelScope.launch {
            when (val result = authRepository.verifyOtp(_phoneNumber.value, otp)) {
                is Result.Success -> {
                    // Save mock token and user details to DataStore
                    sessionManager.saveSession(
                        role = UserRole.CUSTOMER,
                        token = "mock_customer_token_${result.data.uuid}",
                        uuid = result.data.uuid
                    )
                    _loginState.value = UiState.Success(true)
                }
                is Result.Error -> _loginState.value = UiState.Error(result.message)
            }
        }
    }

    fun resetState() {
        _otpState.value = UiState.Success(false)
        _loginState.value = UiState.Success(false)
    }
}
