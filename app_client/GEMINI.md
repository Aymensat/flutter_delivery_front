# Development Guidelines

- This `GEMINI.md` file serves as my memory. I will add to it as we build new features.
- Most files I need are under the `lib` folder.
- I will refer to `lib/openapi-v4.yaml` for the API specification.
- I will use extensive `debugPrint` logging to help with debugging.
- I will run `flutter analyze` frequently to catch compile-time errors early.
- You can help with runtime testing and provide feedback from backend logs (Express.js/MongoDB) and Postman tests.
- We are developing for an emulator, so the base API URL is `http://10.0.2.2:3000/api`. My IDE is VS Code.
- If I have any questions, doubts, or confusion, I will let you know.
- I will build the core order functionality first and treat the specific payment gateway integration as a separate module to be added later, given the complexities of integrating with Tunisian payment services.
- I will prioritize core functionality and major errors over minor `flutter analyze` warnings for now.

## Key Project Patterns & Decisions

- **Map Provider**: We use **OpenStreetMap** via the `flutter_map` package to avoid Google Maps API key and billing requirements. All new map features should use this package.
- **Cash on Delivery (COD) Orders**: The backend does **not** support a `cash` payment method directly. Our established workaround is:
    - The user selects "Cash on Delivery" in the UI.
    - When creating the order, the app sends `paymentMethod: 'credit-card'` (as a placeholder) and `paymentStatus: 'pending'` to the backend.
    - This allows the order to be created and tracked in the system while the actual payment is handled offline.
- **Dependency Management**: We must be mindful of dependency conflicts. When adding new packages, we will immediately run `flutter pub get` and `flutter analyze` to catch and resolve any versioning issues with existing packages like `http`.
- **Error Handling**: We will prioritize fixing compilation errors first, then address critical runtime errors (like the `LateInitializationError` we saw with the map controller), and finally, clean up warnings from the analyzer.

## Feature Roadmap

1.  **Cash Payments & GPS Location (Complete)**: 
    - Implemented a simplified cash-on-delivery option.
    - Integrated GPS functionality to retrieve and use the user's current location during checkout.
2.  **Delivery Tracking (In Progress)**: 
    - Display the delivery person's location on a map in real-time.
    - Add buttons to call the delivery person's phone number or send them a message on WhatsApp.

## Completed Refactoring: Google Maps to OpenStreetMap

-   **`pubspec.yaml`**: 
    -   Removed `google_maps_flutter` and added `flutter_map` and `latlong2`.
    -   Upgraded `http` package to resolve dependency conflicts.
-   **`android/app/src/main/AndroidManifest.xml`**:
    -   Removed the Google Maps API key `meta-data` tag.
-   **`lib/screens/location/location_screen.dart`**:
    -   Replaced `GoogleMap` with `FlutterMap` and corrected implementation.
-   **`lib/screens/orders/delivery_tracking_screen.dart`**:
    -   Replaced `GoogleMap` with `FlutterMap` and corrected implementation.

