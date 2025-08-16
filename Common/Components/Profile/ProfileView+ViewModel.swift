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
        private let logger = AppLogger(category: "ProfileView+ViewModel")
        private var performRevocationTask: Task<Void, Never>? = nil
        
        var executionScheduler = [() -> Void]() {
            didSet {
                self.logger.info("Execution Scheduler was changed. There is \(self.executionScheduler.count) tasks inside it.")
            }
        }
        
        #if CLIENT
        var isLoadingDeleteAccountButton = false
        #endif
        
        var isLoadingSignOutButton = false
        var alert: AppAlert? = nil {
            didSet {
                if let alert {
                    self.logger.info(
                        "A new alert was setted. Alert -> Title: \(alert.title); Description: \(alert.description)."
                    )
                }
            }
        }
        
        var deletionType: RevocationType? = nil {
            didSet {
                if let deletionType {
                    self.logger.info(
                        "The deletion type was setted for \(deletionType.rawValue)."
                    )
                }
            }
        }
        
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
            with isPerfomingAction: Bool,
            session: URLSession = .shared,
            revokeHandler: @escaping (RevocationType, URLSession) async throws -> Void
        ) {
            if let deletionType, self.executionScheduler.isEmpty {
                guard !isPerfomingAction else {
                    self.startLoad()
                    self.executionScheduler.append { [weak self] in
                        guard let self else { return }
                        
                        self.performRevocation(with: false, revokeHandler: revokeHandler)
                    }
                    
                    return
                }
                
                self.performRevocationTask = Task.detached { [weak self] in
                    guard let self else { return }
                    
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
                        
                        self.stopLoad()
                        
                        self.performRevocationTask?.cancel()
                        self.performRevocationTask = nil
                    }
                }
            }
        }
        
        private func startLoad() {
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
        
        private func stopLoad() {
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
