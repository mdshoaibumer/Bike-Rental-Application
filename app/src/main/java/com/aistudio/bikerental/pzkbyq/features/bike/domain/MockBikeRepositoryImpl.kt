package com.aistudio.bikerental.pzkbyq.features.bike.domain

import com.aistudio.bikerental.pzkbyq.core.common.Result
import com.aistudio.bikerental.pzkbyq.core.mock.MockDataProvider
import kotlinx.coroutines.delay
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class MockBikeRepositoryImpl @Inject constructor() : BikeRepository {

    override suspend fun getFeaturedBikes(): Result<List<BikeModel>> {
        delay(800)
        // Return top 5 rated bikes
        return Result.Success(MockDataProvider.bikes.sortedByDescending { it.rating }.take(5))
    }

    override suspend fun getPopularBikes(): Result<List<BikeModel>> {
        delay(800)
        // Return 5 random bikes (mocking popular)
        return Result.Success(MockDataProvider.bikes.shuffled().take(5))
    }

    override suspend fun getRecentlyAddedBikes(): Result<List<BikeModel>> {
        delay(800)
        return Result.Success(MockDataProvider.bikes.takeLast(5))
    }

    override suspend fun getBikeById(uuid: String): Result<BikeModel> {
        delay(500)
        val bike = MockDataProvider.bikes.find { it.uuid == uuid }
        return if (bike != null) Result.Success(bike) else Result.Error("Bike not found")
    }

    override suspend fun searchAndFilterBikes(
        criteria: FilterCriteria,
        sortOrder: SortOrder
    ): Result<List<BikeModel>> {
        delay(1000)
        
        var filteredList = MockDataProvider.bikes

        // Filter by Query
        if (criteria.query.isNotBlank()) {
            val q = criteria.query.lowercase()
            filteredList = filteredList.filter { 
                it.name.lowercase().contains(q) || 
                it.brand.lowercase().contains(q) ||
                it.category.lowercase().contains(q)
            }
        }

        // Filter by Categories
        if (criteria.categories.isNotEmpty()) {
            filteredList = filteredList.filter { it.category in criteria.categories }
        }

        // Filter by Brands
        if (criteria.brands.isNotEmpty()) {
            filteredList = filteredList.filter { it.brand in criteria.brands }
        }

        // Filter by Price
        criteria.minPrice?.let { min ->
            filteredList = filteredList.filter { it.rentalPrice >= min }
        }
        criteria.maxPrice?.let { max ->
            filteredList = filteredList.filter { it.rentalPrice <= max }
        }

        // Filter by CC
        criteria.minCc?.let { min ->
            filteredList = filteredList.filter { it.engineCc >= min }
        }
        criteria.maxCc?.let { max ->
            filteredList = filteredList.filter { it.engineCc <= max }
        }

        // Filter by Fuel Type
        if (criteria.fuelTypes.isNotEmpty()) {
            filteredList = filteredList.filter { it.fuelType in criteria.fuelTypes }
        }

        // Filter Availability
        if (criteria.onlyAvailable) {
            filteredList = filteredList.filter { it.status == BikeStatus.AVAILABLE }
        }

        // Sorting
        filteredList = when (sortOrder) {
            SortOrder.PRICE_LOW_HIGH -> filteredList.sortedBy { it.rentalPrice }
            SortOrder.PRICE_HIGH_LOW -> filteredList.sortedByDescending { it.rentalPrice }
            SortOrder.NEWEST -> filteredList.shuffled() // Mock behavior
            SortOrder.POPULARITY -> filteredList.sortedByDescending { it.rating }
            SortOrder.ENGINE_CC -> filteredList.sortedByDescending { it.engineCc }
            SortOrder.ALPHABETICAL -> filteredList.sortedBy { it.name }
        }

        return Result.Success(filteredList)
    }
}
