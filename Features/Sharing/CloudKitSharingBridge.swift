import CloudKit
import CoreData
import Foundation
import SwiftData

enum CloudKitSharingBridge {
    static func persistentCloudKitContainer(from context: ModelContext) -> NSPersistentCloudKitContainer? {
        var visited: Set<ObjectIdentifier> = []
        return find(NSPersistentCloudKitContainer.self, in: context.container, depth: 0, visited: &visited)
    }

    static func managedObjectContext(from context: ModelContext) -> NSManagedObjectContext? {
        var visited: Set<ObjectIdentifier> = []
        if let found = find(NSManagedObjectContext.self, in: context, depth: 0, visited: &visited) {
            return found
        }
        visited.removeAll()
        return find(NSManagedObjectContext.self, in: context.container, depth: 0, visited: &visited)
    }

    static func managedObject(
        for model: some PersistentModel,
        in context: ModelContext
    ) -> NSManagedObject? {
        guard let moc = managedObjectContext(from: context),
              let uri = uriRepresentation(of: model.persistentModelID),
              let objectID = moc.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: uri) else {
            return nil
        }
        return try? moc.existingObject(with: objectID)
    }

    static func sharedPersistentStore(in container: NSPersistentCloudKitContainer) -> NSPersistentStore? {
        let sharedURL = container.persistentStoreDescriptions.first { description in
            description.cloudKitContainerOptions?.databaseScope == .shared
        }?.url
        let stores = container.persistentStoreCoordinator.persistentStores
        if let sharedURL, let shared = stores.first(where: { $0.url == sharedURL }) {
            return shared
        }
        return stores.first
    }

    private static func uriRepresentation(of identifier: PersistentIdentifier) -> URL? {
        guard let data = try? JSONEncoder().encode(identifier),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        if let uriString = nestedString(named: "uriRepresentation", in: json) {
            return URL(string: uriString)
        }
        return nil
    }

    private static func nestedString(named key: String, in object: Any) -> String? {
        if let dictionary = object as? [String: Any] {
            if let value = dictionary[key] as? String {
                return value
            }
            for child in dictionary.values {
                if let found = nestedString(named: key, in: child) {
                    return found
                }
            }
        } else if let array = object as? [Any] {
            for child in array {
                if let found = nestedString(named: key, in: child) {
                    return found
                }
            }
        }
        return nil
    }

    private static func find<T: AnyObject>(
        _ type: T.Type,
        in object: Any,
        depth: Int,
        visited: inout Set<ObjectIdentifier>
    ) -> T? {
        if let match = object as? T {
            return match
        }
        guard depth < 8 else { return nil }
        if Swift.type(of: object) is AnyClass, let objectInstance = object as? AnyObject {
            let identity = ObjectIdentifier(objectInstance)
            if visited.contains(identity) {
                return nil
            }
            visited.insert(identity)
        }

        let mirror = Mirror(reflecting: object)
        for child in mirror.children {
            if let found = find(type, in: child.value, depth: depth + 1, visited: &visited) {
                return found
            }
        }
        return nil
    }
}
