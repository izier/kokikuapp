# Kokiku

**Kokiku** is a Flutter-based app designed to manage kitchen inventory and shopping lists. It helps users track ingredients, plan meals, and stay organized by creating shopping lists based on what’s in the fridge or pantry. The app features a user-friendly interface and utilizes BLoC for state management.

## Features

- **Inventory Management**: Track items in your kitchen with ease.
- **Shopping Lists**: Create and manage shopping lists for efficient grocery trips.
- **Google Sign-In**: User authentication via Google for a personalized experience.
- **Responsive UI**: A clean and responsive user interface for all screen sizes.

## Tech Stack

- **Flutter**: Framework for building natively compiled applications.
- **BLoC**: Business Logic Component for state management, providing separation of concerns and scalability.
- **Firebase**: Backend services for authentication, cloud storage, and real-time database.
- **Get_it**: Service locator for dependency injection and managing app-level dependencies.

## Installation

To run the Kokiku app locally, follow these steps:

1. Clone the repository:
    ```bash
    git clone https://github.com/yourusername/kokiku.git
    ```

2. Navigate to the project directory:
    ```bash
    cd kokiku
    ```

3. Install dependencies:
    ```bash
    flutter pub get
    ```

4. Run the app:
    ```bash
    flutter run
    ```

## Usage

- Sign in using your Google account to sync your data across devices.
- Add items to your inventory by entering the item name, quantity, and location.
- Use the shopping list feature to keep track of items to purchase.
- Easily access your inventory and manage it through a clean, intuitive interface.

## Contributing

Contributions are welcome! If you would like to contribute to the development of Kokiku, follow these steps:

1. Fork the repository.
2. Create a new branch (`git checkout -b feature-branch`).
3. Make your changes and commit them (`git commit -am 'Add new feature'`).
4. Push to the branch (`git push origin feature-branch`).
5. Open a pull request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgements

- **Flutter**: For providing a powerful, cross-platform mobile framework.
- **BLoC**: For providing a clean and scalable approach to state management.
- **Firebase**: For providing backend services such as authentication, cloud storage, and real-time database.
- **Get_it**: For simplifying dependency injection and managing app-level services.
