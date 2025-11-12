//
//  ClearAllDataUseCaseMock.swift
//  CrateDiggingTests
//
//  Created by Chris Galindo on 9/13/25.
//

import Foundation
@testable import CrateDigging

/// Black box mock implementation of ClearAllDataUseCase for testing
final class ClearAllDataUseCaseMock: @unchecked Sendable, ClearAllDataUseCase {
    private var callCount: Int = 0
    private let handler: (@Sendable () -> Void)?
    
    init(handler: (@Sendable () -> Void)? = nil) {
        self.handler = handler
    }
    
    func callAsFunction() {
        callCount += 1
        handler?()
    }
    
    // MARK: - Test Control Methods
    
    func getCallCount() -> Int {
        callCount
    }
    
    func reset() {
        callCount = 0
    }
}

