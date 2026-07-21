package com.aistudio.bikerental.pzkbyq.features.bike.ui.search

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.aistudio.bikerental.pzkbyq.core.designsystem.components.PrimaryButton

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun FilterBottomSheet(
    onDismiss: () -> Unit,
    viewModel: SearchViewModel
) {
    val sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true)
    val currentCriteria by viewModel.filterCriteria.collectAsState()

    // Local state for UI toggles
    var onlyAvailable by remember { mutableStateOf(currentCriteria.onlyAvailable) }

    ModalBottomSheet(
        onDismissRequest = onDismiss,
        sheetState = sheetState
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(24.dp)
        ) {
            Text("Filter & Sort", style = MaterialTheme.typography.titleLarge)
            Spacer(modifier = Modifier.height(16.dp))
            
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Text("Show only available bikes")
                Switch(checked = onlyAvailable, onCheckedChange = { onlyAvailable = it })
            }

            Spacer(modifier = Modifier.height(32.dp))

            PrimaryButton(
                text = "Apply Filters",
                onClick = {
                    viewModel.updateFilters(currentCriteria.copy(onlyAvailable = onlyAvailable))
                    onDismiss()
                }
            )
            Spacer(modifier = Modifier.height(24.dp))
        }
    }
}
