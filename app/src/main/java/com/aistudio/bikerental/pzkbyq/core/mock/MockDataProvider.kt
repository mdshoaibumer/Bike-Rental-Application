package com.aistudio.bikerental.pzkbyq.core.mock

import com.aistudio.bikerental.pzkbyq.features.bike.domain.BikeModel
import com.aistudio.bikerental.pzkbyq.features.bike.domain.BikeStatus
import java.util.UUID

object MockDataProvider {

    // Helper to generate generic mock descriptions
    private fun desc(name: String) = "The $name is one of the most reliable and popular bikes in India, offering excellent mileage, smooth handling, and premium comfort for both daily commutes and long rides."

    val bikes: List<BikeModel> = listOf(
        // Scooters
        BikeModel(UUID.randomUUID().toString(), "Activa 6G", "Honda", "Scooter", 110, "Automatic", "Petrol", 45.0, 350, 1000, BikeStatus.AVAILABLE, desc("Activa 6G"), listOf("https://example.com/activa.jpg"), 4.8),
        BikeModel(UUID.randomUUID().toString(), "Jupiter", "TVS", "Scooter", 110, "Automatic", "Petrol", 50.0, 350, 1000, BikeStatus.AVAILABLE, desc("Jupiter"), listOf("https://example.com/jupiter.jpg"), 4.6),
        BikeModel(UUID.randomUUID().toString(), "Access 125", "Suzuki", "Scooter", 125, "Automatic", "Petrol", 45.0, 400, 1200, BikeStatus.AVAILABLE, desc("Access 125"), listOf("https://example.com/access.jpg"), 4.7),
        BikeModel(UUID.randomUUID().toString(), "Dio", "Honda", "Scooter", 110, "Automatic", "Petrol", 48.0, 350, 1000, BikeStatus.RESERVED, desc("Dio"), listOf("https://example.com/dio.jpg"), 4.5),
        BikeModel(UUID.randomUUID().toString(), "RayZR", "Yamaha", "Scooter", 125, "Automatic", "Petrol", 45.0, 400, 1200, BikeStatus.AVAILABLE, desc("RayZR"), listOf("https://example.com/rayzr.jpg"), 4.4),

        // Electric
        BikeModel(UUID.randomUUID().toString(), "Ather 450X", "Ather", "Electric", 0, "Automatic", "Electric", 105.0, 500, 1500, BikeStatus.AVAILABLE, desc("Ather 450X"), listOf("https://example.com/ather.jpg"), 4.8),
        BikeModel(UUID.randomUUID().toString(), "iQube", "TVS", "Electric", 0, "Automatic", "Electric", 100.0, 450, 1500, BikeStatus.AVAILABLE, desc("iQube"), listOf("https://example.com/iqube.jpg"), 4.6),
        BikeModel(UUID.randomUUID().toString(), "S1 Pro", "Ola", "Electric", 0, "Automatic", "Electric", 130.0, 500, 1500, BikeStatus.MAINTENANCE, desc("S1 Pro"), listOf("https://example.com/ola.jpg"), 4.2),
        BikeModel(UUID.randomUUID().toString(), "Chetak", "Bajaj", "Electric", 0, "Automatic", "Electric", 90.0, 450, 1500, BikeStatus.AVAILABLE, desc("Chetak"), listOf("https://example.com/chetak.jpg"), 4.5),

        // Commuter
        BikeModel(UUID.randomUUID().toString(), "Splendor Plus", "Hero", "Commuter", 100, "Manual", "Petrol", 65.0, 300, 1000, BikeStatus.AVAILABLE, desc("Splendor Plus"), listOf("https://example.com/splendor.jpg"), 4.9),
        BikeModel(UUID.randomUUID().toString(), "Shine", "Honda", "Commuter", 125, "Manual", "Petrol", 55.0, 350, 1000, BikeStatus.AVAILABLE, desc("Shine"), listOf("https://example.com/shine.jpg"), 4.7),
        BikeModel(UUID.randomUUID().toString(), "Raider", "TVS", "Commuter", 125, "Manual", "Petrol", 57.0, 400, 1200, BikeStatus.RESERVED, desc("Raider"), listOf("https://example.com/raider.jpg"), 4.8),
        BikeModel(UUID.randomUUID().toString(), "Platina 110", "Bajaj", "Commuter", 110, "Manual", "Petrol", 70.0, 300, 1000, BikeStatus.AVAILABLE, desc("Platina 110"), listOf("https://example.com/platina.jpg"), 4.5),

        // Sports
        BikeModel(UUID.randomUUID().toString(), "R15 V4", "Yamaha", "Sports", 155, "Manual", "Petrol", 40.0, 800, 2500, BikeStatus.AVAILABLE, desc("R15 V4"), listOf("https://example.com/r15.jpg"), 4.8),
        BikeModel(UUID.randomUUID().toString(), "RC 200", "KTM", "Sports", 200, "Manual", "Petrol", 35.0, 900, 3000, BikeStatus.AVAILABLE, desc("RC 200"), listOf("https://example.com/rc200.jpg"), 4.6),
        BikeModel(UUID.randomUUID().toString(), "Apache RTR 200", "TVS", "Sports", 200, "Manual", "Petrol", 38.0, 750, 2000, BikeStatus.INACTIVE, desc("Apache RTR 200"), listOf("https://example.com/apache200.jpg"), 4.7),
        BikeModel(UUID.randomUUID().toString(), "Pulsar NS200", "Bajaj", "Sports", 200, "Manual", "Petrol", 35.0, 750, 2000, BikeStatus.AVAILABLE, desc("Pulsar NS200"), listOf("https://example.com/ns200.jpg"), 4.6),

        // Cruiser
        BikeModel(UUID.randomUUID().toString(), "Classic 350", "Royal Enfield", "Cruiser", 350, "Manual", "Petrol", 35.0, 1000, 3000, BikeStatus.AVAILABLE, desc("Classic 350"), listOf("https://example.com/classic350.jpg"), 4.9),
        BikeModel(UUID.randomUUID().toString(), "Meteor 350", "Royal Enfield", "Cruiser", 350, "Manual", "Petrol", 35.0, 1000, 3000, BikeStatus.RESERVED, desc("Meteor 350"), listOf("https://example.com/meteor350.jpg"), 4.8),
        BikeModel(UUID.randomUUID().toString(), "CB350 H'ness", "Honda", "Cruiser", 350, "Manual", "Petrol", 38.0, 1000, 3000, BikeStatus.AVAILABLE, desc("CB350 H'ness"), listOf("https://example.com/cb350.jpg"), 4.7),
        BikeModel(UUID.randomUUID().toString(), "Avenger 220", "Bajaj", "Cruiser", 220, "Manual", "Petrol", 40.0, 700, 2000, BikeStatus.AVAILABLE, desc("Avenger 220"), listOf("https://example.com/avenger.jpg"), 4.4),

        // Adventure
        BikeModel(UUID.randomUUID().toString(), "Himalayan 450", "Royal Enfield", "Adventure", 450, "Manual", "Petrol", 30.0, 1500, 5000, BikeStatus.AVAILABLE, desc("Himalayan 450"), listOf("https://example.com/himalayan450.jpg"), 4.9),
        BikeModel(UUID.randomUUID().toString(), "XPulse 200", "Hero", "Adventure", 200, "Manual", "Petrol", 40.0, 800, 2000, BikeStatus.AVAILABLE, desc("XPulse 200"), listOf("https://example.com/xpulse.jpg"), 4.7),
        BikeModel(UUID.randomUUID().toString(), "390 Adventure", "KTM", "Adventure", 373, "Manual", "Petrol", 25.0, 1600, 5000, BikeStatus.RESERVED, desc("390 Adventure"), listOf("https://example.com/390adv.jpg"), 4.8),
        BikeModel(UUID.randomUUID().toString(), "V-Strom SX", "Suzuki", "Adventure", 250, "Manual", "Petrol", 35.0, 1200, 4000, BikeStatus.AVAILABLE, desc("V-Strom SX"), listOf("https://example.com/vstrom.jpg"), 4.6)
    )
}
