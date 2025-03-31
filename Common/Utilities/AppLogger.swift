//
//  AppLogger.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/30/25.
//

import os.log

struct AppLogger {
    private let logger: Logger
    
    func info(_ message: String) {
        logger.info("\(message)")
    }
    
    func error(_ message: String) {
        logger.error("\(message)")
    }
    
    init(category: String) {
        self.logger = .init(
            subsystem: "com.isaqueDaSilva.CupcakeCorner",
            category: category
        )
    }
}
