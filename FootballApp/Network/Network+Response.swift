//
//  Network+Response.swift
//  FootballApp
//
//  Created by vsocaciu on 16.10.2021.
//

import Foundation

extension Network {
    struct Response<T> {
        let value: T
        let response: URLResponse
    }
}
