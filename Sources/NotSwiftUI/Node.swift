internal final class Node {
    weak var graph: Graph?
    var children: [Node] = []
    var needsRebuild = true
    var view: BuiltinView?
    var previousView: Any?
    var stateProperties: [String: Any] = [:]

    init() {
    }

    init(graph: Graph?) {
        assert(graph != nil)
        self.graph = graph
    }

    @MainActor
    func rebuildIfNeeded() {
        view?._buildNodeTree(self)
    }

    func setNeedsRebuild() {
        needsRebuild = true
    }
}

internal extension Node {
    func dump(depth: Int = 0) {
        let indent = String(repeating: "  ", count: depth)
        print("\(indent)\(String(describing: view))")
        for child in children {
            child.dump(depth: depth + 1)
        }
    }
}
