# Cupcake Corner
An open source and studie case app, that's make easy to manage all flow inside of a Cupcake store.

<a href="" rel="nofollow"><img src="https://camo.githubusercontent.com/498ead3b529283d08c8db814f646db66ac683bb6b8ced181087fdcde9106c241/68747470733a2f2f696d672e736869656c64732e696f2f656e64706f696e743f75726c3d687474707325334125324625324673776966747061636b616765696e6465782e636f6d2532466170692532467061636b616765732532466d316775656c706625324673776966742d7265616c74696d652d6f70656e616925324662616467652533467479706525334473776966742d76657273696f6e7326636f6c6f723d627269676874677265656e" alt="Swift Version" data-canonical-src="https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fm1guelpf%2Fswift-realtime-openai%2Fbadge%3Ftype%3Dswift-versions&amp;color=brightgreen" style="max-width: 100%;"></a>

## Table of Contents
1. [Description](#description)
2. [Getting started](#getting-started)
3. [Technologies](#technologies)
4. [Architecture](#architecture)
5. [Structure](#structure)
6. [Dependencies](#dependencies)
7. [API](#api)

## Description
The Cupcake Corner project is design to solve the commun problems that a cupcake store can be.<br>
Think about, in a traditional Cupcake store:
- The clients needs to go the store;<br>
- Talks with a shop assistant;<br>
- The shop assistant will show all availables flavor, and also customizations available;<br>
- Calculates the final price, based on the fixed price of the cupcake, customizations and quantities;<br>
- The shop assistant, also needs to share the order with a confectioner, that'll prepare it;<br>
- And finally, when it's read, the shop assistant needs to notify the client that your order is ready.<br>

<p>So, with these problems in mind, Cupcake Corner comes into play, it's an easy-use application, that solve all mentionated problems with just a few clicks, for bolth client and admin sides.<br><p>

### Client side
In this target, is aimed at cupcake orders themselves. 
So because this, here the app offers:
    - A simple and easy to understand list of flavors that are available to order;
    - An easy away to choice a flavor to order, customize, based on your needs and taste, and also make an order;
    - Flowing the status change of an order, in real-time, based on updated that an admin can be;
    - And finally, see the balance of your orders within a date range.
    
### Admin target
In this target, the app, is aimed to manage the store and the portfolio itself.
So because this, here the user can:
    - Enter in the app and see what flavors are available into the store's portfolio;
    - Offers a simple and intuitive UI to easy create, update or delete flavors, based on store's needed;
    - An easy away to look and flow the client's orders that arrives;
    - Update the order status;
    - And finally, see the balance of the cupcake sells, to look what are the most selled flavor, total of sells, invoicing and more, within a date range.
    
<p>Finaly, this app comminicates with a custom backend system, whitch provides the core functionality, like the database, WebSockte system, to enable the biderectional and real-time to comunicate with a server and also with the client, and also a authentication system, that enables users to register in the system, and access the protect resources, like make an order, and also restrict some functionalities, like create or delete an cupcake flavor from an unauthorized user.</p>

To see this application in action see the [demontration video](https://youtu.be/HCnSd-yPiJk).

## Getting started
1. Make sure you have the Xcode version 16 or above installed on your computer.<br>
2. Downloads the Cupcake Corner project file from this repositorys.<br>
3. Opens the [Cupcake Corner API](https://github.com/isaqueDaSilva/CupcakeCornerAPI.git) repository and flow your instruction as well.<br>
4. Open the project files in Xcode.<br>
5. Review the code and make sure you understand what it does.
6. Run the CupcakeCorner and CupcakeCornerForAdmin targets.
    - Uses the admin credentials to log into admin target.

## Technologies
- Programming language: Swift;
- Frameworks: SwiftUI, SwiftData, SwiftCharts, Network, Security, CryptoKit;
- Web Communication: RESTful API
- Others: WebSocket

## Architecture
* Cupcake Corner is implemented using the <strong>Model-View-ViewModel (MVVM)</strong> architecture pattern.
    - Model has the base data need to generate each of them.<br>
    - View is responsible for displaying the requested list of data, given by the server request.<br>
    - ViewModel is responsable to process any user input behind the scenes, like refresh, post new data and more.<br>
    - The app, also has some extra layers, like extensions, services and utilities, that helps to the app keeps organized and easy to maintaining.
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

## Dependencies
Swift Package Manager is used as a dependency manager.
## List of dependencies: 
* [ErrorWrapper](https://github.com/isaqueDaSilva/ErrorWrapper.git) -> My library that, used to set error alerts more easy.
* [KeychainService](https://github.com/isaqueDaSilva/KeychainService.git) -> My library, used to handle with store, retrive and delete token from the keychian. 
* [NetworkKit](https://github.com/isaqueDaSilva/NetworkKit.git) -> My library, used to handle with the http call and WebSocket tasks more easy.

## API 
* This projects is using a REST API
* List of API calls is [here](https://github.com/isaqueDaSilva/CupcakeCornerAPI?tab=readme-ov-file#api) 
