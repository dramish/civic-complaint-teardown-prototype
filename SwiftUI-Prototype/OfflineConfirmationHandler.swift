import Foundation
import Observation

/// Records a citizen's confirm/reject decision the instant they tap a button — never blocks
/// on network — then flushes the queue with retry + backoff once connectivity returns.
/// Lightweight prototype: swap the in-memory `pendingActions` array for a persisted store
/// (e.g. SwiftData) before shipping, so a killed app doesn't lose queued decisions.
@MainActor
@Observable
final class OfflineConfirmationHandler {
    enum Decision: Codable {
        case confirm
        case reject
    }

    struct PendingAction: Identifiable, Codable {
        let id: UUID
        let complaintID: String
        let decision: Decision
        let queuedAt: Date
    }

    private(set) var pendingActions: [PendingAction] = []
    private(set) var isSyncing = false

    private let networkMonitor: NetworkReachabilityChecking
    private let submit: (String, Decision) async throws -> Void

    init(
        networkMonitor: NetworkReachabilityChecking = NetworkMonitor.shared,
        submit: @escaping (String, Decision) async throws -> Void
    ) {
        self.networkMonitor = networkMonitor
        self.submit = submit
    }

    /// Call this the moment the citizen taps Confirm/Reject on PendingVerificationView.
    func record(complaintID: String, decision: Decision) {
        pendingActions.append(
            PendingAction(id: UUID(), complaintID: complaintID, decision: decision, queuedAt: .now)
        )
        Task { await flushIfOnline() }
    }

    func flushIfOnline() async {
        guard !isSyncing, networkMonitor.isConnected, !pendingActions.isEmpty else { return }
        isSyncing = true
        defer { isSyncing = false }

        var stillPending: [PendingAction] = []
        for action in pendingActions {
            do {
                try await submitWithRetry(action)
            } catch {
                stillPending.append(action) // network dropped mid-flush — keep it queued
            }
        }
        pendingActions = stillPending
    }

    private func submitWithRetry(_ action: PendingAction, attempt: Int = 1, maxAttempts: Int = 3) async throws {
        do {
            try await submit(action.complaintID, action.decision)
        } catch where attempt < maxAttempts {
            try await Task.sleep(for: .seconds(pow(2, Double(attempt)))) // 2s, 4s, 8s
            try await submitWithRetry(action, attempt: attempt + 1, maxAttempts: maxAttempts)
        }
    }
}
