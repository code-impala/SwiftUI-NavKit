//
//  Encodable+Extensions.swift
//  Navigation-package
//
//  Created by Code Impala on 20/10/24.
//

import Foundation

extension Encodable {
    func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        guard let dictionary = jsonObject as? [String: Any] else {
            throw NSError()
        }
        return dictionary
    }
}
