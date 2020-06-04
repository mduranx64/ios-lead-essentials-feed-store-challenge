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
        let databaseUrl = self.storeURL.appendingPathComponent("\(momdName).sqlite")
        let persistentStoreDescription = NSPersistentStoreDescription(url: databaseUrl)
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
    
    internal func clearDatabase() {
        guard let url = persistentContainer.persistentStoreDescriptions.first?.url else { return }

        let persistentStoreCoordinator = persistentContainer.persistentStoreCoordinator

         do {
             try persistentStoreCoordinator.destroyPersistentStore(at:url, ofType: NSSQLiteStoreType, options: nil)
             try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch let error {
             debugPrint("Attempted to clear persistent store: " + error.localizedDescription)
        }
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        let coreDataFeedImages = feed.map { image -> CoreDataFeedImage in
            return CoreDataFeedImage(context: context, image: image)
        }
        _ = Cache(context: context, feed: coreDataFeedImages, timestamp: timestamp)
        
        do {
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
            guard let coreDataFeedImages = cache.feed.array as? [CoreDataFeedImage] else {
                return completion(.empty)
            }
            let localFeedImages = coreDataFeedImages.map { feed in
                return LocalFeedImage(
                    id: feed.id,
                    description: feed.feedDescription,
                    location: feed.location,
                    url: feed.url
                )
            }
            completion(.found(feed: localFeedImages, timestamp: cache.timestamp))
        } catch {
            completion(.failure(error))
        }
    }
}
