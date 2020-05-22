//
//  APIClient.swift
//  OnTheMap
//
//  Created by Gerry Low on 2020-05-19.
//  Copyright © 2020 Gerry Low. All rights reserved.
//

import Foundation

class APIClient {
    
    struct Auth {
        static var accountKey = ""
        static var sessionId = ""
    }
    
    enum Endpoints {
        static let base = "https://onthemap-api.udacity.com/v1"
        
        case session
        case signUp
        case getStudentLocations(Int)
        case getPublicUserData
        case postStudentLocation
        case putStudentLocation(String)
        
        var stringValue: String {
            switch self {
            case .session: return Endpoints.base + "/session"
            case .signUp: return "https://auth.udacity.com/sign-up"
            case .getStudentLocations(let limit): return Endpoints.base + "/StudentLocation?order=-updatedAt&limit=\(limit)"
            case .getPublicUserData: return Endpoints.base + "/users/\(Auth.accountKey)"
            case .postStudentLocation: return Endpoints.base + "/StudentLocation"
            case .putStudentLocation(let objectId): return Endpoints.base + "/StudentLocation/\(objectId)"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func login(username: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        let loginRequest = LoginRequest(udacity: UserCredentials(username: username, password: password))
        taskForPOSTRequest(url: Endpoints.session.url, responseType: SessionResponse.self, request: loginRequest, skipFirst5Characters: true) { (responseObject, error) in
            guard let responseObject = responseObject else {
                completion(false, error)
                return
            }
            Auth.accountKey = responseObject.account.key
            Auth.sessionId = responseObject.session.id
            completion(true, nil)
        }
    }
    
    class func logout(completion: @escaping () -> Void) {
        var request = URLRequest(url: Endpoints.session.url)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" {
                xsrfCookie = cookie
            }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            Auth.accountKey = ""
            Auth.sessionId = ""
            DispatchQueue.main.async {
                completion()
            }
        }
        task.resume()
    }
    
    class func getStudentLocations(limit: Int, completion: @escaping ([StudentInformation], Error?) -> Void) -> URLSessionTask {
        let task = taskForGETRequest(url: Endpoints.getStudentLocations(limit).url, responseType: StudentInformationResults.self) { (responseObject, error) in
            guard let responseObject = responseObject else {
                completion([], error)
                return
            }
            completion(responseObject.results, nil)
        }
        return task
    }
    
    class func getPublicUserData(completion: @escaping (Bool, Error?) -> Void) -> URLSessionTask? {
        let task = URLSession.shared.dataTask(with: Endpoints.getPublicUserData.url) { (data, response, error) in
            guard var data = data else {
                DispatchQueue.main.async {
                    completion(false, error)
                }
                return
            }
            data = data.dropFirst(5)
            do {
                if let userDataDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                    let firstName = userDataDict["first_name"] as! String
                    let lastName = userDataDict["last_name"] as! String
                    let key = userDataDict["key"] as! String
                    let studentInformationPostingRequest = StudentInformationPostingRequest(uniqueKey: key, firstName: firstName, lastName: lastName, mapString: "", mediaURL: "", latitude: 0, longitude: 0)
                    StudentInformationPosting.studentInformationPostingRequest = studentInformationPostingRequest
                    StudentInformationPosting.userInfoRetrieved = true
                    DispatchQueue.main.async {
                        completion(true, nil)
                    }
                }
                else {
                    DispatchQueue.main.async {
                        completion(false, error)
                    }
                }
                
            } catch {
                DispatchQueue.main.async {
                    completion(false, error)
                }
            }
        }
        task.resume()
        return task
    }
    
    class func postStudentLocation(completion: @escaping (Bool, Error?) -> Void) -> URLSessionTask? {
        let task = taskForPOSTRequest(url: Endpoints.postStudentLocation.url, responseType: StudentInformationPostingResponse.self, request: StudentInformationPosting.studentInformationPostingRequest!) { (responseObject, error) in
            guard let responseObject = responseObject else {
                completion(false, error)
                return
            }
            StudentInformationPosting.objectId = responseObject.objectId
            completion(true, nil)
        }
        return task
    }
    
    class func putStudentLocation(objectId: String, completion: @escaping (Bool, Error?) -> Void) -> URLSessionTask? {
        let task = taskForPUTRequest(url: Endpoints.putStudentLocation(objectId).url, responseType: StudentInformationPuttingResponse.self, request: StudentInformationPosting.studentInformationPostingRequest!) { (responseObject, error) in
            guard responseObject != nil else {
                completion(false, error)
                return
            }
            completion(true, nil)
        }
        return task
    }
    
    @discardableResult class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, skipFirst5Characters: Bool = false, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionTask {
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            parseData(responseType: ResponseType.self, data: data, error: error, skipFirst5Characters: skipFirst5Characters) { (responseObject, error) in
                DispatchQueue.main.async {
                    completion(responseObject, error)
                }
            }
        }
        task.resume()
        return task
    }
    
    @discardableResult class func taskForPOSTRequest<RequestType: Encodable, ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, request body: RequestType, skipFirst5Characters: Bool = false, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionTask {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONEncoder().encode(body)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            parseData(responseType: ResponseType.self, data: data, error: error, skipFirst5Characters: skipFirst5Characters) { (responseObject, error) in
                DispatchQueue.main.async {
                    completion(responseObject, error)
                }
            }
        }
        task.resume()
        return task
    }
    
    @discardableResult class func taskForPUTRequest<RequestType: Encodable, ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, request body: RequestType, skipFirst5Characters: Bool = false, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionTask {
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONEncoder().encode(body)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            parseData(responseType: ResponseType.self, data: data, error: error, skipFirst5Characters: skipFirst5Characters) { (responseObject, error) in
                DispatchQueue.main.async {
                    completion(responseObject, error)
                }
            }
        }
        task.resume()
        return task
    }
    
    class func parseData<ResponseType: Decodable>(responseType: ResponseType.Type, data: Data?, error: Error?, skipFirst5Characters: Bool, completion: @escaping (ResponseType?, Error?) -> Void) {
        guard var data = data else {
            completion(nil, error)
            return
        }
        if skipFirst5Characters {
            data = data.dropFirst(5)
        }
        do {
            let responseObject = try JSONDecoder().decode(ResponseType.self, from: data)
            completion(responseObject, nil)
        } catch {
            do {
                let errorResponse = try JSONDecoder().decode(APIResponse.self, from: data)
                completion(nil, errorResponse)
            } catch {
                completion(nil, error)
            }
        }
    }
    
}
