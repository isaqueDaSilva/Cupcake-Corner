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
        #if CLIENT
        var isLoadingDeleteAccountButton = false
        #endif
        
        var isLoadingSignOutButton = false
        var error: ExecutionError? = nil
        
        var deletionType: DeletionType? = nil
        var alertTitle = ""
        var alertMessage = ""
        var isShowingAlert = false
        
        var isDisabled: Bool {
            #if CLIENT
            isLoadingSignOutButton || isLoadingDeleteAccountButton
            #elseif ADMIN
            isLoadingSignOutButton
            #endif
        }
        
        func showAlert(for deletionType: DeletionType) {
            self.deletionType = deletionType
            
            self.alertTitle = switch deletionType {
            case .signOut:
                "Sign out"
                #if CLIENT
            case .deleteAccount:
                "Delete Account"
                #endif
            }
            
            self.alertMessage = switch deletionType {
            case .signOut:
                "Are your sure that you want to make a sign out?"
                #if CLIENT
            case .deleteAccount:
                "Are you sure that you want to delete your account?"
                #endif
            }
            
            self.isShowingAlert = true
        }
        
        func deletionAction(
            session: URLSession = .shared,
            completation: @escaping () throws -> Void
        ) {
            self.startLoading()
            
            Task { [weak self] in
                guard let self else { return }
                
                do {
                    let token = try TokenGetter.getValue()
                    
                    let (_, response) = try await self.performDeletion(
                        with: token,
                        session: session
                    )
                    
                    try Network.checkResponse(response)
                    
                    try await MainActor.run { [weak self] in
                        guard self != nil else { return }
                        
                        try completation()
                    }
                } catch {
                    await MainActor.run { [weak self] in
                        guard let self else { return }
                        
                        self.error = error as? ExecutionError
                    }
                }
                
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    
                    self.stopLoading()
                }
            }
        }
        
        private func startLoading() {
            switch self.deletionType {
            case .signOut:
                self.isLoadingSignOutButton = true
                #if CLIENT
            case .deleteAccount:
                self.isLoadingDeleteAccountButton = true
                #endif
            case .none:
                break
            }
        }
        
        private func stopLoading() {
            switch self.deletionType {
            case .signOut:
                self.isLoadingSignOutButton = false
                #if CLIENT
            case .deleteAccount:
                self.isLoadingDeleteAccountButton = false
                #endif
            case .none:
                break
            }
            
            self.deletionType = nil
        }
        
        private func performDeletion(
            with token: String,
            session: URLSession
        ) async throws(ExecutionError) -> (Data, URLResponse) {
            let endpoint: EndpointBuilder.Endpoint = switch self.deletionType {
            case.signOut: .auth
            #if CLIENT
            case .deleteAccount: .user
            #endif
            case .none: .auth
            }
            
            let path: EndpointBuilder.Path? = switch self.deletionType {
                case.signOut: .logout
                #if CLIENT
                case .deleteAccount: .delete(nil)
                #endif
                case .none: nil
            }
            
            guard let path else { throw .missingData }
            
            let token = try TokenGetter.getValue()
            
            return try await Network.getData(
                path: EndpointBuilder.makePath(endpoint: endpoint, path: path),
                httpMethod: .delete,
                headers: [EndpointBuilder.Header.authorization.rawValue: token],
                session: session
            )
        }
    }
}

extension UserAccountView {
    enum DeletionType {
        case signOut
        #if CLIENT
        case deleteAccount
        #endif
    }
}
