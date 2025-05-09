//
//  EditAccount.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/13/25.
//


import SwiftUI

struct EditAccount: View {
    @Binding var name: String
    @Binding var email: String
    @Binding var password: String
    @Binding var confirmPassword: String
    @Binding var isLoading: Bool
    
    @FocusState private var focusedField: FocusedField?
    
    private var isDisabled: Bool
    private let buttonLabel: String
    private var action: () -> Void
    
    var body: some View {
        VStack {
            Text("User Information:")
                .headerSessionText(
                    font: .headline,
                    color: .secondary
                )
                .frame(maxWidth: .infinity, alignment: .leading)
            
            TextFieldFocused(
                focusedField: $focusedField,
                focusedFieldValue: .name,
                fieldType: .textField(
                    "Insert your name here...",
                    $name
                ),
                inputAutocapitalization: .sentences
            )
            
            if !isDisabled {
                TextFieldFocused(
                    focusedField: $focusedField,
                    focusedFieldValue: .email,
                    fieldType: .textField(
                        "Insert your email here...",
                        $email
                    ),
                    keyboardType: .emailAddress,
                    isAutocorrectionDisabled: true
                )
                
                TextFieldFocused(
                    focusedField: $focusedField,
                    focusedFieldValue: .password,
                    fieldType: .secureField(
                        "Creates a password here...",
                        $password
                    ),
                    isAutocorrectionDisabled: true
                )
                
                TextFieldFocused(
                    focusedField: $focusedField,
                    focusedFieldValue: .confirmPassword,
                    fieldType: .secureField(
                        "Confirm your password here...",
                        $confirmPassword
                    ),
                    isAutocorrectionDisabled: true
                )
            }
            
            ActionButton(
                isLoading: $isLoading,
                label: buttonLabel,
                width: .infinity
            ) {
                if name.isEmpty {
                    focusedField = .name
                } else if email.isEmpty && !isDisabled {
                    focusedField = .email
                } else if password.isEmpty && !isDisabled {
                    focusedField = .password
                } else if confirmPassword.isEmpty && !isDisabled {
                    focusedField = .confirmPassword
                } else {
                    action()
                }
            }
        }
        .padding(.horizontal)
    }
    
    init(
        name: Binding<String>,
        email: Binding<String> = .constant(""),
        password: Binding<String> = .constant(""),
        confirmPassword: Binding<String> = .constant(""),
        isLoading: Binding<Bool>,
        buttonLabel: String,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        _name = name
        _email = email
        _password = password
        _confirmPassword = confirmPassword
        _isLoading = isLoading
        self.buttonLabel = buttonLabel
        self.isDisabled = isDisabled
        self.action = action
    }
}

extension EditAccount {
    enum FocusedField: Hashable {
        case name, email, password, confirmPassword
    }
}

#Preview {
    NavigationStack {
        EditAccount(
            name: .constant(""),
            email: .constant(""),
            password: .constant(""),
            confirmPassword: .constant(""),
            isLoading: .constant(false),
            buttonLabel: "Create"
        ) { }
    }
}

#Preview {
    EditAccount(
        name: .constant("Tim Cook"),
        isLoading: .constant(false),
        buttonLabel: "Update",
        isDisabled: true
    ) { }
}
