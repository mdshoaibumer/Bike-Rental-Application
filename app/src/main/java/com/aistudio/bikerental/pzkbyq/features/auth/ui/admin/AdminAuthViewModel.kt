package com.aistudio.bikerental.pzkbyq.features.auth.ui.admin

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
class AdminAuthViewModel @Inject constructor(
    private val authRepository: MockAuthRepository,
    private val sessionManager: SessionManager
) : ViewModel() {

    private val _email = MutableStateFlow("")
    val email: StateFlow<String> = _email.asStateFlow()

    private val _password = MutableStateFlow("")
    val password: StateFlow<String> = _password.asStateFlow()

    private val _loginState = MutableStateFlow<UiState<Boolean>>(UiState.Success(false))
    val loginState: StateFlow<UiState<Boolean>> = _loginState.asStateFlow()

    fun updateEmail(email: String) {
        _email.value = email
    }

    fun updatePassword(password: String) {
        _password.value = password
    }

    fun login() {
        if (_email.value.isBlank() || _password.value.isBlank()) {
            _loginState.value = UiState.Error("Please enter email and password")
            return
        }

        _loginState.value = UiState.Loading
        viewModelScope.launch {
            when (val result = authRepository.loginAdmin(_email.value, _password.value)) {
                is Result.Success -> {
                    sessionManager.saveSession(
                        role = UserRole.ADMIN,
                        token = "mock_admin_token_${result.data.uuid}",
                        uuid = result.data.uuid
                    )
                    _loginState.value = UiState.Success(true)
                }
                is Result.Error -> _loginState.value = UiState.Error(result.message)
            }
        }
    }

    fun resetState() {
        _loginState.value = UiState.Success(false)
    }
}
