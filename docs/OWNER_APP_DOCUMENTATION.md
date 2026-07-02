# Phase 11 — Owner/Admin Android Application

This document outlines the architecture, navigation paths, and feature layout of the Owner/Admin Flutter App designed for managing the bike rental fleet, customer requests, and financial performance.

## Key Screens Built
- **Splash Screen**: Brand representation with a 2-second timed initialization sequence routing users to authentication check.
- **Login Screen**: High-fidelity phone validation page accepting register requests and verification codes.
- **Dashboard Screen**: Rich Material 3 KPIs, operation counts, revenue trackers (Today, Monthly), and quick shortcuts to fleet and booking consoles.
- **Bike Management Screen**: Integrated list view, search-by-model query, and dropdown category filters. Features toggles for instant bike availability and dialog sheets to add a new asset to the fleet.
- **Booking Management Screen**: Real-time reservation panel structured with Status tabs (Pending, Confirmed, Active, Completed). Equips the owner with dynamic status actions (Approve, Reject, Mark Pickup, Mark Returned & Complete) and shows action logs.
- **Customer & KYC Console Screen**: Displays customer information, verification statuses (Pending, Approved, Rejected), options to view/verify Driving Licenses and Aadhaar cards, and toggle switches to Block or Unblock clients.
- **Settings Screen**: Fleet profile info, GSTIN verification, toggles for push alerts/email summaries, language selectors, and a secure Logout button.

## Architecture & Code Organization
The codebase resides under `/apps/owner_app/` and utilizes the `/shared/` library package to reuse material tokens, network client providers, and custom typography across platforms.
- `lib/core/router.dart`: Configures state-aware routing.
- `lib/features/auth/`: Splash & Login screen implementations.
- `lib/features/dashboard/`: Management statistics and metrics.
- `lib/features/bikes/`: Real-time inventory and availability.
- `lib/features/bookings/`: Request lifecycles and validation logs.
- `lib/features/customers/`: Verification status and compliance controls.
- `lib/features/settings/`: Preferences and business details.
