import CloudKit
import CoreData
import Foundation
import SwiftData

@MainActor
enum HouseholdSharingService {
    static func share(_ household: Household, from context: ModelContext) async throws -> (CKShare, CKContainer) {
        try context.save()
        guard let cloudContainer = CloudKitSharingBridge.persistentCloudKitContainer(from: context),
              let managedObject = CloudKitSharingBridge.managedObject(for: household, in: context) else {
            throw AppError.sharingUnavailable
        }
        let householdName = household.name

        return try await withCheckedThrowingContinuation { continuation in
            cloudContainer.share([managedObject], to: nil) { _, share, ckContainer, error in
                if let error {
                    continuation.resume(throwing: AppError.sharingFailed(error.localizedDescription))
                    return
                }
                guard let share, let ckContainer else {
                    continuation.resume(throwing: AppError.sharingUnavailable)
                    return
                }
                share[CKShare.SystemFieldKey.title] = householdName as CKRecordValue
                continuation.resume(returning: (share, ckContainer))
            }
        }
    }

    static func persist(_ share: CKShare, from context: ModelContext) async throws {
        guard let cloudContainer = CloudKitSharingBridge.persistentCloudKitContainer(from: context),
              let store = cloudContainer.persistentStoreCoordinator.persistentStores.first else {
            throw AppError.sharingUnavailable
        }
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            cloudContainer.persistUpdatedShare(share, in: store) { _, error in
                if let error {
                    continuation.resume(throwing: AppError.sharingFailed(error.localizedDescription))
                } else {
                    continuation.resume()
                }
            }
        }
    }

    static func accept(_ metadata: [CKShare.Metadata], from context: ModelContext) async throws {
        guard let cloudContainer = CloudKitSharingBridge.persistentCloudKitContainer(from: context),
              let store = CloudKitSharingBridge.sharedPersistentStore(in: cloudContainer) else {
            throw AppError.sharingUnavailable
        }
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            cloudContainer.acceptShareInvitations(from: metadata, into: store) { _, error in
                if let error {
                    continuation.resume(throwing: AppError.sharingFailed(error.localizedDescription))
                } else {
                    continuation.resume()
                }
            }
        }
    }
}
