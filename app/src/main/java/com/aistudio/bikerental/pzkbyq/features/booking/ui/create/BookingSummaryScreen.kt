package com.aistudio.bikerental.pzkbyq.features.booking.ui.create

import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import com.aistudio.bikerental.pzkbyq.core.common.UiState
import com.aistudio.bikerental.pzkbyq.core.designsystem.components.PrimaryButton

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun BookingSummaryScreen(
    onNavigateBack: () -> Unit,
    onNavigateToSuccess: () -> Unit,
    viewModel: BookingCreateViewModel = hiltViewModel()
) {
    val bikeState by viewModel.bikeState.collectAsState()
    val pickupDate by viewModel.pickupDate.collectAsState()
    val returnDate by viewModel.returnDate.collectAsState()
    val createState by viewModel.createState.collectAsState()
    var acceptedTerms by remember { mutableStateOf(false) }

    LaunchedEffect(createState) {
        if (createState is UiState.Success && (createState as UiState.Success).data != null) {
            onNavigateToSuccess()
            viewModel.resetCreateState()
        }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Booking Summary") },
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
                is UiState.Success -> {
                    val bike = state.data
                    // Simple mock calculation: 1 day rental
                    val rentalTotal = bike.rentalPrice * 1
                    val grandTotal = rentalTotal + bike.securityDeposit

                    Column(modifier = Modifier.padding(24.dp).fillMaxSize()) {
                        Text("Bike: ${bike.name}", style = MaterialTheme.typography.titleMedium)
                        Text("Pickup: $pickupDate", style = MaterialTheme.typography.bodyMedium)
                        Text("Return: $returnDate", style = MaterialTheme.typography.bodyMedium)
                        
                        Divider(modifier = Modifier.padding(vertical = 16.dp))

                        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                            Text("Rental (1 Day)")
                            Text("₹$rentalTotal")
                        }
                        Spacer(modifier = Modifier.height(8.dp))
                        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                            Text("Security Deposit (Refundable)")
                            Text("₹${bike.securityDeposit}")
                        }
                        Divider(modifier = Modifier.padding(vertical = 16.dp))
                        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                            Text("Grand Total", style = MaterialTheme.typography.titleLarge)
                            Text("₹$grandTotal", style = MaterialTheme.typography.titleLarge, color = MaterialTheme.colorScheme.primary)
                        }

                        Spacer(modifier = Modifier.height(32.dp))

                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Checkbox(checked = acceptedTerms, onCheckedChange = { acceptedTerms = it })
                            Text("I accept the Terms & Conditions")
                        }

                        if (createState is UiState.Error) {
                            Text((createState as UiState.Error).message, color = MaterialTheme.colorScheme.error)
                        }

                        Spacer(modifier = Modifier.weight(1f))

                        PrimaryButton(
                            text = if (createState is UiState.Loading) "Processing..." else "Confirm Booking",
                            onClick = { viewModel.confirmBooking("mock-customer-uuid") },
                            enabled = acceptedTerms && createState !is UiState.Loading
                        )
                    }
                }
                else -> {}
            }
        }
    }
}
