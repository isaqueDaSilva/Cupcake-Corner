//
//  ExecutionError+Extension.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/9/25.
//

/// A Representation data of an error that will be occur in some task execution.
struct AppError: Sendable, Error {
    var title: String
    var description: String
}

// MARK: - Default Erros -

extension AppError {
    static let saveFailed = AppError(
        title: "Failed to save data.",
        description: "There was not possible to make changes in the persistence storage. Please try again or contact us to solve ir."
    )
    
    static let fetchFailed = AppError(
        title: "Failed to fetch data.",
        description: "Seams that isn't possible to find data. Please try to repeat the action or contact us to analyse the problem."
    )
    
    static let modelQuantityDifferent = AppError(
        title: "More than 1 model stored.",
        description: "Seams that the model's quantity, with the same ID is more than 1. It's not allowed. Please contact us to solve this problem."
    )
    
    static let noItemSaved = AppError(
        title: "No Item saved",
        description: "No item is available to perform the requested action."
    )
    
    static let internalError = AppError(
        title: "Internal Error",
        description: "Ops... Seams that an internal error occur when we try to fetch the data. Please try again later, or contact us o try to solve this problem."
    )
    
    static let failedToGetData = AppError(
        title: "Failed to Get Data",
        description: "Seams that an error occur when we try to fetch the data."
    )
    
    static let resposeFailed = AppError(
        title: "Invalid Response",
        description: "The response that you recive is not acceptable. Please try to repeat the task or if the error persist, contact us to try solve this problem."
    )
    
    static let decodedFailure = AppError(
        title: "Failed to decode data",
        description: "Seams that the data that you recive from this network call is not acceptable to use in the app. Please contact us to identify what is happen."
    )
    
    static let encodeFailure = AppError(
        title: "Failed to encode data",
        description: "Seams that an error occur in the data's transformation task. Please contact us to solve this problem."
    )
    
    static let receiveDataFailed = AppError(
        title: "Failed to receive data",
        description: ""
    )
    
    static let noConnection = AppError(
        title: "No connection",
        description: "There are no connection available to handle with this task."
    )
    
    static let missingData = AppError(
        title: "Missing Data",
        description: "Seams that some process failed in the background. Check if you don't miss to fill some field. If you don't, contact us to solve this problem."
    )
    
    static let accessDenied = AppError(
        title: "Access Denied",
        description: "It does not match any credentials in our database. Please try to fill in the details correctly if there is an active account, otherwise create one. Now if the error persists, please contact us to solve the problem."
    )
    
    static let badResponse = AppError(
        title: "Bad Response",
        description: "Oops! Looks like something went sideways. Our tech wizards are on it, but for now, maybe grab a coffee and try again. We'll be here when you get back!"
    )
    
    // MARK: - CreateCupcake Error -
    static let emptyIngredientsList = AppError(
        title: "Missing Ingredients",
        description: "To create a new cupcake, is needed to set the ingredients list."
    )
    
    static let priceOutTheRange = AppError(
        title: "Price out the range.",
        description: "The price needs to be at least US$0.10."
    )
    
    static let notUpgraded = AppError(
        title: "Channel not upgraded.",
        description: "The channel was not upgraded correctly."
    )
    
    static let failedToSendData = AppError(
        title: "Failed to send data in the channel.",
        description: ""
    )
    
    static let dataNotSuported = AppError(
        title: "An unexpected data type was received.",
        description: ""
    )
    
    static func unknownError(error: Error) -> Self {
        AppError(title: "Unknown Error", description: "An unexpected error occur. Error: \(error.localizedDescription)")
    }
}
