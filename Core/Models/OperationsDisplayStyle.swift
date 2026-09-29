import Foundation

enum OperationsDisplayStyle: String, CaseIterable, Identifiable {
    case list
    case charts

    var id: Self { self }

    var title: String {
        switch self {
        case .list: "Liste"
        case .charts: "Graphiques"
        }
    }

    var systemImage: String {
        switch self {
        case .list: "list.bullet.rectangle"
        case .charts: "chart.bar.xaxis"
        }
    }
}
