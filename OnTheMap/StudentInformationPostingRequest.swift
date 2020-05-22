//
//  StudentInformationPostingRequest.swift
//  OnTheMap
//
//  Created by Gerry Low on 2020-05-21.
//  Copyright © 2020 Gerry Low. All rights reserved.
//

import Foundation

struct StudentInformationPostingRequest: Codable {
    let uniqueKey: String
    let firstName: String
    let lastName: String
    var mapString: String
    var mediaURL: String
    var latitude: Double
    var longitude: Double
}
