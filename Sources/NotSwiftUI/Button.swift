public struct Button: View, BuiltinView {
    public typealias Body = Never

    var title: String
    var action: () -> ()
    public init(_ title: String, action: @escaping () -> ()) {
        self.title = title
        self.action = action
    }

    func _buildNodeTree(_ node: Node) {
        // todo create a UIButton
    }
}
