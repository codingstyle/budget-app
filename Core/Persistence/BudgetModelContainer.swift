import Foundation
import SwiftData

enum BudgetCloudKit {
    static let containerIdentifier = "iCloud.com.christophebuguet.Budget"
}

enum BudgetModelContainer {
    static func make() -> ModelContainer {
        let schema = Schema(BudgetSchema.models)
        let cloudConfiguration = ModelConfiguration(
            "Budget",
            schema: schema,
            cloudKitDatabase: .private(BudgetCloudKit.containerIdentifier)
        )

        do {
            return try ModelContainer(for: schema, configurations: [cloudConfiguration])
        } catch {
            let localConfiguration = ModelConfiguration(
                "BudgetLocal",
                schema: schema,
                cloudKitDatabase: .none
            )
            do {
                return try ModelContainer(for: schema, configurations: [localConfiguration])
            } catch {
                fatalError("Impossible d’ouvrir SwiftData : \(error)")
            }
        }
    }
}
