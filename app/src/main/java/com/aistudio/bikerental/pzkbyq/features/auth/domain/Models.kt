package com.aistudio.bikerental.pzkbyq.features.auth.domain

import kotlinx.serialization.Serializable

@Serializable
data class CustomerProfile(
    val uuid: String,
    val name: String,
    val phone: String,
    val email: String,
    val address: String,
    val drivingLicenseNumber: String? = null,
    val profilePhotoUrl: String? = null
)

@Serializable
data class AdminProfile(
    val uuid: String,
    val name: String,
    val email: String,
    val phone: String,
    val businessName: String,
    val role: String
)
