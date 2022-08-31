//
//  RemoteFeedLoadTest.swift
//  RouteMapUITests
//
//  Created by Анна Яцун on 31.08.2022.
//

import XCTest

class RemoteFeedLoad {
    let client: HTTPClient
    let url: URL
    
    init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    func load() {
        client.get(url: url)
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
        let url = URL(string: "http://a-given-url.com")!
        let client = HTTPClientSpy()
        _ = RemoteFeedLoad(url: url, client: client)
        XCTAssertNil(client.requestURL)
    }

    func test_load_requestDataFromUrl() {
        let client = HTTPClientSpy()
        let url = URL(string: "http://given-url.com")!
        let sut = RemoteFeedLoad(url: url, client: client)
        sut.load()
        XCTAssertNotNil(client.requestURL)
    }
}
