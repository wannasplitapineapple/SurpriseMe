//
//  YelpClient
//  SurpriseMe
//
//  Created by Evan Grossman on 8/19/16.
//  Copyright © 2016 Evan Grossman. All rights reserved.
//

import Alamofire
import RxSwift
import SwiftyJSON

class YelpClient {
    
    static let YelpBaseURL = "https://api.yelp.com/v3/"
    
    static func searchForLocation(latitude: Double, longitude: Double, token: String) -> Observable<[SMLocation]> {
        
        return Observable.create { o in
            var urlComponents = baseURLComponents()
            urlComponents.path = "/v3/businesses/search"
            urlComponents = addQueryToURLComponents(urlComponents, name: "latitude", value: String(latitude))
            urlComponents = addQueryToURLComponents(urlComponents, name: "longitude", value: String(longitude))
            let defaultSearchOptions = SMSearchOptions()
            urlComponents = addQueryToURLComponents(urlComponents, name: "term", value: defaultSearchOptions.term)
            let sortOption = defaultSearchOptions.sort
            urlComponents = addQueryToURLComponents(urlComponents, name: "sort", value: sortOption.rawValue)
            if sortOption == .HighestRated || sortOption == .Closest {
                urlComponents = addQueryToURLComponents(urlComponents, name: "limit", value: "10")
            }
            urlComponents = addQueryToURLComponents(urlComponents, name: "radius", value: defaultSearchOptions.radius.rawValue)
            
            Alamofire.request(.GET, urlComponents.URL!, headers: ["Authorization": "Bearer \(token)"])
                .responseJSON { (response) in
                    switch response.result {
                    case .Success(let data):
                        let json = JSON(data)
                        let locations = YelpLocationParser.parseLocationsFromJSON(json)
                        o.onNext(locations)
                        o.onCompleted()
                        break
                    case .Failure:
                        o.onError(Error.RequestFailed)
                    }
            }
            return AnonymousDisposable { }
        }
        
    }

    private static func baseURLComponents() -> NSURLComponents {
        let urlComponents = NSURLComponents()
        urlComponents.scheme = "https";
        urlComponents.host = "api.yelp.com";
        return urlComponents;
    }
    
    private static func addQueryToURLComponents(urlComponents: NSURLComponents, name: String, value: String) -> NSURLComponents {
        let query = NSURLQueryItem(name: name, value: value)
        if urlComponents.queryItems == nil {
            urlComponents.queryItems = []
        }
        urlComponents.queryItems?.append(query)
        return urlComponents
    }
}
