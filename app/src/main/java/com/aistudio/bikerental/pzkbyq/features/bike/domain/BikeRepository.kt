package com.aistudio.bikerental.pzkbyq.features.bike.domain

import com.aistudio.bikerental.pzkbyq.core.common.Result

interface BikeRepository {
    suspend fun getFeaturedBikes(): Result<List<BikeModel>>
    suspend fun getPopularBikes(): Result<List<BikeModel>>
    suspend fun getRecentlyAddedBikes(): Result<List<BikeModel>>
    
    suspend fun getBikeById(uuid: String): Result<BikeModel>
    
    suspend fun searchAndFilterBikes(
        criteria: FilterCriteria,
        sortOrder: SortOrder
    ): Result<List<BikeModel>>
}
