package com.aistudio.bikerental.pzkbyq.core.navigation

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import com.aistudio.bikerental.pzkbyq.core.common.UserRole
import com.aistudio.bikerental.pzkbyq.core.storage.SessionManager
import com.aistudio.bikerental.pzkbyq.features.auth.ui.admin.AdminLoginScreen
import com.aistudio.bikerental.pzkbyq.features.auth.ui.admin.ForgotPasswordScreen
import com.aistudio.bikerental.pzkbyq.features.auth.ui.customer.CustomerLoginScreen
import com.aistudio.bikerental.pzkbyq.features.auth.ui.customer.CustomerOtpScreen
import kotlinx.coroutines.delay

@Composable
fun BikeRentalNavHost(
    navController: NavHostController,
    sessionManager: SessionManager
) {
    val isLoggedIn by sessionManager.isLoggedIn.collectAsState(initial = null)
    val userRole by sessionManager.userRole.collectAsState(initial = null)

    NavHost(
        navController = navController,
        startDestination = "splash"
    ) {
        composable("splash") {
            Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                CircularProgressIndicator()
            }
            LaunchedEffect(isLoggedIn, userRole) {
                delay(1000) // minimum splash delay
                if (isLoggedIn == true) {
                    if (userRole == UserRole.ADMIN) {
                        navController.navigate("admin_graph") { popUpTo("splash") { inclusive = true } }
                    } else {
                        navController.navigate("customer_graph") { popUpTo("splash") { inclusive = true } }
                    }
                } else if (isLoggedIn == false) {
                    navController.navigate("auth_graph") { popUpTo("splash") { inclusive = true } }
                }
            }
        }

        composable("auth_graph") {
            // By default, showing customer login. An option could switch to admin login.
            CustomerLoginScreen(
                onNavigateToOtp = { navController.navigate("customer_otp") }
            )
        }
        
        composable("customer_otp") {
            CustomerOtpScreen(
                onLoginSuccess = { navController.navigate("customer_graph") { popUpTo("auth_graph") { inclusive = true } } }
            )
        }
        
        composable("admin_login") {
            AdminLoginScreen(
                onLoginSuccess = { navController.navigate("admin_graph") { popUpTo("auth_graph") { inclusive = true } } },
                onNavigateToForgotPassword = { navController.navigate("admin_forgot_password") }
            )
        }
        
        composable("admin_forgot_password") {
            ForgotPasswordScreen(
                onNavigateBack = { navController.popBackStack() }
            )
        }

        composable("customer_graph") {
            // Customer Home Placeholder (Normally would use nested navigation here, but keeping it flat for simplicity in MVP flow)
            HomeScreen(
                onNavigateToSearch = { navController.navigate("search") },
                onNavigateToBikeDetails = { bikeId -> navController.navigate("bike_details/$bikeId") }
            )
        }
        
        composable("search") {
            SearchScreen(
                onNavigateBack = { navController.popBackStack() },
                onNavigateToBikeDetails = { bikeId -> navController.navigate("bike_details/$bikeId") }
            )
        }
        
        composable("bike_details/{bikeId}") { backStackEntry ->
            val bikeId = backStackEntry.arguments?.getString("bikeId") ?: return@composable
            BikeDetailsScreen(
                onNavigateBack = { navController.popBackStack() },
                onBookNow = { navController.navigate("booking_form/$bikeId") }
            )
        }

        composable("booking_form/{bikeId}") { backStackEntry ->
            BookingFormScreen(
                onNavigateBack = { navController.popBackStack() },
                onNavigateToSummary = { navController.navigate("booking_summary") }
            )
        }

        composable("booking_summary") {
            BookingSummaryScreen(
                onNavigateBack = { navController.popBackStack() },
                onNavigateToSuccess = { navController.navigate("booking_success") { popUpTo("customer_graph") { inclusive = false } } }
            )
        }

        composable("booking_success") {
            BookingSuccessScreen(
                onNavigateHome = { navController.navigate("customer_graph") { popUpTo(0) } },
                onNavigateToHistory = { navController.navigate("booking_history") { popUpTo(0) } }
            )
        }

        composable("booking_history") {
            BookingHistoryScreen(
                onNavigateToDetails = { bookingId -> navController.navigate("booking_details/$bookingId") }
            )
        }

        composable("booking_details/{bookingId}") {
            BookingDetailsScreen(
                onNavigateBack = { navController.popBackStack() }
            )
        }

        composable("admin_graph") {
            AdminDashboardScreen(
                onNavigateToBikes = { navController.navigate("admin_bikes") },
                onNavigateToBookings = { navController.navigate("admin_bookings") },
                onNavigateToCustomers = { navController.navigate("admin_customers") }
            )
        }

        composable("admin_bikes") {
            AdminBikeListScreen(
                onNavigateBack = { navController.popBackStack() },
                onNavigateToAddBike = { navController.navigate("admin_bike_form") },
                onNavigateToEditBike = { bikeId -> navController.navigate("admin_bike_form?bikeId=$bikeId") }
            )
        }

        composable("admin_bike_form?bikeId={bikeId}") {
            AdminBikeFormScreen(
                onNavigateBack = { navController.popBackStack() }
            )
        }

        composable("admin_bookings") {
            AdminBookingListScreen(
                onNavigateBack = { navController.popBackStack() },
                onNavigateToDetails = { bookingId -> navController.navigate("admin_booking_details/$bookingId") }
            )
        }

        composable("admin_booking_details/{bookingId}") {
            AdminBookingDetailsScreen(
                onNavigateBack = { navController.popBackStack() }
            )
        }

        composable("admin_customers") {
            CustomerListScreen(
                onNavigateBack = { navController.popBackStack() },
                onNavigateToProfile = { customerId -> navController.navigate("admin_customer_profile/$customerId") }
            )
        }

        composable("admin_customer_profile/{customerId}") {
            CustomerProfileScreen(
                onNavigateBack = { navController.popBackStack() }
            )
        }
    }
}
