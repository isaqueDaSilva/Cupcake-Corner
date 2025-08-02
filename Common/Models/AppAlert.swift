//
//  ExecutionError+Extension.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/9/25.
//

/// A Representation data of an error that will be occur in some task execution.
struct AppAlert: Sendable, Error {
    var title: String
    var description: String
}

// MARK: - Default Erros -

extension AppAlert {
    static let fetchFailed = AppAlert(
        title: "Failed to fetch data.",
        description: "Seams that isn't possible to find data. Please try to repeat the action or contact us to analyse the problem."
    )
    
    static let modelQuantityDifferent = AppAlert(
        title: "More than 1 model stored.",
        description: "Seams that the model's quantity, with the same ID is more than 1. It's not allowed. Please contact us to solve this problem."
    )
    
    static let internalError = AppAlert(
        title: "Internal Error",
        description: "Ops... Seams that an internal error occur when we try to perform an action. Please try again later, or contact us o try to solve this problem."
    )
    
    static let failedToGetData = AppAlert(
        title: "Failed to Get Data",
        description: "Seams that an error occur when we try to fetch the data."
    )
    
    static let decodedFailure = AppAlert(
        title: "Failed to decode data",
        description: "Seams that the data that you recive from this network call is not acceptable to use in the app. Please contact us to identify what is happen."
    )
    
    static let encodeFailure = AppAlert(
        title: "Failed to encode data",
        description: "Seams that an error occur in the data's transformation task. Please contact us to solve this problem."
    )
    
    static let noConnection = AppAlert(
        title: "No connection",
        description: "There are no connection available to handle with this task."
    )
    
    static let missingData = AppAlert(
        title: "Missing Data",
        description: "Seams that some process failed in the background. Check if you don't miss to fill some field. If you don't, contact us to solve this problem."
    )
    
    static let accessDenied = AppAlert(
        title: "Access Denied",
        description: "It does not match any credentials in our database. Please try to fill in the details correctly if there is an active account, otherwise create one. Now if the error persists, please contact us to solve the problem."
    )
    
    static let badResponse = AppAlert(
        title: "Bad Response",
        description: "Oops! Looks like something went sideways. Our tech wizards are on it, but for now, maybe grab a coffee and try again. We'll be here when you get back!"
    )
    
    // MARK: - CreateCupcake Error -
    static let emptyIngredientsList = AppAlert(
        title: "Missing Ingredients",
        description: "To create a new cupcake, is needed to set the ingredients list."
    )
    
    static let priceOutTheRange = AppAlert(
        title: "Price out the range.",
        description: "The price needs to be at least US$0.10."
    )
    
    static let failedToSendData = AppAlert(
        title: "Failed to send data in the channel.",
        description: ""
    )
    
    static let dataNotSuported = AppAlert(
        title: "An unexpected data type was received.",
        description: ""
    )
    
    static func unknownError(error: Error) -> Self {
        AppAlert(title: "Unknown Error", description: "An unexpected error occur. Error: \(error.localizedDescription)")
    }
}
