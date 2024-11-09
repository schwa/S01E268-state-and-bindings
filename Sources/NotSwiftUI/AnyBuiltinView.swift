/// A type-erased View wrapper that converts a View to a BuiltinView.
internal struct AnyBuiltinView: BuiltinView {
    private var buildNodeTree: (Node) -> ()

    @MainActor
    init<V: View>(_ view: V) {
        buildNodeTree = view.buildNodeTree(_:)
    }

    @MainActor
    func _buildNodeTree(_ node: Node) {
        buildNodeTree(node)
    }
}
