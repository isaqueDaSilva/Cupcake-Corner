//
//  ImageCache.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 7/5/25.
//

import Foundation

final actor ImageCache {
    static let shared = ImageCache()
    
    private let logger = AppLogger(category: "ImageCache")
    private let cache = NSCache<NSString, NSData>()
    
    func setImageData(_ imageData: Data, forKey key: String) {
        self.cache.setObject(imageData as NSData, forKey: key as NSString)
        print("Image setted with success for key \(key).")
        self.logger.info("Image setted with success for key \(key).")
    }
    
    func imageData(withKey key: String) -> Data? {
        self.cache.object(forKey: key as NSString) as? Data
    }
    
    func removeImageData(withKey key: String) {
        self.cache.removeObject(forKey: key as NSString)
    }
    
    func removeAllImageData() {
        self.cache.removeAllObjects()
    }
    
    private init() { }
}
