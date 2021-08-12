//
//  File.swift
//  
//
//  Created by Chris Eidhof on 10.06.21.
//

import Foundation

struct AnyBuiltinView: BuiltinView {
    private var buildNodeTree: (Node) -> ()
    
    init<V: View>(_ view: V) {
        self.buildNodeTree = view.buildNodeTree(_:)
    }
    
    func _buildNodeTree(_ node: Node) {
        buildNodeTree(node)
    }
}
