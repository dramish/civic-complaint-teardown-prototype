import Foundation

/// The complaint lifecycle proposed in the 2FC (Citizen-Gated Two-Factor Closing) model.
/// Replaces the old two-state jump (Assigned -> Resolved/Rejected) with an intermediate
/// verification step and a routing step, per the teardown's Section 7 recommendation.
enum ComplaintStatus: String, Codable, CaseIterable {
    case submitted
    case assigned
    case pendingVerification   // NEW — inspector submitted proof, citizen hasn't confirmed yet
    case resolved
    case escalated             // replaces the generic "Rejected" — jurisdiction mismatch, not a dead end

    var displayName: String {
        switch self {
        case .submitted: "Submitted"
        case .assigned: "Assigned"
        case .pendingVerification: "Pending Your Verification"
        case .resolved: "Resolved"
        case .escalated: "In Progress – Escalated"
        }
    }
}

/// A resolution photo an inspector has submitted, awaiting citizen confirmation.
struct ComplaintResolution: Identifiable {
    let id: UUID
    let complaintID: String
    let proofPhotoURL: URL
    let submittedAt: Date
    /// submittedAt + 48h by default; see PendingVerificationView / risk mitigation in the README
    /// for the 7-day extension applied to wards with a high silent-closure rate.
    let autoCloseDeadline: Date
}
