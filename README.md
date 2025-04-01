# Table of Contents
1. [Description](#description)
2. [Getting started](#getting-started)
3. [Technologies](#technologies)
4. [Arhitecture](#arhitecture)
5. [Structure](#structure)
6. [Dependencies](#dependencies)
7. [API](#api)

# HelloWorld
An ergonomic application that make easy to manage all flow in a Cupcake store.

# Description
The Cupcake Corner project is design to solve the commun problems that a cupcake store can be.<br>
Think about, in a traditional Cupcake store, the clients needs to go there, talks to an attendant, that'll show all availables flavor, calculates the final price, based on customizations, prepare, and when it's read, they need to manually notify each client that your order is ready.<br>
So, with these problems in mind, Cupcake Corner comes into play, it's an easy-use application, that solve all mentionated problems with just a few clicks, for bolth client and admin sides.<br>
On client side, the user can access a list of flavors variety, choice what they want, customize, create your order, and check each order status update until it's stay read to be delivered.
On admin side, the user-admin can be create, update or delete cupcakes from the menu, check order flow and update status of an order.<br>
Finally, for both targets, the app gives a balance of all orders made by a client or in general if the user was a admin, if showing avarges, most sold/purchased cupcake flavor, total invoiced/spent for bolth clients and administrators can get insights from what they do.<br>

# Getting started
1. Make sure you have the Xcode version 16 or above installed on your computer.<br>
2. Downloads the Cupcake Corner project file from this repositorys.<br>
3. Opens the [Cupcake Corner API](https://github.com/isaqueDaSilva/CupcakeCornerAPI.git) repository and flow your instruction as well.<br>
4. Open the project files in Xcode.<br>
5. Review the code and make sure you understand what it does.
6. Run the CupcakeCorner and CupcakeCornerForAdmin targets.
    - Uses the admin credentials to log into admin target.

# Technologies
- Programming language: Swift;
- Frameworks: SwiftUI, SwiftData, SwiftCharts, Network, Security, CryptoKit;
- Web Communication: RESTful API
- Others: WebSocket

# Architecture
* Cupcake Corner is implemented using the <strong>Model-View-ViewModel (MVVM)</strong> architecture pattern.
    - Model has the base data need to generate each of them.<br>
    - View is responsible for displaying the requested list of data, given by the server request.<br>
    - ViewModel is responsable to process any user input behind the scenes, like refresh, post new data and more.<br>
* The project uses the SwiftData to persist on-device an user profile, that given back from the request.<br>

# Structure 
```
├── Common
|   ├── App
|   |   ├── MainEntrypoint.swift
|   |   ├── MainRootView.swift
|   |   └── SplashScreen.swift
|   ├── Core
|   |   ├── Components
|   |   |   ├── ActionButton.swift
|   |   |   |── CoverImageView.swift
|   |   |   ├── EditAccount.swift
|   |   |   |── EmptyStateView.swift
|   |   |   ├── Icon.swift
|   |   |   |── IngredientCell.swift
|   |   |   ├── LogoView.swift
|   |   |   |── OrderEmptyView.swift
|   |   |   └── TextFieldFocused.swift
|   |   └── Views
|   |       ├── Bag
|   |       |   ├── Components
|   |       |   |   ├── ItemCard.swift
|   |       |   |   └── OrderFilterPickerView.swift
|   |       |   ├── BagView.swift
|   |       |   └── BagView+ViewModel.swift
|   |       |── Balance
|   |       |   |── BalanceView.swift
|   |       |   └── BalanceView+ViewModel.swift
|   |       ├── Create Account
|   |       |   |── CreateAccountView.swift
|   |       |   └── CreateAccountView+ViewModel.swift
|   |       |── Cupcake
|   |       |   |── CupcakeView.swift
|   |       |   └── CupcakeView+ViewModel.swift
|   |       ├── Login View
|   |       |   |── LoginView.swift
|   |       |   └── LoginView+ViewModel.swift
|   |       |── Root
|   |       |   |── Components
|   |       |   |   └── TabSection.swift
|   |       |   └── RootView.swift
|   |       └── User Account
|   |           |── UserAccountView.swift
|   |           └── UserAccountView+ViewModel.swift
|   ├── Extensions
|   |   ├── CGSize+Extension.swift
|   |   |── Date+Extension.swift
|   |   ├── Dictionary+Extension.swift
|   |   |── Double+Extension.swift
|   |   ├── ExecutionError+Extension.swift
|   |   |── Image+Extension.swift
|   |   ├── TimeInterval+Extension.swift
|   |   |── UIImage+Extension.swift
|   |   └── View+Extension.swift
|   ├── Models
|   |   ├── Balance
|   |   |   |── Balance.swift
|   |   |   └── Balance+Get.swift
|   |   |── Cupcake
|   |   |   |── Cupcake.swift
|   |   |   └── Cupcake+ListResponse.swift
|   |   ├── Order
|   |   |   |── Order.swift
|   |   |   └── Order+ReadList.swift
|   |   |── Security
|   |   |   |── EncryptedField.swift
|   |   |   |── LoginResponse.swift
|   |   |   |── PublicKeyAgreement.swift
|   |   |   └── Token.swift
|   |   ├── User
|   |   |   |── User.swift
|   |   |   |── User+Create.swift
|   |   |   └── User+Get.swift
|   |   |── PaymentMethod.swift
|   |   ├── Role.swift
|   |   |── Status.swift
|   |   └── WebSocketMessage.swift
|   ├── Service
|   |   |── Encryptor.swift
|   |   └── SecureServerCommunication.swift
|   ├── Utilities
|   |   |── Network
|   |   |   |── EndpointBuilder.swift
|   |   |   └── Network.swift
|   |   ├── Preview
|   |   |   └── ModelContext+InMemory.swift
|   |   |── AppLogger.swift
|   |   ├── ImageResizer.swift
|   |   |── TokenGetter.swift
|   |   └── UserRepository.swift
|   └── Assets.xcassets
├── CupcakeCorner
|   |── App
|   |   └── CupcakeCornerApp.swift
|   |── Core
|   |   |── About Cupcake
|   |   |   └── AboutCupcakeView.swift
|   |   |── Components
|   |   |   |── InformationLabel.swift
|   |   |   └── SelectionPicker.swift
|   |   └── Orders
|   |       |── OrderView.swift
|   |       └── OrderView+ViewModel.swift
|   |── Model
|   |   └── Order+Create.swift
|   |── Preview Content
|   |   └── Preview Assets.xcassets
|   └── Info.plist   
├── CupcakeCornerForAdmin
|   |── App
|   |   └── CupcakeCornerForAdminApp.swift
|   |── Core
|   |   |── Components
|   |   |   |── EditCupcake.swift
|   |   |   └── IngredientsList.swift
|   |   |── Create Cupcake
|   |   |   |── CreateNewCupcakeView.swift
|   |   |   └── CreateNewCupcakeView+ViewModel.swift
|   |   |── Cupcake Deatail
|   |   |   |── CupcakeDetailView.swift
|   |   |   └── CupcakeDetailView+ViewModel.swift
|   |   └── Update Cupcake
|   |       |── UpdateCupcakeView.swift
|   |       └── UpdateCupcakeView+ViewModel.swift
|   |── Model
|   |   |── Action.swift
|   |   |── Cupcake+Update.swift
|   |   └── Order+Update.swift
|   |── Preview Content
|   |   └── Preview Assets.xcassets
|   |── Service
|   |   └── GetPhoto.swift
|   └── Info.plist   
├── LICENSE
└── README.md       
```

# Dependencies
Swift Package Manager is used as a dependency manager.
## List of dependencies: 
* ErrorWrapper -> My library that, used to set error alerts more easy.
* KeychainService -> My library, used to handle with store, retrive and delete token from the keychian. 
* NetworkKit -> My library, used to handle with the http call and WebSocket tasks more easy.

# API 
* This projects is using a REST API
* List of API calls is [here](https://github.com/isaqueDaSilva/CupcakeCornerAPI?tab=readme-ov-file#api) 
