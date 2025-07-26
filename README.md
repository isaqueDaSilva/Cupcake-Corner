# Cupcake Corner
A study-case app of selling cupcakes, whose goal was to combine all my knowledge in Swift and SwiftUI into an app that simulated real production environments, focusing on asynchronous programming, RESTful API integration, store sensitive data, load large set of data efficiently and MVVM architecture.

<a href="" rel="nofollow"><img src="https://camo.githubusercontent.com/498ead3b529283d08c8db814f646db66ac683bb6b8ced181087fdcde9106c241/68747470733a2f2f696d672e736869656c64732e696f2f656e64706f696e743f75726c3d687474707325334125324625324673776966747061636b616765696e6465782e636f6d2532466170692532467061636b616765732532466d316775656c706625324673776966742d7265616c74696d652d6f70656e616925324662616467652533467479706525334473776966742d76657273696f6e7326636f6c6f723d627269676874677265656e" alt="Swift Version" data-canonical-src="https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fm1guelpf%2Fswift-realtime-openai%2Fbadge%3Ftype%3Dswift-versions&amp;color=brightgreen" style="max-width: 100%;"></a>

## Table of Contents
1. [Features](#-features)
2. [Applied Knowledge](#-applied-knowledge)
3. [Technologies](#-technologies)
4. [Key Takeaways](#-key-takeaways)
5. [Dependencies](#dependencies)
6. [API](#api)
7. [Demo](#demo)

## 🚀 Features

- 🔒 Authentication with persistent login support (access token + refresh token);
- 📲 Secure storage of access tokens in the **Keychain**;
- 🧁 Interactive catalog with a variety of cupcakes;
- 📝 ​​Order customization (In progress to offer more customizations);
- 🔄 Real-time order status updates;
- 📋 List of orders already placed;

## 🧠 Applied Knowledge

### ✅ Secure Authentication
- Implementation of a login flow with secure storage of **access token** and **refresh token** in the Keychain;
- Clean logout with Keychain and session state clearing.

### ⚙️ Advanced Asynchronous Programming
- Intensive use of `async/await` for REST calls with refined error handling (`do-catch`, `try await`, `Task {}`);
- Update UI data with `@MainActor`.

### 🌐 Integration with RESTful API
- Modular HTTP call structure with support for authentication, dynamic headers, and JSON parsing with `Codable`;
- Endpoints separated by responsibility (authentication, requests, etc.);
- Support for pagination and incremental data loading.

### 📡 Real-time data
- Implementation of a **WebSockets** mechanism to track order status in real time.

### 📊 Large data sets
- Asynchronous pagination and on-demand loading to improve performance;
- Use of the `.onScrollVisibilityChange(threshold:)` modifier, which loads more data when 80% of the items are loaded, ensuring fluidity and responsiveness even with large lists. (We will use LazyVStack in the future, after figuring out what is causing items from pagination to not render.).

### 🏗️ Architecture
- Follows MVVM pattern to separate business logic, networking, and UI code.
- Promotes testability and scalability.

## 🔧 Technologies

- **Swift**
- **SwiftUI**
- **RESTful API**
- **Keychain** to keep sensitive data secure
- **Swift Concurrency**, `async/await`, `Task`, `Codable`, `MainActor`, `@Observable`

## 🧩 Key Takeaways

> 🔐 *"Working with Keychain was a game-changer for understanding how to ensure secure credential storage."*

> ⚡ *"I learned hands-on how to effectively manage asynchronous tasks with `async/await`, which gave me more control over concurrency and performance."*

> 🌐 *"Integrating with real REST APIs and handling authentication and token renewal errors prepared me for real-world challenges."*

> 📈 *"I optimized the user experience when working with large amounts of data without compromising performance."*

## 📱 Screenshots

## 📋 Future Improvements

- Support for iOS 26;
- Add unit tests;
- Continue improving the app's architecture.

## Dependencies
Swift Package Manager is used as a dependency manager.
## List of dependencies: 
* [KeychainService](https://github.com/isaqueDaSilva/KeychainService.git) -> My library, used to handle storing, retrieving, and deleting tokens from the Keychain.
* [Swift Collections](https://github.com/apple/swift-collections.git) -> A Swift library to add new data structures to the project.
* [Swift HTTP Types](https://github.com/apple/swift-http-types.git) -> A Swift library to handle with the network layer more easily and efficiently. 

## API 
* This projects is using a REST API
* Click [here](https://github.com/isaqueDaSilva/CupcakeCornerAPI) to access the repository of the RESTful API the powers this app.

## Demo
Click [here](https://youtu.be/HCnSd-yPiJk) to access a brief demonstration of the application in action <ins>*(New version of the demonstration coming soon after the full redesign.)*</ins> 
