//
//  NetworkingFile.swift
//  VirtualTourist
//
//  Created by Guneet Garg on 22/04/18.
//  Copyright © 2018 Guneet Garg. All rights reserved.
//

import Foundation
import MapKit
import CoreData

class NetworkingFlickr : NSFetchedResultsController<Photo>{
    
    var fetchedResultsController:NSFetchedResultsController<Photo>!
    var dataController : DataController!
    
    init(coords : MKAnnotation,dataaController : DataController,pinToSave : Pin){
        super.init()
        dataController = dataaController
        try? self.dataController.viewContext.save()
        self.setupFetchRequest(dataaController,pintoSave: pinToSave)
    }
    
    
    fileprivate func setupFetchRequest(_ dataaController: DataController,pintoSave : Pin) {
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        fetchRequest.sortDescriptors = []
        fetchRequest.predicate = NSPredicate(format: "pin==%@", argumentArray: [pintoSave])
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataaController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        do{
            try fetchedResultsController.performFetch()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    func SavePinToCD(photoURLToSave : String,pinToSave : Pin){
        let photoToSave = Photo(context: dataController.viewContext)
        photoToSave.url = photoURLToSave
        photoToSave.pin = pinToSave
        let photoURL = URL(string: photoURLToSave)
        URLSession.shared.dataTask(with: photoURL!){ (data,response,error) in
            if error == nil{
                DispatchQueue.global().async {
                    photoToSave.data = data
                }
            }
            }.resume()
        try? dataController.viewContext.save()
    }
    
    fileprivate func networkSessio(_ methodParameters: [String : String],coords : MKAnnotation,pinToSave : Pin) {
        let session = URLSession.shared
        let request = URLRequest(url: FlickrURL(parameters: methodParameters as [String : AnyObject]))
        let task = session.dataTask(with: request) {
            (data,request,error) in
            if (error == nil){
                let parsedResult : [String : AnyObject]!
                do{
                    try parsedResult = JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String : AnyObject]
                    let photosDictionary = parsedResult[Constants.ResponseKeys.Photos] as? [String:AnyObject]
                    let photoArray = photosDictionary![Constants.ResponseKeys.Photo] as? [[String:AnyObject]]
                    for _ in 0...10{
                        let randomNo = Int(arc4random_uniform(UInt32((photoArray?.count)!-2)))
                        let randomPhotoArray = photoArray![randomNo]
                        let imageURLString = randomPhotoArray[Constants.ResponseKeys.MediumURL] as! String
                        self.SavePinToCD(photoURLToSave: imageURLString, pinToSave: pinToSave)
                    }
                    
                } catch {
                    print("Error in Fetching Results")
                }
                
            }//Check For Error Ends Here
        }//Data Request Ends Here
        task.resume()
        
    }
    
    func getNetworkRequest(pinRecieved : MKAnnotation,pinToSave : Pin){
        let methodParameters = [
            Constants.ParameterKeys.SafeSearch: Constants.ParameterValues.UseSafeSearch,
            Constants.ParameterKeys.Extras: Constants.ParameterValues.MediumURL,
            Constants.ParameterKeys.Format: Constants.ParameterValues.ResponseFormat,
            Constants.ParameterKeys.NoJSONCallback: Constants.ParameterValues.DisableJSONCallback,
            Constants.ParameterKeys.Method: Constants.ParameterValues.SearchMethod,
            Constants.ParameterKeys.APIKey: Constants.ParameterValues.APIKey,
            Constants.ParameterKeys.BoundingBox: getbbox(pinRecieved: pinRecieved)
        ]
        
        networkSessio(methodParameters, coords: pinRecieved, pinToSave: pinToSave)
    }
    
    func getbbox(pinRecieved : MKAnnotation) -> String{
        
        let minimumLon = max(pinRecieved.coordinate.longitude - Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.0)
        let minimumLat = max(pinRecieved.coordinate.latitude - Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.0)
        let maximumLon = min(pinRecieved.coordinate.longitude + Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.1)
        let maximumLat = min(pinRecieved.coordinate.latitude + Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.1)
        
        return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
    }
    
    func FlickrURL(parameters : [String : AnyObject]) -> URL{
        var urlComponents = URLComponents()
        urlComponents.scheme = Constants.Flickr.APIScheme
        urlComponents.host = Constants.Flickr.APIHost
        urlComponents.path = Constants.Flickr.APIPath
        urlComponents.queryItems = [URLQueryItem]()
        
        for(key,value) in parameters{
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            urlComponents.queryItems?.append(queryItem)
        }
        return urlComponents.url!
    }
    
}
