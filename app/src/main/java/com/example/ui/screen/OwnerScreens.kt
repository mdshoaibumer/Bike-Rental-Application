package com.example.ui.screen

import androidx.compose.animation.*
import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.data.model.BikeEntity
import com.example.ui.viewmodel.BikeViewModel

@Composable
fun OwnerPortalScreen(
    viewModel: BikeViewModel,
    onLogout: () -> Unit,
    modifier: Modifier = Modifier
) {
    var selectedTab by remember { mutableIntStateOf(0) }

    Scaffold(
        bottomBar = {
            NavigationBar(
                containerColor = MaterialTheme.colorScheme.surface,
                tonalElevation = 8.dp
            ) {
                NavigationBarItem(
                    selected = selectedTab == 0,
                    onClick = { selectedTab = 0 },
                    icon = { Icon(Icons.Default.Dashboard, "Dashboard") },
                    label = { Text("Dashboard") }
                )
                NavigationBarItem(
                    selected = selectedTab == 1,
                    onClick = { selectedTab = 1 },
                    icon = { Icon(Icons.Default.DirectionsBike, "Manage Fleet") },
                    label = { Text("Fleet") }
                )
                NavigationBarItem(
                    selected = selectedTab == 2,
                    onClick = { selectedTab = 2 },
                    icon = { Icon(Icons.Default.People, "Customers") },
                    label = { Text("Riders") }
                )
            }
        },
        modifier = modifier.fillMaxSize()
    ) { innerPadding ->
        Box(modifier = Modifier.padding(innerPadding)) {
            when (selectedTab) {
                0 -> OwnerDashboardTab(viewModel, onLogout)
                1 -> FleetManagementTab(viewModel)
                2 -> CustomersTab(viewModel)
            }
        }
    }
}

@Composable
fun OwnerDashboardTab(
    viewModel: BikeViewModel,
    onLogout: () -> Unit
) {
    val analytics by viewModel.analyticsSummary.collectAsState()

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background)
    ) {
        // Owner Header
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .background(MaterialTheme.colorScheme.surface)
                .padding(horizontal = 20.dp, vertical = 16.dp)
                .statusBarsPadding()
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column {
                    Text(
                        text = "Owner Console",
                        style = MaterialTheme.typography.headlineSmall.copy(fontWeight = FontWeight.Bold),
                        color = MaterialTheme.colorScheme.onBackground
                    )
                    Text(
                        text = "Real-time Operations & Analytics",
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onBackground.copy(alpha = 0.5f)
                    )
                }

                IconButton(
                    onClick = onLogout,
                    modifier = Modifier.testTag("owner_logout_icon_btn")
                ) {
                    Icon(Icons.Default.ExitToApp, "Logout", tint = MaterialTheme.colorScheme.error)
                }
            }
        }

        LazyColumn(
            modifier = Modifier
                .fillMaxWidth()
                .weight(1f),
            contentPadding = PaddingValues(20.dp),
            verticalArrangement = Arrangement.spacedBy(20.dp)
        ) {
            // Stats Grid Section
            item {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    MetricCard(
                        title = "Total Earnings",
                        value = "$${String.format("%.2f", analytics?.totalRevenue ?: 132.50)}",
                        icon = Icons.Default.MonetizationOn,
                        tint = MaterialTheme.colorScheme.primary,
                        modifier = Modifier.weight(1f)
                    )

                    MetricCard(
                        title = "Active Rentals",
                        value = "${analytics?.activeBookingsCount ?: 0}",
                        icon = Icons.Default.DirectionsBike,
                        tint = Color(0xFF4CAF50),
                        modifier = Modifier.weight(1f)
                    )
                }
            }

            item {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    MetricCard(
                        title = "Fleet Available",
                        value = "${analytics?.availableFleet ?: 5}",
                        icon = Icons.Default.CheckCircle,
                        tint = Color(0xFF2196F3),
                        modifier = Modifier.weight(1f)
                    )

                    MetricCard(
                        title = "Registered Users",
                        value = "${analytics?.totalUsers ?: 1}",
                        icon = Icons.Default.Group,
                        tint = Color(0xFFE91E63),
                        modifier = Modifier.weight(1f)
                    )
                }
            }

            // Custom Analytics Report 1: Revenue by Bike Category (Rounded Bar Chart)
            item {
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(20.dp),
                    colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface)
                ) {
                    Column(modifier = Modifier.padding(20.dp)) {
                        Text(
                            text = "Revenue by Bike Category",
                            style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold),
                            color = MaterialTheme.colorScheme.onSurface,
                            modifier = Modifier.padding(bottom = 16.dp)
                        )

                        val categoryRevenues = analytics?.revenueByCategory ?: mapOf(
                            "Electric" to 65.0,
                            "Mountain" to 42.0,
                            "Road" to 25.5,
                            "Cruiser" to 16.0
                        )

                        // Draw Custom Canvas Bar Chart
                        Box(
                            modifier = Modifier
                                .fillMaxWidth()
                                .height(160.dp)
                        ) {
                            val primaryColor = MaterialTheme.colorScheme.primary
                            val secondaryColor = MaterialTheme.colorScheme.secondary
                            val labelColor = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f)

                            Canvas(modifier = Modifier.fillMaxSize()) {
                                val keys = categoryRevenues.keys.toList()
                                val maxVal = (categoryRevenues.values.maxOrNull() ?: 1.0).coerceAtLeast(10.0)

                                val padding = 40f
                                val chartWidth = size.width
                                val chartHeight = size.height - 40f
                                val barSpacing = chartWidth / keys.size

                                keys.forEachIndexed { index, category ->
                                    val rev = categoryRevenues[category] ?: 0.0
                                    val barHeight = (rev / maxVal) * chartHeight
                                    val barWidth = 60f
                                    val xOffset = index * barSpacing + (barSpacing - barWidth) / 2

                                    // Draw background guide tracks
                                    drawRoundRect(
                                        color = Color.LightGray.copy(alpha = 0.15f),
                                        topLeft = Offset(xOffset, 0f),
                                        size = Size(barWidth, chartHeight),
                                        cornerRadius = CornerRadius(10f, 10f)
                                    )

                                    // Draw filled values
                                    drawRoundRect(
                                        brush = Brush.verticalGradient(
                                            colors = listOf(primaryColor, secondaryColor)
                                        ),
                                        topLeft = Offset(xOffset, chartHeight - barHeight.toFloat()),
                                        size = Size(barWidth, barHeight.toFloat()),
                                        cornerRadius = CornerRadius(10f, 10f)
                                    )
                                }
                            }
                        }

                        // Categories legends
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(top = 12.dp),
                            horizontalArrangement = Arrangement.SpaceBetween
                        ) {
                            val categoryRevenues = analytics?.revenueByCategory ?: mapOf(
                                "Electric" to 65.0,
                                "Mountain" to 42.0,
                                "Road" to 25.5,
                                "Cruiser" to 16.0
                            )
                            categoryRevenues.forEach { (cat, rev) ->
                                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                                    Text(text = cat, style = MaterialTheme.typography.labelSmall, color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.5f))
                                    Text(text = "$${rev.toInt()}", style = MaterialTheme.typography.bodySmall.copy(fontWeight = FontWeight.Bold))
                                }
                            }
                        }
                    }
                }
            }

            // Custom Analytics Report 2: Weekly Rent Booking Trends (Gradient Line Chart)
            item {
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(20.dp),
                    colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface)
                ) {
                    Column(modifier = Modifier.padding(20.dp)) {
                        Text(
                            text = "Weekly Bookings Trend",
                            style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold),
                            color = MaterialTheme.colorScheme.onSurface,
                            modifier = Modifier.padding(bottom = 16.dp)
                        )

                        // Weekly points
                        val points = listOf(1.5f, 3f, 2.5f, 5.2f, 4f, 6.5f, 5f) // simulated bookings counts
                        val days = listOf("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun")

                        Box(
                            modifier = Modifier
                                .fillMaxWidth()
                                .height(160.dp)
                        ) {
                            val primaryColor = MaterialTheme.colorScheme.primary
                            val gradientColor = MaterialTheme.colorScheme.primaryContainer.copy(alpha = 0.3f)

                            Canvas(modifier = Modifier.fillMaxSize()) {
                                val chartWidth = size.width
                                val chartHeight = size.height - 40f
                                val spacing = chartWidth / (points.size - 1)
                                val maxPointsVal = 8f

                                val path = Path()
                                val fillPath = Path()

                                points.forEachIndexed { idx, value ->
                                    val x = idx * spacing
                                    val y = chartHeight - (value / maxPointsVal) * chartHeight

                                    if (idx == 0) {
                                        path.moveTo(x, y)
                                        fillPath.moveTo(x, chartHeight)
                                        fillPath.lineTo(x, y)
                                    } else {
                                        path.lineTo(x, y)
                                        fillPath.lineTo(x, y)
                                    }

                                    if (idx == points.size - 1) {
                                        fillPath.lineTo(x, chartHeight)
                                        fillPath.close()
                                    }

                                    // Draw point dots
                                    drawCircle(
                                        color = primaryColor,
                                        radius = 8f,
                                        center = Offset(x, y)
                                    )
                                }

                                // Draw trend line
                                drawPath(
                                    path = path,
                                    color = primaryColor,
                                    style = Stroke(width = 6f)
                                )

                                // Draw gradient fill below line
                                drawPath(
                                    path = fillPath,
                                    brush = Brush.verticalGradient(
                                        colors = listOf(gradientColor, Color.Transparent)
                                    )
                                )
                            }
                        }

                        // Day label legends
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(top = 8.dp),
                            horizontalArrangement = Arrangement.SpaceBetween
                        ) {
                            days.forEach { day ->
                                Text(
                                    text = day,
                                    style = MaterialTheme.typography.labelSmall,
                                    color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.4f),
                                    modifier = Modifier.width(36.dp),
                                    textAlign = TextAlign.Center
                                )
                            }
                        }
                    }
                }
            }
        }
    }
}

@Composable
fun FleetManagementTab(viewModel: BikeViewModel) {
    val bikes by viewModel.allBikes.collectAsState()
    var showAddDialog by remember { mutableStateOf(false) }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background)
    ) {
        // Fleet Header
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .background(MaterialTheme.colorScheme.surface)
                .padding(horizontal = 20.dp, vertical = 16.dp)
                .statusBarsPadding()
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column {
                    Text(
                        text = "Fleet Management",
                        style = MaterialTheme.typography.headlineSmall.copy(fontWeight = FontWeight.Bold),
                        color = MaterialTheme.colorScheme.onBackground
                    )
                    Text(
                        text = "${bikes.size} Registered Vehicles",
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onBackground.copy(alpha = 0.5f)
                    )
                }

                Button(
                    onClick = { showAddDialog = true },
                    shape = RoundedCornerShape(12.dp),
                    modifier = Modifier.testTag("add_bike_nav_btn")
                ) {
                    Icon(Icons.Default.Add, "Add")
                    Spacer(modifier = Modifier.width(4.dp))
                    Text("Add Bike")
                }
            }
        }

        LazyColumn(
            modifier = Modifier
                .fillMaxWidth()
                .weight(1f),
            contentPadding = PaddingValues(20.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            items(bikes) { bike ->
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(16.dp),
                    colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface)
                ) {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(16.dp),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        Row(modifier = Modifier.weight(1f), verticalAlignment = Alignment.CenterVertically) {
                            Box(
                                modifier = Modifier
                                    .size(44.dp)
                                    .clip(CircleShape)
                                    .background(MaterialTheme.colorScheme.primaryContainer),
                                contentAlignment = Alignment.Center
                            ) {
                                Icon(
                                    imageVector = Icons.Default.DirectionsBike,
                                    contentDescription = "Bike Icon",
                                    tint = MaterialTheme.colorScheme.onPrimaryContainer
                                )
                            }
                            Spacer(modifier = Modifier.width(16.dp))
                            Column {
                                Text(
                                    text = bike.name,
                                    style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold),
                                    color = MaterialTheme.colorScheme.onSurface
                                )
                                Text(
                                    text = "Rate: $${String.format("%.2f", bike.chargePerHour)}/hr | ${bike.category}",
                                    style = MaterialTheme.typography.bodySmall,
                                    color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f)
                                )
                                Text(
                                    text = bike.location,
                                    style = MaterialTheme.typography.bodySmall,
                                    color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.4f),
                                    maxLines = 1
                                )
                            }
                        }

                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Box(
                                modifier = Modifier
                                    .padding(end = 12.dp)
                                    .clip(RoundedCornerShape(6.dp))
                                    .background(
                                        if (bike.isAvailable) Color(0xFF4CAF50).copy(alpha = 0.1f)
                                        else Color(0xFFFF9800).copy(alpha = 0.1f)
                                    )
                                    .padding(horizontal = 8.dp, vertical = 4.dp)
                            ) {
                                Text(
                                    text = if (bike.isAvailable) "Ready" else "Rented",
                                    style = MaterialTheme.typography.labelSmall.copy(fontWeight = FontWeight.Bold),
                                    color = if (bike.isAvailable) Color(0xFF4CAF50) else Color(0xFFFF9800)
                                )
                            }

                            IconButton(
                                onClick = { viewModel.deleteBike(bike.id) },
                                modifier = Modifier.testTag("delete_bike_${bike.id}")
                            ) {
                                Icon(
                                    imageVector = Icons.Default.Delete,
                                    contentDescription = "Delete Bike",
                                    tint = MaterialTheme.colorScheme.error
                                )
                            }
                        }
                    }
                }
            }
        }
    }

    if (showAddDialog) {
        AddBikeDialog(
            onDismiss = { showAddDialog = false },
            onSave = { name, model, category, charge, loc ->
                viewModel.addNewBike(name, model, category, charge, loc, category.lowercase())
                showAddDialog = false
            }
        )
    }
}

@Composable
fun AddBikeDialog(
    onDismiss: () -> Unit,
    onSave: (String, String, String, Double, String) -> Unit
) {
    var name by remember { mutableStateOf("") }
    var model by remember { mutableStateOf("") }
    var category by remember { mutableStateOf("Electric") }
    var chargeString by remember { mutableStateOf("") }
    var location by remember { mutableStateOf("") }

    val categories = listOf("Electric", "Mountain", "Road", "Cruiser")

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Register New Fleet Bike") },
        text = {
            Column(
                verticalArrangement = Arrangement.spacedBy(12.dp),
                modifier = Modifier.verticalScroll(rememberScrollState())
            ) {
                OutlinedTextField(
                    value = name,
                    onValueChange = { name = it },
                    label = { Text("Bike Name") },
                    singleLine = true,
                    modifier = Modifier.fillMaxWidth().testTag("add_bike_name_field")
                )

                OutlinedTextField(
                    value = model,
                    onValueChange = { model = it },
                    label = { Text("Model Spec") },
                    singleLine = true,
                    modifier = Modifier.fillMaxWidth().testTag("add_bike_model_field")
                )

                Text("Category Selection", style = MaterialTheme.typography.titleSmall)
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    categories.forEach { cat ->
                        FilterChip(
                            selected = category == cat,
                            onClick = { category = cat },
                            label = { Text(cat) },
                            modifier = Modifier.testTag("add_bike_chip_$cat")
                        )
                    }
                }

                OutlinedTextField(
                    value = chargeString,
                    onValueChange = { chargeString = it },
                    label = { Text("Hourly Rate ($)") },
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                    singleLine = true,
                    modifier = Modifier.fillMaxWidth().testTag("add_bike_charge_field")
                )

                OutlinedTextField(
                    value = location,
                    onValueChange = { location = it },
                    label = { Text("Initial Parking Location") },
                    singleLine = true,
                    modifier = Modifier.fillMaxWidth().testTag("add_bike_location_field")
                )
            }
        },
        confirmButton = {
            Button(
                onClick = {
                    val charge = chargeString.toDoubleOrNull() ?: 10.0
                    onSave(name, model, category, charge, location)
                },
                enabled = name.isNotBlank() && location.isNotBlank(),
                modifier = Modifier.testTag("add_bike_confirm_btn")
            ) {
                Text("Register")
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) {
                Text("Cancel")
            }
        }
    )
}

@Composable
fun CustomersTab(viewModel: BikeViewModel) {
    val riders by viewModel.allCustomers.collectAsState()

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background)
    ) {
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .background(MaterialTheme.colorScheme.surface)
                .padding(horizontal = 20.dp, vertical = 16.dp)
                .statusBarsPadding()
        ) {
            Text(
                text = "Registered Riders",
                style = MaterialTheme.typography.headlineSmall.copy(fontWeight = FontWeight.Bold),
                color = MaterialTheme.colorScheme.onBackground
            )
        }

        if (riders.isEmpty()) {
            Box(
                modifier = Modifier.fillMaxSize(),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    text = "No customer accounts registered yet",
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onBackground.copy(alpha = 0.5f)
                )
            }
        } else {
            LazyColumn(
                modifier = Modifier.fillMaxSize(),
                contentPadding = PaddingValues(20.dp),
                verticalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                items(riders) { user ->
                    Card(
                        modifier = Modifier.fillMaxWidth(),
                        shape = RoundedCornerShape(12.dp),
                        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface)
                    ) {
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(16.dp),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Box(
                                modifier = Modifier
                                    .size(44.dp)
                                    .clip(CircleShape)
                                    .background(MaterialTheme.colorScheme.primaryContainer),
                                contentAlignment = Alignment.Center
                            ) {
                                Text(
                                    text = user.name.take(1).uppercase(),
                                    style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold),
                                    color = MaterialTheme.colorScheme.onPrimaryContainer
                                )
                            }
                            Spacer(modifier = Modifier.width(16.dp))
                            Column {
                                Text(
                                    text = user.name,
                                    style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold),
                                    color = MaterialTheme.colorScheme.onSurface
                                )
                                Text(
                                    text = user.email,
                                    style = MaterialTheme.typography.bodySmall,
                                    color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f)
                                )
                                Text(
                                    text = "Phone: ${user.phone}",
                                    style = MaterialTheme.typography.bodySmall,
                                    color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.5f)
                                )
                            }
                        }
                    }
                }
            }
        }
    }
}

@Composable
fun MetricCard(
    title: String,
    value: String,
    icon: ImageVector,
    tint: Color,
    modifier: Modifier = Modifier
) {
    Card(
        modifier = modifier,
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = title,
                    style = MaterialTheme.typography.labelSmall,
                    color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.5f)
                )
                Icon(
                    imageVector = icon,
                    contentDescription = null,
                    tint = tint,
                    modifier = Modifier.size(18.dp)
                )
            }
            Spacer(modifier = Modifier.height(12.dp))
            Text(
                text = value,
                style = MaterialTheme.typography.titleLarge.copy(fontWeight = FontWeight.Bold),
                color = MaterialTheme.colorScheme.onSurface
            )
        }
    }
}
