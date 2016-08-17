//
//  ApiClient.swift
//  Virtual Tourist
//
//  Created by martin chibwe on 7/23/16.
//  Copyright © 2016 martin chibwe. All rights reserved.
//

import Foundation


class ApiClient {

	
    var session: NSURLSession { return NSURLSession.sharedSession() }

	
    var headers: [String: String] = [String: String]()


    enum Method: String {
        case Get
        case Post
        case Put
        case Delete
    }

 
    class func encodeParameters(params: [String: AnyObject]) -> String {
        let components = NSURLComponents()
        components.queryItems = params.map { NSURLQueryItem(name: $0, value: String($1)) }

        return components.percentEncodedQuery ?? ""
    }

 
    func prepareRequest(url: String, method: Method = .Get, params: [String: AnyObject] = [String: AnyObject](), body: AnyObject? = nil) -> NSMutableURLRequest {
        let url = url + "?" + ApiClient.encodeParameters(params)
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.HTTPMethod = method.rawValue.uppercaseString

        for (header, value) in headers {
            request.addValue(value, forHTTPHeaderField: header)
        }

        if body != nil {
            do {
                request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(body!, options: [])
            }
        }

        return request
    }

 
    func processResuest(request: NSMutableURLRequest, handler: (result: AnyObject?, error: String?) -> Void) {
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
			
            guard error == nil else {
                print("Error in response")
                handler(result: nil, error: "Connection error")
                return
            }

            // Did we get a successful 2XX response?
            guard let status = (response as? NSHTTPURLResponse)?.statusCode where status != 403 else {
				
                handler(result: nil, error: "Username or password is incorrect")
                return
            }

     
            guard let data = data else {
				
                handler(result: nil, error: "Connection error")
                return
            }

            let json: AnyObject!
            do {
                json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
	
                handler(result: nil, error: "Connection error")
                return
            }

            handler(result: json, error: nil)
        }

        task.resume()
    }
}