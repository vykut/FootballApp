//
//  Network.swift
//  FootballApp
//
//  Created by vsocaciu on 16.10.2021.
//

import Foundation
import Combine

enum Network {
    static private let session: URLSession = .init(configuration: .default)
    static private let encoder: JSONEncoder = .init()
    static private let decoder: JSONDecoder = .init()

    static func makeRequest<R: Encodable, T: Decodable>(_ request: Request<R>) -> AnyPublisher<Response<T>, Error> {
        guard let urlRequest: URLRequest = getURLRequest(from: request) else {
            return Fail(error: .unableToConstructRequest)
                .eraseToAnyPublisher()
        }

        return session.dataTaskPublisher(for: urlRequest)
            .tryMap { result -> Response<T> in
                do {
                    let value = try decoder.decode(T.self, from: result.data)
                    return .init(value: value, response: result.response)
                } catch {
                    throw Error.unableToDecode(error)
                }
            }
            .mapError { error -> Error in
                if let error = error as? Error {
                    return error
                } else if let error = error as? URLError {
                    return .network(statusCode: error.errorCode)
                } else {
                    return .unknown
                }
            }
            .eraseToAnyPublisher()
    }

    static private func getURLRequest<R: Encodable>(from request: Request<R>) -> URLRequest? {
        var urlRequest: URLRequest = .init(url: request.baseURL)
        urlRequest.httpMethod = request.method.rawValue

        switch request.method {
        case .post:
            guard let payload = request.payload else {
                assertionFailure("POST methods should have a body")
                return nil
            }
            guard let data = try? encoder.encode(payload) else {
                assertionFailure("Unable to encode body")
                return nil
            }
            urlRequest.httpBody = data
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        case .get:
            if let parameters = request.payload as? [String: String] {
                var components = URLComponents(url: request.baseURL, resolvingAgainstBaseURL: false)
                components?.queryItems = parameters.map(URLQueryItem.init)
                urlRequest.url = components?.url
            }
        }

        return urlRequest
    }
}
