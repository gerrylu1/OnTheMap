//
//  APIResponse.swift
//  OnTheMap
//
//  Created by Gerry Low on 2020-05-20.
//  Copyright © 2020 Gerry Low. All rights reserved.
//

import Foundation

struct APIResponse: Codable {
    let status: Int
    let error: String
}

extension APIResponse: LocalizedError {
    var errorDescription: String? {
        return error
    }
}
