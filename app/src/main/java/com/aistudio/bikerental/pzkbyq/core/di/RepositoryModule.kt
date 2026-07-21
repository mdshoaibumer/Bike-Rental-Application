package com.aistudio.bikerental.pzkbyq.core.di

import com.aistudio.bikerental.pzkbyq.features.auth.domain.ApiAuthRepositoryImpl
import com.aistudio.bikerental.pzkbyq.features.auth.domain.AuthRepository
import com.aistudio.bikerental.pzkbyq.features.bike.domain.ApiBikeRepositoryImpl
import com.aistudio.bikerental.pzkbyq.features.bike.domain.BikeRepository
import com.aistudio.bikerental.pzkbyq.features.booking.domain.ApiBookingRepositoryImpl
import com.aistudio.bikerental.pzkbyq.features.booking.domain.BookingRepository
import com.aistudio.bikerental.pzkbyq.features.admin.domain.ApiAdminRepositoryImpl
import com.aistudio.bikerental.pzkbyq.features.admin.domain.AdminRepository
import dagger.Binds
import dagger.Module
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
abstract class RepositoryModule {

    @Binds
    @Singleton
    abstract fun bindAuthRepository(
        authRepositoryImpl: ApiAuthRepositoryImpl
    ): AuthRepository

    @Binds
    @Singleton
    abstract fun bindBikeRepository(
        bikeRepositoryImpl: ApiBikeRepositoryImpl
    ): BikeRepository

    @Binds
    @Singleton
    abstract fun bindBookingRepository(
        bookingRepositoryImpl: ApiBookingRepositoryImpl
    ): BookingRepository

    @Binds
    @Singleton
    abstract fun bindAdminRepository(
        adminRepositoryImpl: ApiAdminRepositoryImpl
    ): AdminRepository
}
