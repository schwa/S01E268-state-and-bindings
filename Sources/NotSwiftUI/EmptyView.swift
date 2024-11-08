public struct EmptyView: View {
    public typealias Body = Never

    public init() {
    }
}

extension EmptyView: BuiltinView {
    func _buildNodeTree(_ node: Node) {
        // This line intentionally left blank.
    }
}
