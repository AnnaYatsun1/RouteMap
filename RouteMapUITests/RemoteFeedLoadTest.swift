//
//  RemoteFeedLoadTest.swift
//  RouteMapUITests
//
//  Created by Анна Яцун on 31.08.2022.
//

import XCTest
import RouteMap


public protocol HTTPClient {
    func get(url: URL, completion: @escaping (Error) -> ())
}

public final class RemoteFeedLoad {
    private let client: HTTPClient
    private let url: URL
    
    public enum Error: Swift.Error {
        case connectivity
    }
    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (RemoteFeedLoad.Error) -> ()) {
        client.get(url: url) { error in
            completion(.connectivity)
        }
    }
}

class RemoteFeedLoadTest: XCTestCase {

    func test_init_dosNotRequestDataFromUrl() {
        let (_, client) = mekeSUT()
        XCTAssertNil(client.requestURL)
    }

    func test_load_requestDataFromUrl() {
        let url = URL(string: "http://given-url.com")!
        let (sut, client) = mekeSUT(url: url)
        sut.load {_ in }
        XCTAssertEqual(client.requestURL, url)
    }
    
    func test_load_deliversErrprOnClientError() {
        let (sut, client) = mekeSUT()

        var captureError: RemoteFeedLoad.Error?
        sut.load(completion: { error in
            captureError = error
        })
        let clientError = NSError(domain: "Test", code: 0)
        client.completions[0](clientError)
        XCTAssertEqual(captureError, .connectivity)
    }
    
    private func mekeSUT(url: URL = URL(string: "http://a-given-url.com")!) -> (sut: RemoteFeedLoad, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoad(url: url, client: client)
        return (sut, client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestURL: URL?
        var error: Error?
        var completions = [(Error) -> ()]()
        func get(url: URL, completion: @escaping (Error) -> ()) {
            completions.append(completion)
            requestURL = url
        }
    }
}
