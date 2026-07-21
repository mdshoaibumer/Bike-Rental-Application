package com.aistudio.bikerental.pzkbyq.features.bike.domain

import kotlinx.serialization.Serializable

@Serializable
data class BikeModel(
    val uuid: String,
    val name: String,
    val brand: String,
    val category: String,
    val engineCc: Int,
    val transmission: String, // Manual, Automatic
    val fuelType: String, // Petrol, Electric
    val mileage: Double, // kmpl or km per charge
    val rentalPrice: Int,
    val securityDeposit: Int,
    val status: BikeStatus,
    val description: String,
    val imageUrls: List<String>,
    val rating: Double
)

enum class BikeStatus {
    AVAILABLE,
    RESERVED,
    MAINTENANCE,
    INACTIVE
}

enum class SortOrder {
    PRICE_LOW_HIGH,
    PRICE_HIGH_LOW,
    NEWEST,
    POPULARITY,
    ENGINE_CC,
    ALPHABETICAL
}

data class FilterCriteria(
    val query: String = "",
    val categories: Set<String> = emptySet(),
    val brands: Set<String> = emptySet(),
    val minPrice: Int? = null,
    val maxPrice: Int? = null,
    val minCc: Int? = null,
    val maxCc: Int? = null,
    val fuelTypes: Set<String> = emptySet(),
    val onlyAvailable: Boolean = false
)
