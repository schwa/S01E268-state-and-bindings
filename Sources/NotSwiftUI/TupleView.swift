struct TupleView: BuiltinView, View {
    var children: [AnyBuiltinView]

    init<V1: View, V2: View>(_ v1: V1, _ v2: V2) {
        self.children = [AnyBuiltinView(v1), AnyBuiltinView(v2)]
    }

    func _buildNodeTree(_ node: Node) {
        for idx in children.indices {
            if node.children.count <= idx {
                node.children.append(Node())
            }
            let child = children[idx]
            child._buildNodeTree(node.children[idx])
        }
    }
}
