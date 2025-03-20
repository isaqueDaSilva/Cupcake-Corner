struct EncryptedField: Content {
    let cipher: Data
    let nonce: Data
    let tag: Data
}