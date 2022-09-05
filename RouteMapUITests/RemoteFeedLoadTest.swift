//
//  RemoteFeedLoadTest.swift
//  RouteMapUITests
//
//  Created by Анна Яцун on 31.08.2022.
//

import XCTest
import RouteMap
public enum HTTPClientResult {
    case succes(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(url: URL, completion: @escaping (HTTPClientResult) -> ())
}

public final class RemoteFeedLoad {
    private let client: HTTPClient
    private let url: URL
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidate
    }
    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (RemoteFeedLoad.Error) -> ()) {
        client.get(url: url) { rerult in
            switch rerult {
            case .succes:
                completion(.invalidate)
            case .failure:
                completion(.connectivity)
            }
        }
    }
}

class RemoteFeedLoadTest: XCTestCase {

    func test_init_dosNotRequestDataFromUrl() {
        let (_, client) = mekeSUT()
        XCTAssertTrue(client.requestURL.isEmpty)
    }

    func test_load_requestDataFromUrl() {
        let url = URL(string: "http://given-url.com")!
        let (sut, client) = mekeSUT(url: url)
        sut.load { _ in }
        XCTAssertEqual(client.requestURL, [url])
    }
    
    func test_load_deliversErrprOnClientError() {
        let (sut, client) = mekeSUT()
        execute(sut: sut, toCompliteWithError: .connectivity) {
            let clientError = NSError(domain: "Test", code: 0)
            client.complite(error: clientError)
        }
    }
    
    func test_load_deliversErrprOn200HTTPResponce() {
        let (sut, client) = mekeSUT()
        
        [199, 201, 300, 400, 500].enumerated().forEach { index, code in
            execute(sut: sut, toCompliteWithError: .invalidate) {
                client.complite(withStatusCode: code, index: index)
            }
        }
    }
    
    func test_deliverErrorOn200HTTPResponceWithInvalidJSON() {
        let (sut, client) = mekeSUT()
        execute(sut: sut, toCompliteWithError: .invalidate) {
            let invalidJSON = Data(bytes: "Invalid JSOn".utf8)
            client.complite(withStatusCode: 200, data: invalidJSON)
        }
    }
    
    // MARK: Helper
    
    private func mekeSUT(url: URL = URL(string: "http://a-given-url.com")!) -> (sut: RemoteFeedLoad, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoad(url: url, client: client)
        return (sut, client)
    }
    
    private func execute(sut: RemoteFeedLoad, toCompliteWithError error: RemoteFeedLoad.Error, file: StaticString = #file, line: UInt = #line, action: () ->()) {
        var captureError = [RemoteFeedLoad.Error?]()
        sut.load { captureError.append($0) }
        action()
        XCTAssertEqual(captureError, [error], file: file, line: line)
        
    }
    private class HTTPClientSpy: HTTPClient {
        var requestURL: [URL] {
            return masseges.map {
                $0.url
            }
        }
        var masseges = [(url: URL, completion: (HTTPClientResult) -> Void)]()
        
        func get(url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            masseges.append((url, completion))
        }
        
        func complite(error: Error, index: Int = 0) {
            masseges[index].completion(.failure(error))
        }
        
        func complite(withStatusCode code: Int, data: Data = Data(), index: Int = 0) {
            let responce = HTTPURLResponse(
                url: requestURL[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil)!
            masseges[index].completion(.succes(data, responce))
        }
    }
}
