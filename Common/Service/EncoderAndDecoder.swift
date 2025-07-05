//
//  EncoderAndDecoder.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 6/21/25.
//

import ErrorWrapper
import Foundation

enum EncoderAndDecoder {
    static func encodeData<T: Encodable>(_ model: T, encoder: JSONEncoder = .init()) throws(ExecutionError) -> Data {
        do {
            return try encoder.encode(model)
        } catch {
            throw .encodeFailure
        }
    }
    
    static func decodeResponse<T: Decodable>(
        type: T.Type,
        by data: Data,
        with decoder: JSONDecoder = .init()
    ) throws(ExecutionError) -> T {
        guard let data = try? decoder.decode(T.self, from: data) else {
            throw .decodedFailure
        }
        
        return data
    }
}
