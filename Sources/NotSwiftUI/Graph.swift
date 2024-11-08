internal import os

internal class Graph {
    var activeNodeStack: [Node] = []

    private(set) var root: Node

    @MainActor
    init<Content>(content: Content) where Content: View {
        root = Node()
        root.graph = self
        Self.current = self
        content.buildNodeTree(root)
        Self.current = nil
    }

    @MainActor
    func rebuildIfNeeded() {
        Self.current = self
        root.view!._buildNodeTree(root)
        Self.current = nil
    }

    static let _current = OSAllocatedUnfairLock<Graph?>(uncheckedState: nil)

    static var current: Graph? {
        get {
            _current.withLockUnchecked { $0 }
        }
        set {
            _current.withLockUnchecked { $0 = newValue }
        }
    }
}
