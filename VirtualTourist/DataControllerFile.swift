//
//  DataController.swift
//  VirtualTourist
//
//  Created by Guneet Garg on 21/04/18.
//  Copyright © 2018 Guneet Garg. All rights reserved.
//

import Foundation
import CoreData

class DataController{
    let container : NSPersistentContainer
    
    init(modelName : String) {
        container = NSPersistentContainer(name: modelName)
    }
    
    func load(completition : (() -> Void)? = nil){
        container.loadPersistentStores{ storeDescription,error in
            guard error == nil else{
                fatalError(error!.localizedDescription)
            }
            completition?()
        }
    }

    var viewContext : NSManagedObjectContext{
        return container.viewContext
    }
    
}
