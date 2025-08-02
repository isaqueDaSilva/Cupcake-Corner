//
//  ProfileView+ViewModel.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/14/25.
//


import Foundation

extension ProfileView {
    @Observable
    @MainActor
    final class ViewModel {
        #if CLIENT
        var isLoadingDeleteAccountButton = false
        #endif
        
        var isLoadingSignOutButton = false
        var alert: AppAlert? = nil
        var deletionType: RevocationType? = nil
        
        var isDisabled: Bool {
            #if CLIENT
            isLoadingSignOutButton || isLoadingDeleteAccountButton
            #elseif ADMIN
            isLoadingSignOutButton
            #endif
        }
        
        func showAlert(for deletionType: RevocationType) {
            self.deletionType = deletionType
            
            let alertTitle = switch deletionType {
            case .signOut:
                "Sign out"
                #if CLIENT
            case .deleteAccount:
                "Delete Account"
                #endif
            }
            
            let alertMessage = switch deletionType {
            case .signOut:
                "Are your sure that you want to make a sign out?"
                #if CLIENT
            case .deleteAccount:
                "Are you sure that you want to delete your account?"
                #endif
            }
            
            self.alert = .init(title: alertTitle, description: alertMessage)
        }
        
        func performRevocation(
            with session: URLSession = .shared,
            revokeHandler: @escaping (RevocationType, URLSession) async throws -> Void
        ) {
            self.startLoading()
            
            Task { [weak self] in
                guard let self, let deletionType else { return }
                
                do {
                    try await revokeHandler(deletionType, session)
                } catch let appError as AppAlert {
                    await self.setError(with: appError)
                } catch {
                    await self.setError(
                        with: .init(
                            title: "Failed to \(deletionType.rawValue).",
                            description: "Try again later or contact us to solve the problem."
                        )
                    )
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
            self.isLoadingSignOutButton = false
            #if CLIENT
            self.isLoadingDeleteAccountButton = false
            #endif
            self.deletionType = nil
        }
        
        private func setError(with appError: AppAlert) async {
            await MainActor.run { [weak self] in
                guard let self else { return }
                self.deletionType = nil
                self.alert = appError
            }
        }
    }
}
