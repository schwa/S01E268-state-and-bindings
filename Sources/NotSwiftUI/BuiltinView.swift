@MainActor
protocol BuiltinView {
    func _buildNodeTree(_ node: Node)
}

extension BuiltinView {
    var body: Never {
        fatalError("This should never happen")
    }
}
