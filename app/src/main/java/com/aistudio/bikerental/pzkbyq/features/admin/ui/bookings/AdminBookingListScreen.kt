package com.aistudio.bikerental.pzkbyq.features.admin.ui.bookings

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
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
import com.aistudio.bikerental.pzkbyq.features.booking.domain.BookingModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AdminBookingListScreen(
    onNavigateBack: () -> Unit,
    onNavigateToDetails: (String) -> Unit,
    viewModel: AdminBookingListViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Manage Bookings") },
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
                    LazyColumn(
                        contentPadding = PaddingValues(16.dp),
                        verticalArrangement = Arrangement.spacedBy(8.dp),
                        modifier = Modifier.fillMaxSize()
                    ) {
                        items(state.data) { booking ->
                            AdminBookingCard(booking = booking, onClick = { onNavigateToDetails(booking.bookingId) })
                        }
                    }
                }
            }
        }
    }
}

@Composable
fun AdminBookingCard(booking: BookingModel, onClick: () -> Unit) {
    Card(
        modifier = Modifier.fillMaxWidth().clickable(onClick = onClick),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                Text(text = booking.bookingId, style = MaterialTheme.typography.titleMedium)
                Text(text = booking.status.name, style = MaterialTheme.typography.labelMedium, color = MaterialTheme.colorScheme.primary)
            }
            Spacer(modifier = Modifier.height(8.dp))
            Text(text = "Customer: ${booking.customerName}", style = MaterialTheme.typography.bodyMedium)
            Text(text = "Bike: ${booking.bikeName}", style = MaterialTheme.typography.bodyMedium)
            Text(text = "Dates: ${booking.pickupDate} - ${booking.returnDate}", style = MaterialTheme.typography.bodySmall)
        }
    }
}
