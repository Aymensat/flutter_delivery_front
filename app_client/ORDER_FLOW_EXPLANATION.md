# Comprehensive Guide to Cart, Order, and Payment Flow

This document provides a thorough explanation of how the cart, order, and payment processes work together in this application, and in a typical food delivery app. The goal is to clarify the entire flow, from adding an item to the cart to the order being delivered.

---

## Section 1: The Core Relationship: Cart -> Order -> Payment

Think of this as a three-step process. Each step builds on the previous one.

1.  **Cart (The Shopping Basket):** This is the initial stage. The user browses restaurants and food items and adds what they want to their cart.
    *   **What it is:** A temporary, user-specific collection of items they intend to buy.
    *   **Key Information:**
        *   List of `Food` items.
        *   `Quantity` for each food item.
        *   Any specific customizations (like `excludedIngredients`).
        *   The `User` who owns the cart.
    *   **Backend Interaction:** The cart is usually saved to the database on the backend. This allows the user's cart to persist even if they close the app and come back later. Every time you add, remove, or update an item, the app communicates with the backend via the `CartService`.

2.  **Order (The Confirmation):** This is the point of no return. When the user proceeds from the checkout screen, the temporary cart is converted into a permanent `Order`.
    *   **What it is:** A formal record of the transaction that has been initiated. It's a snapshot of the cart at a specific moment, combined with all the necessary details for fulfillment.
    *   **Key Information:**
        *   A unique `OrderID` (and often a human-readable `reference` number).
        *   The `User` who placed the order.
        *   The `Restaurant` that will fulfill the order.
        *   A detailed list of `OrderItems` (copied from the cart).
        *   **Crucial Delivery Details:** The user's precise delivery address (`latitude`, `longitude`, and a text address).
        *   **Crucial Contact Details:** The user's `phone` number.
        *   Financial details (`subtotal`, `deliveryFee`, `taxes`, `totalPrice`).
        *   `PaymentMethod` chosen (e.g., 'credit-card').
        *   Initial `status` (e.g., 'pending').
    *   **Backend Interaction:** The app sends all this information to the backend via the `OrderService`. The backend validates the data, saves it as a new `Order` document in the database, and sends a confirmation back to the app.

3.  **Payment (The Financial Transaction):** This step is tightly coupled with the Order. It handles the process of charging the user.
    *   **What it is:** The process of securing funds from the user for the created `Order`.
    *   **Key Information:**
        *   The `OrderID` this payment is for.
        *   The final `amount` to be charged.
        *   Payment details (e.g., credit card information).
        *   A `PaymentID` from the payment gateway.
        *   The `status` of the payment ('pending', 'paid', 'failed').
    *   **Backend Interaction:** This is a critical and sensitive step. The backend's `PaymentService` communicates with an external payment gateway (like Stripe, PayPal, or a Tunisian bank's API). It sends the payment details and amount, and the gateway responds with success or failure.

---

## Section 2: The Delivery Driver's Journey

This section answers the question: **"When does the delivery driver start moving?"**

The answer is: **The driver moves only after the payment is secured.**

Here is the detailed, step-by-step process:

1.  **User Places Order:** The user taps "Place Order" on the `CheckoutScreen`.
2.  **Order Created with `pending` status:** The app sends the order details to our backend. The backend creates the `Order` with `status: 'pending'` and `paymentStatus: 'pending'`.
3.  **Payment Initiated:** Immediately after creating the order, the backend initiates the payment process with the payment gateway.
4.  **Payment Gateway Responds:**
    *   **Success:** The gateway confirms the payment was successful. The backend then updates the `Order`'s `paymentStatus` to `'paid'`.
    *   **Failure:** The gateway reports a failure. The backend updates the `Order`'s `paymentStatus` to `'failed'`. The user is notified in the app and asked to try a different payment method. The order does not proceed.
5.  **Alerting the Restaurant and Drivers (ONLY on Success):** Once the `paymentStatus` is `'paid'`, the system springs into action:
    *   The `Restaurant` is notified of the new order and starts preparing the food. The order `status` might change to `'preparing'`.
    *   The system simultaneously looks for available `Livreurs` (delivery drivers) near the restaurant.
6.  **Driver Accepts:** An available driver accepts the delivery. The system assigns the driver to the order, and the order `status` changes to `'confirmed'` or `'picked_up'` once they have the food.
7.  **Driver Moves:** **This is the point the driver starts moving.** They travel from the restaurant to the customer's location. The app can now show the driver's location on the `OrderTrackingScreen`.

---

## Section 3: Handling User Details (Address & Payment Info)

This section answers: **"How are the delivery address and credit card number retrieved?"**

You are correct, these details **must be exact and confirmed at the moment of ordering.** The current implementation uses placeholders for development speed, but here is how it should work in the final app.

### Delivery Address

*   **How it's supposed to work:**
    1.  **Saved Addresses:** The user should have a "Profile" or "Settings" section in the app where they can save one or more delivery addresses. These are stored securely on the backend and associated with their `User` profile.
    2.  **GPS for Current Location:** For convenience, the app should also be able to use the phone's GPS to get the user's *current* location. The `geolocator` package is perfect for this. It would get the `latitude` and `longitude`, and we could use a reverse geocoding service to get a human-readable address.
    3.  **Selection at Checkout:** On the `CheckoutScreen`, instead of a static placeholder, the user would be presented with:
        *   A dropdown or list of their saved addresses.
        *   An option to "Use my current location".
        *   An option to "Add a new address".
    4.  **Confirmation:** The selected address (including precise lat/lon) is what gets sent to the backend when the `Order` is created.

*   **Current State in Our App:** The `CheckoutScreen` currently shows a hardcoded placeholder address. This needs to be replaced with the dynamic selection logic described above.

### Payment Information (Credit Card)

*   **How it's supposed to work (Securely!):**
    1.  **NEVER Store Full Card Details:** You should **NEVER** store the user's full credit card number or CVC on your backend servers. This is a massive security risk and violates PCI compliance standards.
    2.  **Using a Payment Gateway:** The correct way is to use a trusted payment gateway's SDK (Software Development Kit) in the app.
    3.  **The Tokenization Flow:**
        *   On the `CheckoutScreen`, the user enters their card details into UI components provided by the payment gateway's SDK.
        *   These details are sent **directly from the app to the payment gateway**, bypassing your backend.
        *   The gateway securely saves the card details and sends back a safe, reusable "token" (e.g., `tok_1J2x...`).
        *   Your app then sends this *token*—not the card details—to your backend.
    4.  **Charging the User:** When the order is placed, your backend tells the payment gateway: "Charge the user associated with *this token* this much money."
    5.  **Saved Cards:** For convenience, these tokens can be saved on the backend, associated with the user, allowing for "one-click" checkout in the future. You would only store the token, the card type (Visa), and the last 4 digits, which the gateway provides.

*   **Current State in Our App:** The `CheckoutScreen` shows a placeholder card number. The `Payment` model we have is for our *simulated* payment flow. To make this real, we would need to integrate a real payment gateway SDK and replace the placeholder UI.
