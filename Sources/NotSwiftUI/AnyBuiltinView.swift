@MainActor
struct AnyBuiltinView: BuiltinView {
    @MainActor
    private var buildNodeTree: (Node) -> ()

    init<V: View>(_ view: V) {
        self.buildNodeTree = view.buildNodeTree(_:)
    }

    func _buildNodeTree(_ node: Node) {
        buildNodeTree(node)
    }
}
