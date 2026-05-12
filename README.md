# Service Provider Management App

A comprehensive Flutter-based solution for independent service providers and businesses to manage their schedules, services, and client interactions in real-time.

## 📌 Project Overview

This application is designed specifically for **Service Providers**. It empowers them to manage multiple services under a single profile, track earnings, set flexible working hours, and communicate directly with clients. Whether it's grooming, consulting, or any appointment-based professional service, this app provides the tools to streamline operations.

## ✨ Core Features

### 📅 Advanced Schedule Management
*   **Dynamic Calendar:** Integrated `table_calendar` to view daily and weekly appointments.
*   **Flexible Working Hours:** Toggle availability for specific days and set precise start/end times for each working day.
*   **Overview Analytics:** Track performance with statistics on successful bookings, canceled appointments, and total revenue.

### 🛠 Service Management
*   **Multi-Service Support:** Add and manage multiple services under a single provider account.
*   **Service Details:** Customizable service descriptions, durations, and pricing.
*   **Service Updates:** Easily edit or add new offerings as the business grows.

### 💬 Real-Time Communication
*   **Instant Messaging:** Built-in chat system using **Socket.io** for real-time client consultations and support.
*   **Notifications:** Push notifications via `flutter_local_notifications` to stay alerted about new bookings or messages.

### 🔍 Smart Tools
*   **QR Code Integration:** Quick check-ins and provider identification using `qr_code_scanner`.
*   **Geolocation:** Helping local clients find your services easily.
*   **Secure Auth:** Robust authentication including Google Sign-In and OTP verification.

## 🛠 Technical Stack

*   **Framework:** [Flutter](https://flutter.dev/) (v3.7.2+)
*   **State Management:** [GetX](https://pub.dev/packages/get) (Efficient state, dependency, and route management)
*   **Networking:** [Dio](https://pub.dev/packages/dio) with [Pretty Dio Logger](https://pub.dev/packages/pretty_dio_logger)
*   **Real-time Engine:** [Socket.io Client](https://pub.dev/packages/socket_io_client)
*   **Local Storage:** [GetStorage](https://pub.dev/packages/get_storage) & [Shared Preferences](https://pub.dev/packages/shared_preferences)
*   **UI/UX Highlights:** 
    *   `flutter_screenutil` for pixel-perfect responsive design.
    *   `google_fonts` for professional typography.
    *   `curved_navigation_bar` for an intuitive navigation experience.
    *   `cached_network_image` for optimized media performance.

## 🚀 Getting Started

### Prerequisites
*   Flutter SDK (^3.7.2)
*   Dart SDK
*   Android Studio / VS Code

### Installation
1.  **Clone the repository:**
    ```bash
    git clone <repository-url>
    ```
2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```
3.  **Setup Environment:**
    Create a `.env` file in the root directory and add your configuration (API Base URL, Socket URL, etc.)
4.  **Run the app:**
    ```bash
    flutter run
    ```

## 📂 Project Structure

```
lib/
├── component/       # Reusable UI widgets (Buttons, Text, etc.)
├── features/        # Feature-first modular architecture
│   ├── auth/        # Authentication & Registration
│   ├── overview/    # Business analytics & Schedule settings
│   ├── message/     # Real-time Chat system
│   ├── profile/     # Service & Profile management
│   └── home/        # Dashboard and booking overviews
├── services/        # API, Socket, and Notification services
└── utils/           # Themes, Constants, and Helpers
```

---
*Developed with Flutter for high-performance cross-platform utility.*
