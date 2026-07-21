package com.aistudio.bikerental.pzkbyq.features.admin.ui.customers

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

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CustomerProfileScreen(
    onNavigateBack: () -> Unit,
    viewModel: AdminCustomerProfileViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Customer Profile") },
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
                    val customer = state.data
                    LazyColumn(
                        modifier = Modifier.fillMaxSize(),
                        contentPadding = PaddingValues(24.dp)
                    ) {
                        item {
                            Text(customer.name, style = MaterialTheme.typography.headlineMedium)
                            Text("UUID: ${customer.uuid}", style = MaterialTheme.typography.labelSmall)
                            Spacer(modifier = Modifier.height(24.dp))
                        }
                        item {
                            Text("Contact Details", style = MaterialTheme.typography.titleMedium)
                            Text("Phone: ${customer.phone}", style = MaterialTheme.typography.bodyLarge)
                            Text("Email: ${customer.email ?: "N/A"}", style = MaterialTheme.typography.bodyLarge)
                            Spacer(modifier = Modifier.height(16.dp))
                        }
                        item {
                            Text("Address", style = MaterialTheme.typography.titleMedium)
                            Text(customer.address ?: "N/A", style = MaterialTheme.typography.bodyLarge)
                            Spacer(modifier = Modifier.height(16.dp))
                        }
                        item {
                            Text("KYC Information", style = MaterialTheme.typography.titleMedium)
                            Text("Driving License: ${customer.drivingLicenseNumber ?: "N/A"}", style = MaterialTheme.typography.bodyLarge)
                        }
                    }
                }
            }
        }
    }
}
