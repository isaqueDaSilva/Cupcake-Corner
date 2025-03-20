struct LoginRequest: Content {
    let clientPublicKey: DHKey
    let email: EncryptedField
    let password: EncryptedField
}