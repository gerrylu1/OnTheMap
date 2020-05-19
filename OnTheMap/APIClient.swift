//
//  APIClient.swift
//  OnTheMap
//
//  Created by Gerry Low on 2020-05-19.
//  Copyright © 2020 Gerry Low. All rights reserved.
//

import Foundation

class APIClient {
    
    static let limit = 100
    
    struct Auth {
        static var accountKey = ""
        static var sessionId = ""
    }
    
    enum Endpoints {
        static let base = "https://onthemap-api.udacity.com/v1"
        
        case login
        case signUp
        case getStudentLocation
        
        var stringValue: String {
            switch self {
            case .login: return Endpoints.base + "/session"
            case .signUp: return "https://auth.udacity.com/sign-up"
            case .getStudentLocation: return Endpoints.base + "/StudentLocation?limit=\(limit)"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func login(username: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        let loginRequest = LoginRequest(udacity: UserCredentials(username: username, password: password))
        taskForPOSTRequest(url: Endpoints.login.url, responseType: SessionResponse.self, request: loginRequest, skipFirst5Characters: true) { (responseObject, error) in
            guard let responseObject = responseObject else {
                completion(false, error)
                return
            }
            Auth.accountKey = responseObject.account.key
            Auth.sessionId = responseObject.session.id
            completion(true, nil)
        }
    }
    
    class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, skipFirst5Characters: Bool = false, completion: @escaping (ResponseType?, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard var data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            if skipFirst5Characters {
                let range = 5..<data.count
                data = data.subdata(in: range)
            }
            do {
                let responseObject = try JSONDecoder().decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        task.resume()
    }
    
    class func taskForPOSTRequest<RequestType: Encodable, ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, request body: RequestType, skipFirst5Characters: Bool = false, completion: @escaping (ResponseType?, Error?) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONEncoder().encode(body)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                parseData(data: data, error: error, skipFirst5Characters: skipFirst5Characters, completion: completion)
            }
        }
        task.resume()
    }
    
    class func parseData<ResponseType: Decodable>(data: Data?, error: Error?, skipFirst5Characters: Bool, completion: @escaping (ResponseType?, Error?) -> Void) {
        guard var data = data else {
            completion(nil, error)
            return
        }
        if skipFirst5Characters {
            let range = 5..<data.count
            data = data.subdata(in: range)
        }
        //print(String(decoding: data, as: UTF8.self))
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
