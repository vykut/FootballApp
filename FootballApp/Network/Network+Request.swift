//
//  Network+Request.swift
//  FootballApp
//
//  Created by vsocaciu on 16.10.2021.
//

import Foundation

extension Network {
    struct Request<Payload: Encodable> {
        let baseURL: URL
        let method: Method
        let payload: Payload?

        private init(baseURL: URL, method: Method, payload: Payload?) {
            self.baseURL = baseURL
            self.method = method
            self.payload = payload
        }

        static func get(baseURL: URL, payload: [String: String]? = nil) -> Request<[String: String]> {
            .init(
                baseURL: baseURL,
                method: .get,
                payload: payload
            )
        }

        static func post<R: Encodable>(baseURL: URL, payload: R) -> Request<R> {
            .init(
                baseURL: baseURL,
                method: .post,
                payload: payload
            )
        }
    }
}

extension Network.Request {
    enum Method: String {
        case get = "GET"
        case post = "POST"
    }
}
