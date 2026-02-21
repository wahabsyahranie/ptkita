# Capstone Project – Layered Architecture Blueprint (CLA v1)

This project uses a structured layered architecture to ensure scalability, maintainability, and future backend flexibility.

---

## Architecture Overview

The application follows a layered pattern:

UI (Widgets)
↓
Service (Business Logic)
↓
Repository (Data Access)
↓
Data Source (Firestore / Excel / MySQL / API)

Each layer has a clear responsibility and must not violate separation rules.

---

## Layer Responsibilities

### UI Layer (Widgets / Pages)

Location:
lib/pages/

Responsibilities:

- Render UI
- Handle user interaction
- Consume data from Service layer
- Must NOT access Firestore, API, or database directly
- Must NOT contain business logic

Rules:

- No Firebase queries inside UI
- No Map<String, dynamic> parsing
- Use Models only

---

### Service Layer

Location:
lib/services/

Responsibilities:

- Business logic
- Data transformation
- Combining multiple repositories
- Calculations (progress, summary, filtering logic)

Service communicates only with Repository.

---

### Repository Layer

Location:
lib/repositories/

Responsibilities:

- Data access abstraction
- Communicate with database (Firestore, Excel, MySQL, API)
- Convert raw data into Models

All repositories must implement abstract classes.

Example:

abstract class HomeRepository {
Future<RepairSummaryModel> getRepairSummary(int days);
}

Concrete implementation:

class FirestoreHomeRepository implements HomeRepository

This allows easy backend replacement.

---

### Model Layer

Location:
lib/models/

Responsibilities:

- Data structure definition (DTO)
- Strong typing
- Optional computed properties

Models MUST NOT:

- Query database
- Contain business logic
- Know about Firestore

---

## Data Flow Example

HomePage
↓
HomeService
↓
FirestoreHomeRepository
↓
Firestore

---

## Design Principles

- UI is database-agnostic
- No vendor lock-in
- Future caching handled in initState()
- Streams only used for real-time data
- Modular widgets per page
- No business logic inside widgets

---

## Color System

Color palette is centralized in:

lib/styles/colors.dart

Status colors:

- success
- error
- warning
- info

Colors follow a warm-industrial theme to match brand identity.

---

## Backend Flexibility

Because of repository abstraction, backend can be replaced with:

- Excel local file
- MySQL server
- REST API
- Firebase
- Offline database

Without modifying UI layer.

---

## Naming Convention

All code variables use English naming.

Discussion may use Indonesian, but code must remain English.

---

## Current Architecture Version

Blueprint Name:
Capstone Layered Architecture v1 (CLA v1)

Any new feature must follow this blueprint.