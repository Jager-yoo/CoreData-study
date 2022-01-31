//
//  CoreDataManager.swift
//  CoreDataCRUDPractice
//
//  Created by 유재호 on 2022/02/01.
//

import Foundation
import CoreData

class CoreDataManager {
    
    static let shared = container.newBackgroundContext()
    private static let container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "JokeModel")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        return container
    }()
    
    private init() { }
}
