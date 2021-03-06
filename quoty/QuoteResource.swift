//
//  QuoteResource.swift
//  quoty
//
//  Created by Marvin Messenzehl on 16.03.17.
//  Copyright © 2017 Marvin Messenzehl. All rights reserved.
//

import Foundation

class QuoteResource {
    
    //old api
    //let url = "http://quotesondesign.com/wp-json/posts?filter[orderby]=rand&filter[posts_per_page]=1"
    //
    
    func getUrlString() -> String {
        //let url = "http://api.forismatic.com/api/1.0/?method=getQuote&key=457653&format=json&lang=en"
        
        let urlBase = "api.forismatic.com"
        let urlSub = "api/1.0"
        let urlConfig = "method=getQuote&key=457653&format=json&lang=en"
        
        return "http://\(urlBase)/\(urlSub)/?\(urlConfig)"
    }
    
    
    // MARK: Download data
    
    func fetchData(completion: @escaping (_ response: Quote) -> ()) {
        
        let queue = DispatchQueue.global(qos: .background)
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        //async download
        queue.async {
            guard let urlObj = URL(string: self.getUrlString()) else {
                print("problem while creating url object")
                return
            }
            
            let task = session.dataTask(with: urlObj, completionHandler: { (data, response, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                
                guard let data = data,
                      let apiResponse = self.createResponse(fromData: data) else {
                        print("no data?")
                        return
                }
                
                DispatchQueue.main.async {
                    completion(apiResponse)
                }
            })
            
            task.resume()
        }
    }
    
    
    
    // MARK: Response
    
    private func createResponse(fromData: Data) -> Quote? {
        
        guard let jsonDict = parseJson(data: fromData) else {
            print("problem with json parsing")
            return nil
        }
        
        let author = jsonDict["quoteAuthor"] as! String
        let text = jsonDict["quoteText"] as! String
        
        //debugging
        //print(author)
        //print(text)
        
        
        
        //build response
        let response = Quote(author: author, text: text)
        return response
        
    }
    
    
    private func parseJson(data: Data) -> NSDictionary? {
        do {
            let jsonDict = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary
            return jsonDict
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    
    //method not needed with the current api
    private func processQuoteText(withText: String) -> String {
        let startIndex = withText.index(withText.startIndex, offsetBy: 3)
        let endIndex = withText.index(withText.endIndex, offsetBy: -5)
        
        let range = startIndex..<endIndex
        
        let result = withText.substring(with: range)
        
        return result
    }
}
