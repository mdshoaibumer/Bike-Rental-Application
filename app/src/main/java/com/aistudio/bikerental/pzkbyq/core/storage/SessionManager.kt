package com.aistudio.bikerental.pzkbyq.core.storage

import android.content.Context
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.booleanPreferencesKey
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import com.aistudio.bikerental.pzkbyq.core.common.UserRole
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import javax.inject.Inject
import javax.inject.Singleton

val Context.dataStore: DataStore<Preferences> by preferencesDataStore(name = "session_prefs")

@Singleton
class SessionManager @Inject constructor(
    @ApplicationContext private val context: Context
) {
    private val dataStore = context.dataStore

    companion object {
        val KEY_IS_LOGGED_IN = booleanPreferencesKey("is_logged_in")
        val KEY_USER_ROLE = stringPreferencesKey("user_role")
        val KEY_AUTH_TOKEN = stringPreferencesKey("auth_token")
        val KEY_USER_UUID = stringPreferencesKey("user_uuid")
    }

    val isLoggedIn: Flow<Boolean> = dataStore.data.map { preferences ->
        preferences[KEY_IS_LOGGED_IN] ?: false
    }

    val userRole: Flow<UserRole> = dataStore.data.map { preferences ->
        val roleStr = preferences[KEY_USER_ROLE] ?: UserRole.NONE.name
        UserRole.valueOf(roleStr)
    }

    val authToken: Flow<String?> = dataStore.data.map { preferences ->
        preferences[KEY_AUTH_TOKEN]
    }

    suspend fun saveSession(role: UserRole, token: String, uuid: String) {
        dataStore.edit { preferences ->
            preferences[KEY_IS_LOGGED_IN] = true
            preferences[KEY_USER_ROLE] = role.name
            preferences[KEY_AUTH_TOKEN] = token
            preferences[KEY_USER_UUID] = uuid
        }
    }

    suspend fun clearSession() {
        dataStore.edit { preferences ->
            preferences.clear()
        }
    }
}
