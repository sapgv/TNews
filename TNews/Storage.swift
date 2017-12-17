//
//  Storage.swift
//  TNews
//
//  Created by Гриша on 12.12.2017.
//  Copyright © 2017 sapgv. All rights reserved.
//

import Foundation
import CoreData


public class Storage {
    private let entityName = "Post"
    public typealias Entity = _Post
    
    public static let shared = Storage()
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!.appendingPathComponent("TNews.sqlite")
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            abort()
        }
        return coordinator
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: "TNews", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    private init() { }
    
    //MARK: Objects manipulating
    public func saveContext() {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    public func clear() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        _ = try? managedObjectContext.execute(deleteRequest)
        saveContext()
    }
    
    public func postsSortedByDate() -> [Entity] {
        let fetchRequest = NSFetchRequest<Entity>(entityName: entityName)
        let sectionSortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        let results = try? managedObjectContext.fetch(fetchRequest)
        return results ?? []
    }
    
    public func post(id: Int) -> Entity? {
        let fetchRequest = NSFetchRequest<Entity>(entityName: entityName)
        let description = NSEntityDescription.entity(forEntityName: entityName, in: managedObjectContext)!
        fetchRequest.entity = description
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)
        
        let results = try? managedObjectContext.fetch(fetchRequest)
        let object = results?.first
        return object
    }
    
    public func findOrCreatePost(id: Int) -> Entity {
        if let object = post(id: id) {
            return object
        } else {
            let description = NSEntityDescription.entity(forEntityName: entityName, in: managedObjectContext)!
            let object = Entity(entity: description, insertInto: managedObjectContext)
            object.id = Int32(id)
            return object
        }
    }
    
    public func createPost(id: Int) -> Entity {
        let description = NSEntityDescription.entity(forEntityName: entityName, in: managedObjectContext)!
        let object = Entity(entity: description, insertInto: managedObjectContext)
        object.id = Int32(id)
        return object
    }
}
