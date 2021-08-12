//
//  File.swift
//  
//
//  Created by Chris Eidhof on 24.06.21.
//

import Foundation

@propertyWrapper
public struct Binding<Value>: Equatable {
    var get: () -> Value
    var set: (Value) -> ()
    private let id = UUID()
    
    public var wrappedValue: Value {
        get { get() }
        nonmutating set { set(newValue) }
    }
    
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}
