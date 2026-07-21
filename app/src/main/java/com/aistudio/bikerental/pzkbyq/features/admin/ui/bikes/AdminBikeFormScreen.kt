package com.aistudio.bikerental.pzkbyq.features.admin.ui.bikes

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
fun AdminBikeFormScreen(
    onNavigateBack: () -> Unit,
    viewModel: AdminBikeFormViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    val name by viewModel.name.collectAsState()
    val brand by viewModel.brand.collectAsState()
    val rentalPrice by viewModel.rentalPrice.collectAsState()

    LaunchedEffect(uiState) {
        if (uiState is UiState.Success && (uiState as UiState.Success).data == true) {
            onNavigateBack() // Go back when saved successfully
        }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text(if (viewModel.isEditMode) "Edit Bike" else "Add Bike") },
                navigationIcon = {
                    IconButton(onClick = onNavigateBack) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Back")
                    }
                }
            )
        }
    ) { paddingValues ->
        Box(modifier = Modifier.padding(paddingValues).fillMaxSize()) {
            when (uiState) {
                is UiState.Loading -> CircularProgressIndicator(modifier = Modifier.align(Alignment.Center))
                is UiState.Error -> Text((uiState as UiState.Error).message, color = MaterialTheme.colorScheme.error, modifier = Modifier.align(Alignment.Center))
                is UiState.Success -> {
                    Column(modifier = Modifier.padding(24.dp).fillMaxSize()) {
                        OutlinedTextField(
                            value = name,
                            onValueChange = viewModel::updateName,
                            label = { Text("Bike Name") },
                            modifier = Modifier.fillMaxWidth()
                        )
                        Spacer(modifier = Modifier.height(16.dp))
                        OutlinedTextField(
                            value = brand,
                            onValueChange = viewModel::updateBrand,
                            label = { Text("Brand") },
                            modifier = Modifier.fillMaxWidth()
                        )
                        Spacer(modifier = Modifier.height(16.dp))
                        OutlinedTextField(
                            value = rentalPrice,
                            onValueChange = viewModel::updateRentalPrice,
                            label = { Text("Rental Price (₹/day)") },
                            modifier = Modifier.fillMaxWidth()
                        )
                        
                        Spacer(modifier = Modifier.weight(1f))
                        
                        PrimaryButton(
                            text = "Save Bike",
                            onClick = viewModel::saveBike,
                            enabled = name.isNotBlank() && brand.isNotBlank() && rentalPrice.isNotBlank()
                        )
                    }
                }
            }
        }
    }
}
