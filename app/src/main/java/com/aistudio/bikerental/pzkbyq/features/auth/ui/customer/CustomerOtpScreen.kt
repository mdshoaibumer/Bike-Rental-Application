package com.aistudio.bikerental.pzkbyq.features.auth.ui.customer

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import com.aistudio.bikerental.pzkbyq.core.common.UiState
import com.aistudio.bikerental.pzkbyq.core.designsystem.components.PrimaryButton
import kotlinx.coroutines.delay

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CustomerOtpScreen(
    onLoginSuccess: () -> Unit,
    viewModel: CustomerAuthViewModel = hiltViewModel()
) {
    val phoneNumber by viewModel.phoneNumber.collectAsState()
    val loginState by viewModel.loginState.collectAsState()
    var otp by remember { mutableStateOf("") }
    var countdown by remember { mutableIntStateOf(30) }

    LaunchedEffect(countdown) {
        if (countdown > 0) {
            delay(1000)
            countdown--
        }
    }

    LaunchedEffect(loginState) {
        if (loginState is UiState.Success && (loginState as UiState.Success<Boolean>).data) {
            onLoginSuccess()
            viewModel.resetState()
        }
    }

    Scaffold { paddingValues ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
                .padding(24.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            Text(
                text = "Verify your number",
                style = MaterialTheme.typography.headlineMedium
            )
            Spacer(modifier = Modifier.height(8.dp))
            Text(
                text = "Sent to +91 $phoneNumber",
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
            
            Spacer(modifier = Modifier.height(32.dp))

            // Using a standard text field for simplicity, ideally a 4-box custom layout
            OutlinedTextField(
                value = otp,
                onValueChange = { if (it.length <= 4) otp = it },
                label = { Text("4-digit OTP (hint: 1234)") },
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                singleLine = true,
                modifier = Modifier.fillMaxWidth(),
                isError = loginState is UiState.Error
            )

            if (loginState is UiState.Error) {
                Text(
                    text = (loginState as UiState.Error).message,
                    color = MaterialTheme.colorScheme.error,
                    style = MaterialTheme.typography.labelMedium,
                    modifier = Modifier.align(Alignment.Start).padding(top = 4.dp)
                )
            }

            Spacer(modifier = Modifier.height(24.dp))

            PrimaryButton(
                text = if (loginState is UiState.Loading) "Verifying..." else "Verify OTP",
                onClick = { viewModel.verifyOtp(otp) },
                enabled = otp.length == 4 && loginState !is UiState.Loading
            )

            Spacer(modifier = Modifier.height(24.dp))

            TextButton(
                onClick = { 
                    countdown = 30
                    viewModel.requestOtp() 
                },
                enabled = countdown == 0
            ) {
                Text(if (countdown > 0) "Resend OTP in $countdown s" else "Resend OTP")
            }
        }
    }
}
