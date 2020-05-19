//
//  StudentInformation.swift
//  OnTheMap
//
//  Created by Gerry Low on 2020-05-19.
//  Copyright © 2020 Gerry Low. All rights reserved.
//

import Foundation

struct StudentInformation: Codable {
    let objectId: String
    let uniqueKey: String
    let firstName: String
    let lastName: String
    let mapString: String
    let mediaURL: String
    let latitude: Double
    let longitude: Double
    let createdAt: Date
    let updatedAt: Date
}
