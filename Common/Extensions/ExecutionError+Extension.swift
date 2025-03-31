//
//  ExecutionError+Extension.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/9/25.
//

import ErrorWrapper

extension ExecutionError {
    static let saveFailed = ExecutionError(
        title: "Failed to save data.",
        descrition: "There was not possible to make changes in the persistence storage. Please try again or contact us to solve ir."
    )
    
    static let fetchFailed = ExecutionError(
        title: "Failed to fetch data.",
        descrition: "Seams that isn't possible to find data. Please try to repeat the action or contact us to analyse the problem."
    )
    
    static let modelQuantityDifferent = ExecutionError(
        title: "More than 1 model stored.",
        descrition: "Seams that the model's quantity, with the same ID is more than 1. It's not allowed. Please contact us to solve this problem."
    )
    
    static let noItemSaved = ExecutionError(
        title: "No Item saved",
        descrition: "No item is available to perform the requested action."
    )
    
    static let internalError = ExecutionError(
        title: "Internal Error",
        descrition: "Ops... Seams that an internal error occur when we try to fetch the data. Please try again later, or contact us o try to solve this problem."
    )
    
    static let failedToGetData = ExecutionError(
        title: "Failed to Get Data",
        descrition: "Seams that an error occur when we try to fetch the data."
    )
    
    static let resposeFailed = ExecutionError(
        title: "Invalid Response",
        descrition: "The response that you recive is not acceptable. Please try to repeat the task or if the error persist, contact us to try solve this problem."
    )
    
    static let decodedFailure = ExecutionError(
        title: "Failed to decode data",
        descrition: "Seams that the data that you recive from this network call is not acceptable to use in the app. Please contact us to identify what is happen."
    )
    
    static let encodeFailure = ExecutionError(
        title: "Failed to encode data",
        descrition: "Seams that an error occur in the data's transformation task. Please contact us to solve this problem."
    )
    
    static let receiveDataFailed = ExecutionError(
        title: "Failed to receive data",
        descrition: ""
    )
    
    static let noConnection = ExecutionError(
        title: "No connection",
        descrition: "There are no connection available to handle with this task."
    )
    
    static let missingData = ExecutionError(
        title: "Missing Data",
        descrition: "Seams that some process failed in the background. Check if you don't miss to fill some field. If you don't, contact us to solve this problem."
    )
    
    static let accessDenied = ExecutionError(
        title: "Access Denied",
        descrition: "It does not match any credentials in our database. Please try to fill in the details correctly if there is an active account, otherwise create one. Now if the error persists, please contact us to solve the problem."
    )
}
