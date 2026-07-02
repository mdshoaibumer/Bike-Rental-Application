# Product Roadmap v2.0 & Risk Register — Bike Rental Platform

This document describes the high-priority engineering objectives for Version 2.0 and details the Risk Register for managing production hazards.

---

## 1. Version 2.0 Strategic Roadmap

We evaluate future features based on their **Business Value (ROI)** and **Implementation Complexity (Effort)** to help plan the next development phase:

```
    High  │  ┌─────────────────────────┐     ┌─────────────────────────┐
          │  │  KYC Automation (OCR)   │     │     GPS IoT Tracking    │
          │  │  Value: High            │     │     Value: High         │
          │  │  Effort: Low-Medium      │     │     Effort: High        │
          │  └─────────────────────────┘     └─────────────────────────┘
          │
          │  ┌─────────────────────────┐     ┌─────────────────────────┐
B         │  │  Promo/Loyalty System   │     │  AI Customer Support    │
U         │  │  Value: Medium-High     │     │  Value: Medium          │
S  Value  │  │  Effort: Low            │     │  Effort: High           │
I         │  └─────────────────────────┘     └─────────────────────────┘
N         │
E         │  ┌─────────────────────────┐     ┌─────────────────────────┐
S         │  │  Multi-Branch Portal    │     │  Dynamic Pricing        │
S         │  │  Value: Medium          │     │  Value: Low-Medium      │
          │  │  Effort: Medium         │     │  Effort: Medium-High    │
          │  └─────────────────────────┘     └─────────────────────────┘
    Low   │
          └─────────────────────────────────────────────────────────────
                     Low/Medium                        High
                                IMPLEMENTATION EFFORT
```

### High Value, Low/Medium Effort (Quick Wins - Prioritize First)
1. **Automated OCR KYC Document Verification**
   - **Details**: Integrate Google Cloud Document AI or Onfido to automatically parse Driving Licenses and Aadhaar cards, cutting KYC approval times down from hours to seconds.
   - **Value**: High | **Effort**: Medium
2. **Referral and Promo Engine**
   - **Details**: Introduce user-specific promo codes and reward points to improve customer retention.
   - **Value**: High | **Effort**: Low

### High Value, High Effort (Strategic Investments)
3. **GPS Tracking & IoT Fleet Immobilizer**
   - **Details**: Install hardware GPS modules on bikes to track speed, map paths, and enable remote locking/unlocking directly from the Owner App.
   - **Value**: Critical (Reduces theft risks) | **Effort**: High

---

## 2. Risk Register & Mitigation Strategy

### R-01: Vehicle Theft or Abandonment
- **Impact**: High | **Probability**: Medium
- **Description**: Users may rent high-value motorcycles and fail to return them, or abandon them outside operating boundaries.
- **Mitigation Strategy**:
  1. Enforce strict KYC verification before allowing users to create bookings.
  2. Implement holding deposits on credit cards for premium vehicle rentals.
  3. (Roadmap v2.0) Install IoT geofenced GPS immobilizers.

### R-02: Double-Booking Collisions (Concurrency Spikes)
- **Impact**: Medium | **Probability**: Low
- **Description**: Two users may attempt to reserve the exact same motorcycle for overlapping dates simultaneously during high-demand events.
- **Mitigation Strategy**:
  1. The database utilizes strict transactions (`SELECT ... FOR UPDATE`) to lock bike rows during booking validation.
  2. A unique check constraint blocks overlapping rental schedules.

### R-03: Webhook Delivery Failures (State De-synchronization)
- **Impact**: High | **Probability**: Medium
- **Description**: Network issues may cause payment gateway webhooks to fail, leaving bookings in a "Pending" state even after the customer is charged.
- **Mitigation Strategy**:
  1. Handlers verify payments idempotently.
  2. Implement an automatic reconciliation cron job that queries the payment provider's API for any "Pending" bookings older than 15 minutes.
