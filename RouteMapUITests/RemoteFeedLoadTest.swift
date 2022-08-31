//
//  RemoteFeedLoadTest.swift
//  RouteMapUITests
//
//  Created by Анна Яцун on 31.08.2022.
//

import XCTest

class RemoteFeedLoad {
    let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    func load() {
        URL(string: "https://a-url.com").map {
            client.get(url: $0)
        }
    }
}

protocol HTTPClient {
    func get(url: URL)
}

class HTTPClientSpy: HTTPClient {
    var requestURL: URL?
    
    func get(url: URL) {
        requestURL = url
    }
}


class RemoteFeedLoadTest: XCTestCase {

    func test_init_dosNotRequestDataFromUrl() {
        let client = HTTPClientSpy()
        _ = RemoteFeedLoad(client: client)
        XCTAssertNil(client.requestURL)
    }

    func test_load_requestDataFromUrl() {
        let client = HTTPClientSpy()

        let sut = RemoteFeedLoad(client: client)
        sut.load()
        XCTAssertNotNil(client.requestURL)
    }
}
