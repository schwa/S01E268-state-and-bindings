struct Button: View, BuiltinView {
    var title: String
    var action: () -> ()
    init(_ title: String, action: @escaping () -> ()) {
        self.title = title
        self.action = action
    }

    func _buildNodeTree(_ node: Node) {
        // todo create a UIButton
    }
}
