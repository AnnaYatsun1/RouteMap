//
//  RemoteFeedLoadTest.swift
//  RouteMapUITests
//
//  Created by Анна Яцун on 31.08.2022.
//

import XCTest

class RemoteFeedLoad {
    func load() {
        HTTPClient.shared.requestURL = URL(string: "https://a-url.com")
    }
}

class HTTPClient {
    static let shared = HTTPClient()
    
    private init() {}
    
    var requestURL: URL?
    
}


class RemoteFeedLoadTest: XCTestCase {

    func test_init_dosNotRequestDataFromUrl() {
        let client = HTTPClient.shared
        let sut = RemoteFeedLoad()
        XCTAssertNil(client.requestURL)
    }

    func test_load_requestDataFromUrl() {
        let client = HTTPClient.shared
        let sut = RemoteFeedLoad()
        sut.load()
        XCTAssertNotNil(client.requestURL)
    }
}
