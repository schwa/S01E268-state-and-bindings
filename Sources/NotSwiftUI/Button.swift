public struct Button: View, BuiltinView {
    public typealias Body = Never

    public var title: String
    public var action: () -> ()

    public init(_ title: String, action: @escaping () -> ()) {
        self.title = title
        self.action = action
    }

    func _buildNodeTree(_ node: Node) {
        // todo create a UIButton
    }
}
