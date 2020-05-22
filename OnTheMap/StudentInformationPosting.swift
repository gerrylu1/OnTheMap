//
//  StudentInformationPosting.swift
//  OnTheMap
//
//  Created by Gerry Low on 2020-05-22.
//  Copyright © 2020 Gerry Low. All rights reserved.
//

import Foundation

class StudentInformationPosting: Encodable {
    static var objectId: String? = nil
    static var userInfoRetrieved = false
    static var locationText = ""
    static var studentInformationPostingRequest: StudentInformationPostingRequest? = nil
    
    class func clear() {
        objectId = nil
        userInfoRetrieved = false
        locationText = ""
        studentInformationPostingRequest = nil
    }
}
