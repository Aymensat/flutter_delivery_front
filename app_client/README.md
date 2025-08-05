# Food Delivery App - Client

This is a Flutter-based mobile application for a food delivery service. It allows users to browse restaurants, order food, and track their deliveries. This document provides a comprehensive overview of the project's current state, including working features, missing functionalities, and potential improvements.

## Table of Contents

- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
- [Current Features](#current-features)
  - [Authentication](#authentication)
  - [Restaurant & Food Browsing](#restaurant--food-browsing)
  - [Shopping Cart](#shopping-cart)
  - [Ordering & Checkout](#ordering--checkout)
  - [Order Management](#order-management)
  - [User Profile](#user-profile)
- [Missing Features & Future Improvements](#missing-features--future-improvements)
  - [Functionality](#functionality)
  - [UI/UX](#uiux)
- [Key Project Decisions & Architecture](#key-project-decisions--architecture)

## Getting Started

### Prerequisites

- Flutter SDK (version 3.8.1 or higher)
- An emulator or physical device running Android or iOS
- A running instance of the backend server

### Installation

1.  **Clone the repository:**
    ```bash
    git clone <repository-url>
    cd app_client
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Run the app:**
    ```bash
    flutter run
    ```

## Current Features

### Authentication

-   **User Registration:** Users can create an account as either a "Customer" or a "Delivery Driver".
-   **User Login:** Registered users can log in to their accounts.
-   **Session Management:** The app keeps users logged in across sessions.

### Restaurant & Food Browsing

-   **Restaurant List:** The home screen displays a list of available restaurants.
-   **Search & Filter:** Users can search for restaurants and filter them by cuisine type.
-   **Restaurant Details:** View detailed information about a restaurant, including its address, contact information, and menu.
-   **Food Details:** View details about a specific food item, including its description, price, and ingredients.
-   **Ingredient Exclusion:** Users can choose to exclude certain ingredients from their food items.

### Shopping Cart

-   **Add to Cart:** Users can add food items to their shopping cart.
-   **Update Cart:** Users can update the quantity of items in their cart or remove them.
-   **Persistent Cart:** The cart's state is saved and restored when the user re-opens the app.

### Ordering & Checkout

-   **Cash on Delivery:** The app supports a "Cash on Delivery" payment method.
-   **GPS Location:** The user's current location is automatically fetched and used as the delivery address.
-   **Order Placement:** Users can place orders from their cart.

### Order Management

-   **Order History:** Users can view a list of their past and current orders.
-   **Order Details:** Users can view the details of a specific order, including the items, total price, and status.
-   **Mock Delivery Tracking:** A simulated delivery tracking screen shows the supposed real-time location of the delivery person on a map.

### User Profile

-   **View Profile:** Users can view their profile information.
-   **Update Profile:** Users can update their first name, last name, email, and phone number.
-   **Profile Image Upload:** Users can upload a profile picture.

## Missing Features & Future Improvements

### Functionality

-   **Real-time Delivery Tracking:** The current delivery tracking is a simulation. A real-time location tracking system needs to be implemented on the backend and integrated with the app.
-   **Online Payments:** The app only supports cash on delivery. Integrating a payment gateway for online payments is a crucial next step.
-   **Push Notifications:** While Firebase Messaging is set up, there is no implementation for sending or receiving notifications for order status updates.
-   **Forgot Password:** The "Forgot Password" functionality is not implemented.
-   **Social Login:** The UI for Google and Facebook login exists, but the functionality is not implemented.
-   **Reviews:** The ability to write reviews is present on the restaurant detail screen, but it should be moved to the order detail screen and linked to a specific order.
-   **Error Handling:** While some error handling is in place, it can be improved to be more robust and user-friendly across the app.
-   **Address Management:** Users should be able to save and manage multiple delivery addresses.

### UI/UX

-   **Improved Design:** The overall UI/UX can be enhanced to be more modern and visually appealing.
-   **Empty States:** More informative and visually appealing "empty state" screens (e.g., for an empty cart or no orders) can be designed.
-   **Loading Indicators:** More sophisticated loading indicators (e.g., shimmer effects) can be used to improve the user experience during data fetching.
-   **Image Handling:** A more robust solution for image loading and caching can be implemented to improve performance and reduce network usage.
-   **Accessibility:** The app should be audited and improved for accessibility.

## Key Project Decisions & Architecture

-   **State Management:** The project uses the `provider` package for state management.
-   **API Communication:** The `http` and `dio` packages are used for making API requests to the backend.
-   **Mapping:** `flutter_map` with OpenStreetMap is used for displaying maps to avoid Google Maps API key and billing complexities.
-   **Local Storage:** `shared_preferences` is used for storing simple data locally, such as the user's session token.
-   **Backend URL:** The app is configured to connect to a local backend server at `http://10.0.2.2:3000/api`.