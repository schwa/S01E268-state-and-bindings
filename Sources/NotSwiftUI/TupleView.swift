public struct TupleView <each T: View>: View, BuiltinView {
    public typealias Body = Never

    private var children: (repeat each T)

    public init(_ children: repeat each T) {
        self.children = (repeat each children)
    }

    func _buildNodeTree(_ node: Node) {
        var idx = 0
        for child in repeat (each children) {
            let child = AnyBuiltinView(child)
            if node.children.count <= idx {
                node.children.append(Node())
            }
            child._buildNodeTree(node.children[idx])
            idx += 1
        }
    }
}
