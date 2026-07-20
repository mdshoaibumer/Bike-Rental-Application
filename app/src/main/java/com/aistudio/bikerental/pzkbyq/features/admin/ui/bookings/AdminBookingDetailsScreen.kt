package com.aistudio.bikerental.pzkbyq.features.admin.ui.bookings

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
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
import com.aistudio.bikerental.pzkbyq.core.designsystem.components.SecondaryButton
import com.aistudio.bikerental.pzkbyq.features.booking.domain.BookingStatus

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AdminBookingDetailsScreen(
    onNavigateBack: () -> Unit,
    viewModel: AdminBookingDetailsViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    val actionState by viewModel.actionState.collectAsState()

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Booking Operations") },
                navigationIcon = {
                    IconButton(onClick = onNavigateBack) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Back")
                    }
                }
            )
        }
    ) { paddingValues ->
        Box(modifier = Modifier.padding(paddingValues).fillMaxSize()) {
            when (val state = uiState) {
                is UiState.Loading -> CircularProgressIndicator(modifier = Modifier.align(Alignment.Center))
                is UiState.Error -> Text(state.message, color = MaterialTheme.colorScheme.error, modifier = Modifier.align(Alignment.Center))
                is UiState.Success -> {
                    val booking = state.data
                    LazyColumn(
                        modifier = Modifier.fillMaxSize(),
                        contentPadding = PaddingValues(24.dp)
                    ) {
                        item {
                            Text("Booking ID: ${booking.bookingId}", style = MaterialTheme.typography.titleLarge)
                            Text("Status: ${booking.status.name}", style = MaterialTheme.typography.titleMedium, color = MaterialTheme.colorScheme.primary)
                            Spacer(modifier = Modifier.height(24.dp))
                        }
                        
                        item {
                            Text("Customer: ${booking.customerName}", style = MaterialTheme.typography.bodyLarge)
                            Text("Bike: ${booking.bikeName}", style = MaterialTheme.typography.bodyLarge)
                            Spacer(modifier = Modifier.height(16.dp))
                        }

                        item {
                            Text("Rental Period", style = MaterialTheme.typography.titleMedium)
                            Text("Pickup: ${booking.pickupDate} at ${booking.pickupTime}", style = MaterialTheme.typography.bodyMedium)
                            Text("Return: ${booking.returnDate} at ${booking.returnTime}", style = MaterialTheme.typography.bodyMedium)
                            Spacer(modifier = Modifier.height(24.dp))
                        }

                        if (actionState is UiState.Error) {
                            item {
                                Text((actionState as UiState.Error).message, color = MaterialTheme.colorScheme.error)
                                Spacer(modifier = Modifier.height(8.dp))
                            }
                        }

                        // State Transitions
                        item {
                            val isProcessing = actionState is UiState.Loading
                            when (booking.status) {
                                BookingStatus.PENDING_APPROVAL -> {
                                    PrimaryButton(text = "Approve Booking", onClick = { viewModel.updateStatus(BookingStatus.APPROVED) }, enabled = !isProcessing)
                                    Spacer(modifier = Modifier.height(8.dp))
                                    SecondaryButton(text = "Reject Booking", onClick = { viewModel.updateStatus(BookingStatus.REJECTED) }, enabled = !isProcessing)
                                }
                                BookingStatus.APPROVED -> {
                                    PrimaryButton(text = "Mark Ready for Pickup", onClick = { viewModel.updateStatus(BookingStatus.READY_FOR_PICKUP) }, enabled = !isProcessing)
                                }
                                BookingStatus.READY_FOR_PICKUP -> {
                                    PrimaryButton(text = "Start Rental (Handover)", onClick = { viewModel.updateStatus(BookingStatus.ACTIVE) }, enabled = !isProcessing)
                                }
                                BookingStatus.ACTIVE -> {
                                    PrimaryButton(text = "Complete Rental (Return)", onClick = { viewModel.updateStatus(BookingStatus.COMPLETED) }, enabled = !isProcessing)
                                }
                                else -> {
                                    Text("No actions available for current status.", style = MaterialTheme.typography.bodyMedium, color = MaterialTheme.colorScheme.onSurfaceVariant)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
