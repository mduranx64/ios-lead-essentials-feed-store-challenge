//
//  FeedStoreChallengeIntegrationTests.swift
//  Tests
//
//  Created by Miguel Duran on 11-06-20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import XCTest
import FeedStoreChallenge


class FeedStoreChallengeIntegrationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        undoStoreSideEffects()
    }
    
    func test_dataPersists_acrossAppLaunches() {
        let firstStore = makeSUT()
        let secondStore = makeSUT()
        let savedFeed = uniqueImageFeed()
        
        insert(feed: savedFeed, with: firstStore)
        
        expec(with: secondStore, toLoad: savedFeed)
    }
    
    func test_readCache_whenCacheIsDeleted() {
        let firstStore = makeSUT()
        let secondStore = makeSUT()
        let thirdStore = makeSUT()
        let savedFeed = uniqueImageFeed()

        insert(feed: savedFeed, with: firstStore)
        delete(with: secondStore)
        
        expec(with: thirdStore, toLoad: [])
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> FeedStore {
        let sut = CoreDataFeedStore(storeURL: testSpecificStoreURL())
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func insert(feed: [LocalFeedImage], with store: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let expec = expectation(description: "should save feed")
        store.insert(feed, timestamp: Date()) { error in
            XCTAssertNil(error, "error saving feed", file: file, line: line)
            expec.fulfill()
        }
        wait(for: [expec], timeout: 1.0)
    }
    
    private func delete(with store: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let expec = expectation(description: "should delete feed")
        store.deleteCachedFeed { error in
            XCTAssertNil(error, "error deleting feed", file: file, line: line)
            expec.fulfill()
        }
        wait(for: [expec], timeout: 1.0)
    }
    
    private func expec(with store: FeedStore, toLoad expectedFeed: [LocalFeedImage], file: StaticString = #file, line: UInt = #line) {
        let expec = expectation(description: "should retrieve feed")
        store.retrieve { result in
            switch result {
            case .empty:
                XCTAssertEqual(expectedFeed, [], "feed sould be empty")
            case .failure(let error):
                XCTAssertNil(error, "error retrieving feed")
            case .found(let loadedFeed, _):
                XCTAssertEqual(loadedFeed, expectedFeed, "feed should be found")
            }
            expec.fulfill()
        }

        wait(for: [expec], timeout: 1.0)
    }
    
    func uniqueImageFeed() -> [LocalFeedImage] {
        return [uniqueImage(), uniqueImage()]
    }
    
    func uniqueImage() -> LocalFeedImage {
        return LocalFeedImage(id: UUID(), description: "any", location: "any", url: anyURL())
    }
    
    func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
    
    private func setupEmptyStoreState() {
        deleteStoreDataBase()
    }
    
    private func undoStoreSideEffects() {
        deleteStoreDataBase()
    }
    
    private func deleteStoreDataBase() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
    
    private func testSpecificStoreURL() -> URL {
        return cachesDirectory().appendingPathComponent("database.store")
    }
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
}
