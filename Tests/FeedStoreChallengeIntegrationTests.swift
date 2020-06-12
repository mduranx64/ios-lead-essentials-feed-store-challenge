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
        
        let firstExpectation = expectation(description: "should insert feed")
        firstStore.insert(savedFeed, timestamp: Date()) { error in
            XCTAssertNil(error, "error saving feed")
            firstExpectation.fulfill()
        }
        wait(for: [firstExpectation], timeout: 1.0)

        
        let secondExpectation = expectation(description: "should insert feed")
        secondStore.retrieve { result in
            switch result {
            case .empty:
                XCTFail("should not be empty")
            case .failure(let error):
                XCTAssertNil(error, "error retrieving feed")
            case .found(let loadedFeed, _):
                XCTAssertEqual(loadedFeed, savedFeed, "feed should be ")

            }
            secondExpectation.fulfill()
        }

        wait(for: [secondExpectation], timeout: 1.0)
    }
    
    func test_readCache_whenCacheIsDeleted() {
        let feedStore = makeSUT()
        let secondStore = makeSUT()
        let thirdStore = makeSUT()

        let savedFeed = uniqueImageFeed()

        let firstExpectation = expectation(description: "should insert feed")
        feedStore.insert(savedFeed, timestamp: Date()) { error in
            XCTAssertNil(error, "error saving feed")
            firstExpectation.fulfill()
        }
        wait(for: [firstExpectation], timeout: 1.0)
        
        let secondExpectation = expectation(description: "should insert feed")
        secondStore.deleteCachedFeed { error in
            XCTAssertNil(error, "error deletin feed")
            secondExpectation.fulfill()
        }
        wait(for: [secondExpectation], timeout: 1.0)
        
        let thirdExpectation = expectation(description: "should insert feed")
        thirdStore.retrieve { result in
            switch result {
            case .empty:
                break
            case .failure(let error):
                XCTAssertNil(error, "error retrieving feed")
            case .found:
                XCTFail("should not be found")

            }
            thirdExpectation.fulfill()
        }

        wait(for: [thirdExpectation], timeout: 1.0)
    }
    
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> FeedStore {
        let sut = CoreDataFeedStore(storeURL: testSpecificStoreURL())
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
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
