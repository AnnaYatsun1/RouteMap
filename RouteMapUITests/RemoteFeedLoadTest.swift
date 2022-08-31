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
    static var shared = HTTPClient()
    
    func get(url: URL) {}
    
}

class HTTPClientSpy: HTTPClient {
    var requestURL: URL?
    
    override func get(url: URL) {
        requestURL = url
    }
}


class RemoteFeedLoadTest: XCTestCase {

    func test_init_dosNotRequestDataFromUrl() {
        let client = HTTPClientSpy()
        HTTPClient.shared = client
        _ = RemoteFeedLoad()
        XCTAssertNil(client.requestURL)
    }

    func test_load_requestDataFromUrl() {
        let client = HTTPClientSpy()
        HTTPClient.shared = client
        let sut = RemoteFeedLoad()
        sut.load()
        XCTAssertNotNil(client.requestURL)
    }
}
