//
//  NetworkManager.swift
//  HalfTunes
//
//  Created by Alaxabo on 4/10/17.
//  Copyright © 2017 Ken Toh. All rights reserved.
//

import Foundation

protocol NetworkManagerDelegate: class{
    func didUpdateSearchResult(searchResult: [Track])
}

let didUpdateSearchResult = "didUpdateSearchResult"

class NetworkManager{
    weak var delegate: NetworkManagerDelegate?
    static let shared = NetworkManager()
    private init() {
    }
    let defaultSession = URLSession(configuration: URLSessionConfiguration.default)
    var dataTask: URLSessionDataTask?
    var searchResults = [Track]()
    
    func updateSearchResultFromUrl(_ url: URL){
        if dataTask != nil {
            dataTask?.cancel()
        }
            dataTask = defaultSession.dataTask(with: url) {
                data, response, error in
                if let error = error {
                    print(error.localizedDescription)
                } else if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        self.updateSearchResults(data)
                    }
                }
            }
        dataTask?.resume()
    }
    func updateSearchResults(_ data: Data?){
        searchResults.removeAll()
        do{
            if let data = data, let response = try JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions(rawValue:0)) as? [String: AnyObject] {
                if let array: AnyObject = response["results"]{
                    for trackDictionary in array  as! [AnyObject]{
                        if let trackDictionary = trackDictionary as? [String: AnyObject], let previewUrl = trackDictionary["previewUrl"] as? String{
                                let name = trackDictionary["trackName"] as? String
                                let artist = trackDictionary["artistName"] as? String
                                searchResults.append(Track(name: name, artist: artist, previewUrl: previewUrl))
                        }
                        else{
                            print("Not a dictionary")
                        }
                    }
                }
                    else{
                        print("Results key not found in dictionary")
                    }
            }
                else{
                    print("JSON error")
                }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: didUpdateSearchResult), object: searchResults)
        delegate?.didUpdateSearchResult(searchResult: searchResults)
        }catch let error as NSError {
            print("Error parsing results: \(error.localizedDescription)")
        }
    }
    func updateSearchResultsToBlock(_ url: URL, completion: @escaping ((_ searchResults: [Track]) -> Void)) {
        if dataTask != nil {
            dataTask?.cancel()
        }
        
        dataTask = defaultSession.dataTask(with: url) {
            data, response, error in
            if let error = error {
                print(error.localizedDescription)
            } else if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    self.updateSearchResults(data)
                    completion(self.searchResults)
                }
            }
        }
        dataTask?.resume()
    }
}
