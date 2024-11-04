//
//  Decodable+Extensions.swift
//  Navigation-package
//
//  Created by Code Impala on 20/10/24.
//

import Foundation

public extension Decodable {
    // Generic initializer that decodes any Decodable type from a [String: Any] dictionary
    init?(from dictionary: [String: Any]?) {
        guard let dictionary = dictionary else { return nil }

        do {
            // Convert dictionary to JSON data
            let data = try JSONSerialization.data(withJSONObject: dictionary, options: [])
            // Decode the data into the appropriate Decodable type (self)
            let decodedObject = try JSONDecoder().decode(Self.self, from: data)
            self = decodedObject
        } catch {
            print("Decoding error: \(error.localizedDescription)")
            return nil
        }
    }
}
