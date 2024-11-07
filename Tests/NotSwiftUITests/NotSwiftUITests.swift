import Combine
@testable import NotSwiftUI
import Testing

struct Button: View, BuiltinView {
    typealias Body = Never

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

final class Model: ObservableObject {
    @Published var counter: Int = 0
}

extension View {
    func debug(_ f: () -> ()) -> some View {
        f()
        return self
    }
}

struct ContentView: View {
    @ObservedObject var model = Model()
    var body: some View {
        Button("\(model.counter)") {
            model.counter += 1
        }
    }
}

@MainActor
var nestedModel = Model()

@MainActor
var nestedBodyCount = 0

@MainActor
var contentViewBodyCount = 0

@MainActor
var sampleBodyCount = 0

@Suite(.serialized)
@MainActor
struct NotSwiftUIStateTests {
    init() {
        nestedBodyCount = 0
        contentViewBodyCount = 0
        nestedModel.counter = 0
        sampleBodyCount = 0
    }

    @Test func testUpdate() {
        let v = ContentView()
        let node = Node()
        v.buildNodeTree(node)
        var button: Button {
            node.children[0].view as! Button
        }
        #expect(button.title == "0")
        button.action()
        node.rebuildIfNeeded()
        #expect(button.title == "1")
    }

    @Test func testConstantNested() {
        @MainActor struct Nested: View {
            var body: some View {
                nestedBodyCount += 1
                return Button("Nested Button") {}
            }
        }

        struct ContentView: View {
            @ObservedObject var model = Model()
            var body: some View {
                Button("\(model.counter)") {
                    model.counter += 1
                }
                Nested()
                    .debug {
                        contentViewBodyCount += 1
                    }
            }
        }

        let v = ContentView()
        let node = Node()
        v.buildNodeTree(node)
        #expect(contentViewBodyCount == 1)
        #expect(nestedBodyCount == 1)
        var button: Button {
            node.children[0].children[0].view as! Button
        }
        button.action()
        node.rebuildIfNeeded()
        #expect(contentViewBodyCount == 2)
        #expect(nestedBodyCount == 1)
    }

    @Test func testChangedNested() {
        struct Nested: View {
            var counter: Int
            var body: some View {
                nestedBodyCount += 1
                return Button("Nested Button") {}
            }
        }

        struct ContentView: View {
            @ObservedObject var model = Model()
            var body: some View {
                Button("\(model.counter)") {
                    model.counter += 1
                }
                Nested(counter: model.counter)
                    .debug {
                        contentViewBodyCount += 1
                    }
            }
        }

        let v = ContentView()
        let node = Node()
        v.buildNodeTree(node)
        #expect(contentViewBodyCount == 1)
        #expect(nestedBodyCount == 1)
        var button: Button {
            node.children[0].children[0].view as! Button
        }
        button.action()
        node.rebuildIfNeeded()
        #expect(contentViewBodyCount == 2)
        #expect(nestedBodyCount == 2)
    }

    @Test func testUnchangedNested() {
        struct Nested: View {
            var isLarge: Bool = false
            var body: some View {
                nestedBodyCount += 1
                return Button("Nested Button") {}
            }
        }

        struct ContentView: View {
            @ObservedObject var model = Model()
            var body: some View {
                Button("\(model.counter)") {
                    model.counter += 1
                }
                Nested(isLarge: model.counter > 10)
                    .debug {
                        contentViewBodyCount += 1
                    }
            }
        }

        let v = ContentView()
        let node = Node()
        v.buildNodeTree(node)
        #expect(contentViewBodyCount == 1)
        #expect(nestedBodyCount == 1)
        var button: Button {
            node.children[0].children[0].view as! Button
        }
        button.action()
        node.rebuildIfNeeded()
        #expect(contentViewBodyCount == 2)
        #expect(nestedBodyCount == 1)
    }

    @Test func testUnchangedNestedWithObservedObject() {
        struct Nested: View {
            @ObservedObject var model = nestedModel
            var body: some View {
                nestedBodyCount += 1
                return Button("Nested Button") {}
            }
        }

        struct ContentView: View {
            @ObservedObject var model = Model()
            var body: some View {
                Button("\(model.counter)") {
                    model.counter += 1
                }
                Nested()
                    .debug {
                        contentViewBodyCount += 1
                    }
            }
        }

        let v = ContentView()
        let node = Node()
        v.buildNodeTree(node)
        #expect(contentViewBodyCount == 1)
        #expect(nestedBodyCount == 1)
        var button: Button {
            node.children[0].children[0].view as! Button
        }
        button.action()
        node.rebuildIfNeeded()
        #expect(contentViewBodyCount == 2)
        #expect(nestedBodyCount == 1)
    }

    @Test func testBinding1() {
        struct Nested: View {
            @Binding var counter: Int
            var body: some View {
                nestedBodyCount += 1
                return Button("Nested Button") {}
            }
        }

        struct ContentView: View {
            @ObservedObject var model = Model()
            var body: some View {
                Button("\(model.counter)") {
                    model.counter += 1
                }
                Nested(counter: $model.counter)
                    .debug {
                        contentViewBodyCount += 1
                    }
            }
        }

        let v = ContentView()
        let node = Node()
        v.buildNodeTree(node)
        #expect(contentViewBodyCount == 1)
        #expect(nestedBodyCount == 1)
        var button: Button {
            node.children[0].children[0].view as! Button
        }
        button.action()
        node.rebuildIfNeeded()
        #expect(contentViewBodyCount == 2)
        #expect(nestedBodyCount == 2)
    }

    @Test func testBinding2() {
        struct Nested: View {
            @Binding var counter: Int
            var body: some View {
                nestedBodyCount += 1
                return Button("\(counter)") { counter += 1 }
            }
        }

        struct ContentView: View {
            @ObservedObject var model = Model()
            var body: some View {
                Nested(counter: $model.counter)
                    .debug {
                        contentViewBodyCount += 1
                    }
            }
        }

        let v = ContentView()
        let node = Node()
        v.buildNodeTree(node)
        var button: Button {
            node.children[0].children[0].view as! Button
        }
        #expect(contentViewBodyCount == 1)
        #expect(nestedBodyCount == 1)
        #expect(button.title == "0")
        button.action()
        node.rebuildIfNeeded()
        #expect(contentViewBodyCount == 2)
        #expect(nestedBodyCount == 2)
        #expect(button.title == "1")
    }

    @Test func testSimple() {
        struct Nested: View {
            @State private var counter = 0
            var body: some View {
                Button("\(counter)") {
                    counter += 1
                }
            }
        }

        struct Sample: View {
            @State private var counter = 0
            var body: some View {
                Button("\(counter)") {
                    counter += 1
                }
                Nested()
            }
        }

        let s = Sample()
        let node = Node()
        s.buildNodeTree(node)
        var button: Button {
            node.children[0].children[0].view as! Button
        }
        var nestedNode: Node {
            node.children[0].children[1]
        }
        var nestedButton: Button {
            nestedNode.children[0].view as! Button
        }
        #expect(button.title == "0")
        #expect(nestedButton.title == "0")

        nestedButton.action()
        node.rebuildIfNeeded()

        #expect(button.title == "0")
        #expect(nestedButton.title == "1")

        button.action()
        node.rebuildIfNeeded()

        #expect(button.title == "1")
        #expect(nestedButton.title == "1")
    }

    @Test func testBindings() {
        struct Nested: View {
            @Binding var counter: Int
            var body: some View {
                Button("\(counter)") {
                    counter += 1
                }
            }
        }

        struct Sample: View {
            @State private var counter = 0
            var body: some View {
                Nested(counter: $counter)
            }
        }

        let s = Sample()
        let node = Node()
        s.buildNodeTree(node)
        var nestedNode: Node {
            node.children[0]
        }
        var nestedButton: Button {
            nestedNode.children[0].view as! Button
        }
        #expect(nestedButton.title == "0")

        nestedButton.action()
        node.rebuildIfNeeded()

        #expect(nestedButton.title == "1")
    }

    @Test func testUnusedBinding() {
        struct Nested: View {
            @Binding var counter: Int
            var body: some View {
                Button("") {
                    counter += 1
                }
                .debug { nestedBodyCount += 1 }
            }
        }

        struct Sample: View {
            @State private var counter = 0
            var body: some View {
                Button("\(counter)") {}
                Nested(counter: $counter)
                    .debug { sampleBodyCount += 1 }
            }
        }

        let s = Sample()
        let node = Node()
        s.buildNodeTree(node)
        var nestedNode: Node {
            node.children[0].children[1]
        }
        var nestedButton: Button {
            nestedNode.children[0].view as! Button
        }
        #expect(sampleBodyCount == 1)
        #expect(nestedBodyCount == 1)

        nestedButton.action()
        node.rebuildIfNeeded()

        #expect(sampleBodyCount == 2)
        #expect(nestedBodyCount == 1)
    }
}
