package com.aistudio.bikerental.pzkbyq.features.booking.ui.history

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import com.aistudio.bikerental.pzkbyq.core.common.UiState
import com.aistudio.bikerental.pzkbyq.features.booking.domain.BookingModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun BookingHistoryScreen(
    onNavigateToDetails: (String) -> Unit,
    viewModel: BookingHistoryViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    val selectedTab by viewModel.selectedTab.collectAsState()
    val tabs = BookingFilterTab.values()

    Scaffold(
        topBar = {
            TopAppBar(title = { Text("My Bookings") })
        }
    ) { paddingValues ->
        Column(modifier = Modifier.padding(paddingValues).fillMaxSize()) {
            ScrollableTabRow(selectedTabIndex = selectedTab.ordinal, edgePadding = 16.dp) {
                tabs.forEach { tab ->
                    Tab(
                        selected = selectedTab == tab,
                        onClick = { viewModel.setTab(tab) },
                        text = { Text(tab.name.lowercase().capitalize()) }
                    )
                }
            }

            Box(modifier = Modifier.fillMaxSize()) {
                when (val state = uiState) {
                    is UiState.Loading -> CircularProgressIndicator(modifier = Modifier.align(Alignment.Center))
                    is UiState.Error -> Text(state.message, color = MaterialTheme.colorScheme.error, modifier = Modifier.align(Alignment.Center))
                    is UiState.Success -> {
                        if (state.data.isEmpty()) {
                            Text(
                                "No bookings found in this category.",
                                style = MaterialTheme.typography.bodyLarge,
                                modifier = Modifier.align(Alignment.Center)
                            )
                        } else {
                            LazyColumn(
                                contentPadding = PaddingValues(16.dp),
                                verticalArrangement = Arrangement.spacedBy(16.dp),
                                modifier = Modifier.fillMaxSize()
                            ) {
                                items(state.data) { booking ->
                                    BookingHistoryCard(booking = booking, onClick = { onNavigateToDetails(booking.bookingId) })
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

@Composable
fun BookingHistoryCard(booking: BookingModel, onClick: () -> Unit) {
    Card(
        modifier = Modifier.fillMaxWidth().clickable(onClick = onClick),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                Text(text = booking.bikeName, style = MaterialTheme.typography.titleMedium)
                Text(text = booking.status.name, style = MaterialTheme.typography.labelMedium, color = MaterialTheme.colorScheme.primary)
            }
            Spacer(modifier = Modifier.height(8.dp))
            Text(text = "ID: ${booking.bookingId}", style = MaterialTheme.typography.bodySmall)
            Text(text = "${booking.pickupDate} to ${booking.returnDate}", style = MaterialTheme.typography.bodyMedium)
            Spacer(modifier = Modifier.height(8.dp))
            Text(text = "Total: ₹${booking.totalAmount}", style = MaterialTheme.typography.labelLarge)
        }
    }
}
