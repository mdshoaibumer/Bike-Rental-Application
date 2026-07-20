package com.aistudio.bikerental.pzkbyq.features.booking.ui.details

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
fun BookingDetailsScreen(
    onNavigateBack: () -> Unit,
    viewModel: BookingDetailsViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    val cancelState by viewModel.cancelState.collectAsState()

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Booking Details") },
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
                            Text("Status: ${booking.status.name}", style = MaterialTheme.typography.titleLarge, color = MaterialTheme.colorScheme.primary)
                            Text("Booking ID: ${booking.bookingId}", style = MaterialTheme.typography.bodyMedium)
                            Spacer(modifier = Modifier.height(24.dp))
                        }
                        
                        item {
                            Text("Bike Details", style = MaterialTheme.typography.titleMedium)
                            Text(booking.bikeName, style = MaterialTheme.typography.bodyLarge)
                            Spacer(modifier = Modifier.height(16.dp))
                        }

                        item {
                            Text("Rental Period", style = MaterialTheme.typography.titleMedium)
                            Text("Pickup: ${booking.pickupDate} at ${booking.pickupTime}", style = MaterialTheme.typography.bodyMedium)
                            Text("Return: ${booking.returnDate} at ${booking.returnTime}", style = MaterialTheme.typography.bodyMedium)
                            Spacer(modifier = Modifier.height(24.dp))
                        }

                        item {
                            Divider()
                            Spacer(modifier = Modifier.height(16.dp))
                            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                                Text("Total Amount")
                                Text("₹${booking.totalAmount}", style = MaterialTheme.typography.titleMedium)
                            }
                            Spacer(modifier = Modifier.height(32.dp))
                        }

                        if (booking.status == BookingStatus.PENDING_APPROVAL) {
                            item {
                                if (cancelState is UiState.Error) {
                                    Text((cancelState as UiState.Error).message, color = MaterialTheme.colorScheme.error)
                                    Spacer(modifier = Modifier.height(8.dp))
                                }
                                SecondaryButton(
                                    text = if (cancelState is UiState.Loading) "Cancelling..." else "Cancel Booking",
                                    onClick = viewModel::cancelBooking,
                                    enabled = cancelState !is UiState.Loading
                                )
                            }
                        }
                    }
                }
            }
        }
    }
}
