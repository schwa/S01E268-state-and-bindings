final class Node {
    var children: [Node] = []
    var needsRebuild = true
    var view: BuiltinView!
    var previousView: Any?
    var stateProperties: [String: Any] = [:]

    @MainActor
    func rebuildIfNeeded() {
        view._buildNodeTree(self)
    }

    func setNeedsRebuild() {
        needsRebuild = true
    }
}
