//
//  TaskCoreData.swift
//  time
//
//  Created by Sohil Pandya on 09/03/2017.
//  Copyright © 2017 dwyl. All rights reserved.
//
//
//import UIKit
//import CoreData
//
//class DataController: NSObject {
//    var managedObjectContexdt: NSManagedObjectContext
//    override init() {
//        
//        guard let modelURL = Bundle.main.url(forResource: "DataModel", withExtension: "momd")
//        else {
//            fatalError("Error Loading model from bundle")
//        }
//        
//        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
//            fatalError("Error initializing mom from: \(modelURL)")
//        }
//        
//        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
//        managedObjectContexdt = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
//        managedObjectContexdt.persistentStoreCoordinator = psc
//        
//        dispatch_async(DispatchQueue.global(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
//            
//            let urls = NSFileManager.defaultManager().URLsForDirectory
//        }
//    }
//}
