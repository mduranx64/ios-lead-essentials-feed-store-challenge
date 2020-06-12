//
//  CoreDataFeedStore.swift
//  FeedStoreChallenge
//
//  Created by Miguel Duran on 03-06-20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation
import CoreData

public class CoreDataFeedStore: FeedStore {
    
    @objc(Cache)
    private class Cache: NSManagedObject {
        @nonobjc internal class func createFetchRequest() -> NSFetchRequest<Cache> {
            return NSFetchRequest<Cache>(entityName: "Cache")
        }
        
        internal static func delete(in context: NSManagedObjectContext) throws {
            let request = createFetchRequest()
            let caches = try context.fetch(request)
            caches.forEach(context.delete)
        }

        @NSManaged internal var timestamp: Date
        @NSManaged internal var feed: NSOrderedSet
        
        convenience init(context moc: NSManagedObjectContext, feed: [CoreDataFeedImage], timestamp: Date) {
            let name = String(describing: type(of: self))
            guard let entity = NSEntityDescription.entity(forEntityName: name, in: moc) else {
                fatalError("There is no entity with name \(name)")
            }
            self.init(entity: entity, insertInto: moc)
            self.timestamp = timestamp
            self.feed = NSOrderedSet(array: feed)
        }
        
        var localFeed: [LocalFeedImage] {
            let images = self.feed.array as? [CoreDataFeedImage] ?? []
            return images.map { $0.local }
        }
    }
    
    @objc(CoreDataFeedImage)
    private class CoreDataFeedImage: NSManagedObject {

        @NSManaged internal var feedDescription: String?
        @NSManaged internal var id: UUID
        @NSManaged internal var location: String?
        @NSManaged internal var url: URL
        @NSManaged internal var cache: Cache
        
        convenience init(context moc: NSManagedObjectContext, image: LocalFeedImage) {
            let name = String(describing: type(of: self))
            guard let entity = NSEntityDescription.entity(forEntityName: name, in: moc) else {
                fatalError("There is no entity with name \(name)")
            }
            self.init(entity: entity, insertInto: moc)
            self.id = image.id
            self.location = image.location
            self.feedDescription = image.description
            self.url = image.url
        }
        
        var local: LocalFeedImage {
            return LocalFeedImage(
                id: id,
                description: feedDescription,
                location: location,
                url: url
            )
        }
    }
    
    private let storeURL: URL

    public init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let momdName = String(describing: type(of: self))
        let bundle = Bundle(for: type(of: self))
        guard let modelURL = bundle.url(forResource: momdName, withExtension: "momd") else {
            fatalError("Error loading model from bundle")
        }
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Error initializing NSManagedObjectModel from: \(modelURL)")
        }

        let container = NSPersistentContainer(name: momdName, managedObjectModel: managedObjectModel)
        let persistentStoreDescription = NSPersistentStoreDescription(url: self.storeURL)
        container.persistentStoreDescriptions = [persistentStoreDescription]
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        return container
    }()
    
    private var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        do {
            try deleteCache()
            completion(nil)
            try context.save()
        } catch {
            completion(error)
        }
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        let coreDataFeedImages = feed.map { image -> CoreDataFeedImage in
            return CoreDataFeedImage(context: context, image: image)
        }
        do {
            try deleteCache()
            _ = Cache(context: context, feed: coreDataFeedImages, timestamp: timestamp)
            try context.save()
            completion(nil)
        } catch {
            completion(error)
        }
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        let request = Cache.createFetchRequest()
        do {
            guard let cache = try context.fetch(request).first else {
                return completion(.empty)
            }
            completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
        } catch {
            completion(.failure(error))
        }
    } 
    
    private func deleteCache() throws {
        let request = Cache.createFetchRequest()
        let caches = try context.fetch(request)
        caches.forEach(context.delete)
    }
}
