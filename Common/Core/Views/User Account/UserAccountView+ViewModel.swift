//
//  UserAccountView+ViewModel.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/14/25.
//

import ErrorWrapper
import Foundation
import NetworkHandler
import Observation

extension UserAccountView {
    @Observable
    @MainActor
    final class ViewModel {
        var isLoadingSignOutButton = false
        var isLoadingDeleteAccountButton = false
        var error: ExecutionError? = nil
        
        var deletionType: DeletionType? = nil
        var alertTitle = ""
        var alertMessage = ""
        var isShowingAlert = false
        
        var isDisabled: Bool {
            isLoadingSignOutButton || isLoadingDeleteAccountButton
        }
        
        func showAlert(for deletionType: DeletionType) {
            self.deletionType = deletionType
            
            self.alertTitle = switch deletionType {
            case .signOut:
                "Sign out"
            case .deleteAccount:
                "Delete Account"
            }
            
            self.alertMessage = switch deletionType {
            case .signOut:
                "Are your sure that you want to make a sign out?"
            case .deleteAccount:
                "Are you sure that you want to delete your account?"
            }
            
            self.isShowingAlert = true
        }
        
        func deletionAction(
            session: URLSession = .shared,
            completation: @escaping () throws -> Void
        ) {
            self.startLoading()
            
            Task {
                do {
                    let token = try TokenGetter.getValue()
                    
                    let (_, response) = try await performDeletion(
                        with: token,
                        session: session
                    )
                    
                    try checkResponse(response)
                    
                    try await MainActor.run {
                        try completation()
                    }
                } catch {
                    await MainActor.run {
                        self.error = error as? ExecutionError
                    }
                }
                
                await MainActor.run {
                    self.stopLoading()
                }
            }
        }
        
        private func startLoading() {
            switch self.deletionType {
            case .signOut:
                self.isLoadingSignOutButton = true
            case .deleteAccount:
                self.isLoadingDeleteAccountButton = true
            case .none:
                break
            }
        }
        
        private func stopLoading() {
            switch self.deletionType {
            case .signOut:
                self.isLoadingSignOutButton = false
            case .deleteAccount:
                self.isLoadingDeleteAccountButton = false
            case .none:
                break
            }
            
            self.deletionType = nil
        }
        
        private func performDeletion(
            with token: String,
            session: URLSession
        ) async throws(ExecutionError) -> (Data, URLResponse) {
            let path: EndpointBuilder.Path? = switch self.deletionType {
                case.signOut: .signOut
                case .deleteAccount: .delete(nil)
                case .none: nil
            }
            
            guard let path else { throw .missingData }
            
            let endpoint = Endpoint(
                scheme: EndpointBuilder.httpSchema,
                host: EndpointBuilder.domainName,
                path: EndpointBuilder.makePath(endpoint: .user, path: path),
                httpMethod: .delete,
                headers: [EndpointBuilder.Header.authorization.rawValue: token]
            )
            
            let handler = NetworkHandler<ExecutionError>(
                endpoint: endpoint,
                session: session,
                unkwnonURLRequestError: .internalError,
                failureToGetDataError: .failedToGetData
            )
            
            return try await handler.getResponse()
        }
        
        private func checkResponse(_ response: URLResponse) throws(ExecutionError) {
            let statusCode = (response as? HTTPURLResponse)?.statusCode
            
            guard let statusCode, statusCode == 200 else {
                throw .resposeFailed
            }
        }
    }
}

extension UserAccountView {
    enum DeletionType {
        case signOut
        case deleteAccount
    }
}
