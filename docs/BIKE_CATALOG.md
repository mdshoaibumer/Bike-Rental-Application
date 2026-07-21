# Bike Catalog & Search Architecture

## Module Overview
The Bike Catalog module handles the discovery, searching, filtering, and detailed view of the bike inventory. It heavily relies on Jetpack Compose for reactive UI and Kotlin Coroutines/Flow for async state management.

## Screen Flow
1. **Home Screen (`HomeScreen.kt`)**: The landing page displaying curated lists of bikes (Featured, Popular Near You, Recently Added). 
2. **Search Screen (`SearchScreen.kt`)**: Accessed via the search icon on the Home Screen. Provides a full text search input and displays results in a responsive grid.
3. **Filter Bottom Sheet (`FilterBottomSheet.kt`)**: Accessed from the Search Screen, allows the user to apply multiple boolean and range constraints.
4. **Bike Details Screen (`BikeDetailsScreen.kt`)**: Displays comprehensive information regarding a single bike entity (Engine CC, Fuel, Price, Deposit).

## State Management (Search Flow)
State is managed within the `SearchViewModel`.
- `_searchQuery`: Holds the raw text input.
- `_filterCriteria`: Holds the `FilterCriteria` data class, maintaining sets of selected brands, categories, price ranges, and availability toggles.
- `_sortOrder`: Holds the `SortOrder` enum indicating how the results should be sorted (e.g. Price Low->High, Popularity).

When any of these variables change, `performSearch()` is called, which updates the `_uiState` to `UiState.Loading` while querying the `BikeRepository`.

## Future Backend Mapping
Currently, the application uses `MockBikeRepositoryImpl` and `MockDataProvider`. To transition this to a production backend:
1. Create a `RetrofitBikeService`.
2. Map `FilterCriteria` to query parameters (e.g., `GET /api/bikes?q=activa&minPrice=300&onlyAvailable=true`).
3. Bind `ApiBikeRepositoryImpl` via Hilt to replace the mock repository.
4. The ViewModels require zero modification as they are entirely decoupled from the data source via the `BikeRepository` interface and `Result<T>` wrapper.
