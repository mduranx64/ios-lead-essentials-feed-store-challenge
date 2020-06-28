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
        let persistentStoreDescription = NSPersistentStoreDescription(url: self.storeURL)
        container.persistentStoreDescriptions = [persistentStoreDescription]
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        return container
    }()
    
    private lazy var context: NSManagedObjectContext = {
        return persistentContainer.newBackgroundContext()
    }()
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        let ctx = context
        context.perform {
            do {
                try Cache.delete(in: ctx)
                try ctx.save()
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        let ctx = self.context
        context.perform {
            let coreDataFeedImages = feed.map { image -> CoreDataFeedImage in
                return CoreDataFeedImage(context: ctx, image: image)
            }
            do {
                try Cache.delete(in: ctx)
                _ = Cache(context: ctx, feed: coreDataFeedImages, timestamp: timestamp)
                try ctx.save()
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        let ctx = self.context
        context.perform {
            let request = Cache.createFetchRequest()
            do {
                guard let cache = try ctx.fetch(request).first else {
                    return completion(.empty)
                }
                completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
