package com.aistudio.bikerental.pzkbyq.features.booking.ui.create

import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import com.aistudio.bikerental.pzkbyq.core.common.UiState
import com.aistudio.bikerental.pzkbyq.core.designsystem.components.PrimaryButton

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun BookingFormScreen(
    onNavigateBack: () -> Unit,
    onNavigateToSummary: () -> Unit,
    viewModel: BookingCreateViewModel = hiltViewModel()
) {
    val bikeState by viewModel.bikeState.collectAsState()
    val pickupDate by viewModel.pickupDate.collectAsState()
    val returnDate by viewModel.returnDate.collectAsState()

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Select Dates") },
                navigationIcon = {
                    IconButton(onClick = onNavigateBack) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Back")
                    }
                }
            )
        }
    ) { paddingValues ->
        Box(modifier = Modifier.padding(paddingValues).fillMaxSize()) {
            when (val state = bikeState) {
                is UiState.Loading -> CircularProgressIndicator(modifier = Modifier.align(Alignment.Center))
                is UiState.Error -> Text(state.message, color = MaterialTheme.colorScheme.error, modifier = Modifier.align(Alignment.Center))
                is UiState.Success -> {
                    val bike = state.data
                    Column(modifier = Modifier.padding(24.dp).fillMaxSize()) {
                        Text(text = "Booking: ${bike.name}", style = MaterialTheme.typography.titleLarge)
                        Spacer(modifier = Modifier.height(32.dp))

                        OutlinedTextField(
                            value = pickupDate,
                            onValueChange = viewModel::updatePickupDate,
                            label = { Text("Pickup Date (DD/MM/YYYY)") },
                            modifier = Modifier.fillMaxWidth()
                        )
                        
                        Spacer(modifier = Modifier.height(16.dp))

                        OutlinedTextField(
                            value = returnDate,
                            onValueChange = viewModel::updateReturnDate,
                            label = { Text("Return Date (DD/MM/YYYY)") },
                            modifier = Modifier.fillMaxWidth()
                        )

                        Spacer(modifier = Modifier.weight(1f))

                        PrimaryButton(
                            text = "Continue to Summary",
                            onClick = onNavigateToSummary,
                            enabled = pickupDate.isNotBlank() && returnDate.isNotBlank()
                        )
                    }
                }
            }
        }
    }
}
