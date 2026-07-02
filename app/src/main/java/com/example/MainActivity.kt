package com.example

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.viewModels
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.example.ui.screen.CustomerPortalScreen
import com.example.ui.screen.LoginScreen
import com.example.ui.screen.OwnerPortalScreen
import com.example.ui.theme.MyApplicationTheme
import com.example.ui.viewmodel.BikeViewModel
import com.example.ui.viewmodel.BikeViewModelFactory

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Support modern immersive full-screen layout
        enableEdgeToEdge()

        setContent {
            MyApplicationTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background
                ) {
                    val viewModel: BikeViewModel by viewModels {
                        BikeViewModelFactory(application)
                    }
                    BikeRentalApp(viewModel = viewModel)
                }
            }
        }
    }
}

@Composable
fun BikeRentalApp(viewModel: BikeViewModel) {
    val navController = rememberNavController()

    NavHost(
        navController = navController,
        startDestination = "login"
    ) {
        composable("login") {
            LoginScreen(
                viewModel = viewModel,
                onLoginSuccess = {
                    val user = viewModel.currentUser.value
                    if (user != null) {
                        if (user.role == "Owner") {
                            navController.navigate("owner") {
                                popUpTo("login") { inclusive = true }
                            }
                        } else {
                            navController.navigate("customer") {
                                popUpTo("login") { inclusive = true }
                            }
                        }
                    }
                }
            )
        }

        composable("customer") {
            CustomerPortalScreen(
                viewModel = viewModel,
                onLogout = {
                    viewModel.logout()
                    navController.navigate("login") {
                        popUpTo("customer") { inclusive = true }
                    }
                }
            )
        }

        composable("owner") {
            OwnerPortalScreen(
                viewModel = viewModel,
                onLogout = {
                    viewModel.logout()
                    navController.navigate("login") {
                        popUpTo("owner") { inclusive = true }
                    }
                }
            )
        }
    }
}
