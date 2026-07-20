package com.aistudio.bikerental.pzkbyq.features.booking.ui.create

import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.aistudio.bikerental.pzkbyq.core.designsystem.components.PrimaryButton
import com.aistudio.bikerental.pzkbyq.core.designsystem.components.SecondaryButton

@Composable
fun BookingSuccessScreen(
    onNavigateHome: () -> Unit,
    onNavigateToHistory: () -> Unit
) {
    Scaffold { paddingValues ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
                .padding(24.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            Icon(
                imageVector = Icons.Default.CheckCircle,
                contentDescription = "Success",
                tint = MaterialTheme.colorScheme.primary,
                modifier = Modifier.size(100.dp)
            )
            Spacer(modifier = Modifier.height(24.dp))
            Text(
                text = "Booking Confirmed!",
                style = MaterialTheme.typography.headlineMedium
            )
            Spacer(modifier = Modifier.height(8.dp))
            Text(
                text = "Your booking request has been sent for approval. You will receive a confirmation shortly.",
                style = MaterialTheme.typography.bodyMedium,
                textAlign = TextAlign.Center,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )

            Spacer(modifier = Modifier.height(48.dp))

            PrimaryButton(text = "View Bookings", onClick = onNavigateToHistory)
            Spacer(modifier = Modifier.height(16.dp))
            SecondaryButton(text = "Back to Home", onClick = onNavigateHome)
        }
    }
}
