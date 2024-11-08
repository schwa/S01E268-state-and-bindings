@resultBuilder
@MainActor
struct ViewBuilder {
    static func buildBlock<V: View>(_ content: V) -> V {
        content
    }
    
    static func buildBlock<V1: View, V2: View>(_ v1: V1, _ v2: V2) -> TupleView {
        TupleView(v1, v2)
    }
}
