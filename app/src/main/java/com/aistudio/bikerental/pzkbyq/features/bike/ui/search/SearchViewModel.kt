package com.aistudio.bikerental.pzkbyq.features.bike.ui.search

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.aistudio.bikerental.pzkbyq.core.common.Result
import com.aistudio.bikerental.pzkbyq.core.common.UiState
import com.aistudio.bikerental.pzkbyq.features.bike.domain.BikeModel
import com.aistudio.bikerental.pzkbyq.features.bike.domain.BikeRepository
import com.aistudio.bikerental.pzkbyq.features.bike.domain.FilterCriteria
import com.aistudio.bikerental.pzkbyq.features.bike.domain.SortOrder
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class SearchViewModel @Inject constructor(
    private val bikeRepository: BikeRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow<UiState<List<BikeModel>>>(UiState.Loading)
    val uiState: StateFlow<UiState<List<BikeModel>>> = _uiState.asStateFlow()

    private val _searchQuery = MutableStateFlow("")
    val searchQuery: StateFlow<String> = _searchQuery.asStateFlow()

    private val _filterCriteria = MutableStateFlow(FilterCriteria())
    val filterCriteria: StateFlow<FilterCriteria> = _filterCriteria.asStateFlow()

    private val _sortOrder = MutableStateFlow(SortOrder.POPULARITY)
    val sortOrder: StateFlow<SortOrder> = _sortOrder.asStateFlow()

    init {
        performSearch()
    }

    fun updateQuery(query: String) {
        _searchQuery.value = query
        _filterCriteria.value = _filterCriteria.value.copy(query = query)
        performSearch()
    }

    fun updateFilters(criteria: FilterCriteria) {
        _filterCriteria.value = criteria.copy(query = _searchQuery.value)
        performSearch()
    }

    fun updateSortOrder(order: SortOrder) {
        _sortOrder.value = order
        performSearch()
    }

    private fun performSearch() {
        viewModelScope.launch {
            _uiState.value = UiState.Loading
            when (val result = bikeRepository.searchAndFilterBikes(_filterCriteria.value, _sortOrder.value)) {
                is Result.Success -> _uiState.value = UiState.Success(result.data)
                is Result.Error -> _uiState.value = UiState.Error(result.message)
            }
        }
    }
}
