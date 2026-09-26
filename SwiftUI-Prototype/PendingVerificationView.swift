import SwiftUI

/// The core 2FC screen. Shown to the citizen the moment an inspector submits a resolution
/// photo — the ticket sits in `.pendingVerification`, not `.resolved`, until the citizen
/// confirms/rejects or the deadline lapses (see ComplaintResolution.autoCloseDeadline).
struct PendingVerificationView: View {
    let resolution: ComplaintResolution
    var onConfirm: () -> Void
    var onReject: () -> Void

    @State private var now: Date = .now
    private let ticker = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                AsyncImage(url: resolution.proofPhotoURL) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().aspectRatio(contentMode: .fill)
                    case .failure:
                        placeholder(systemName: "photo.badge.exclamationmark")
                    default:
                        placeholder(systemName: "photo")
                    }
                }
                .frame(height: 220)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 14))

                Text("Was this issue actually resolved?")
                    .font(.title3.weight(.semibold))

                Text("The inspector submitted this photo as proof. Compare it against what you reported — if it doesn't match, reject it.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                CountdownBadge(deadline: resolution.autoCloseDeadline, now: now)

                HStack(spacing: 12) {
                    Button(role: .destructive, action: onReject) {
                        Label("Not Fixed", systemImage: "xmark.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)

                    Button(action: onConfirm) {
                        Label("Confirm Fixed", systemImage: "checkmark.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }

                Text("No response by the deadline auto-closes this ticket as resolved.")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding()
        }
        .navigationTitle("Verify Resolution")
        .onReceive(ticker) { now = $0 }
    }

    private func placeholder(systemName: String) -> some View {
        ZStack {
            Color(.secondarySystemBackground)
            Image(systemName: systemName)
                .font(.largeTitle)
                .foregroundStyle(.secondary)
        }
    }
}

/// Live countdown to the auto-close deadline. Turns urgent (orange) inside the last 6 hours.
private struct CountdownBadge: View {
    let deadline: Date
    let now: Date

    private var remaining: TimeInterval { max(0, deadline.timeIntervalSince(now)) }
    private var isUrgent: Bool { remaining < 6 * 3600 }

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "clock.fill")
            Text(remaining > 0 ? "\(formatted(remaining)) left to respond" : "Auto-closing now")
        }
        .font(.footnote.weight(.medium))
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(isUrgent ? Color.orange.opacity(0.15) : Color.blue.opacity(0.1))
        .foregroundStyle(isUrgent ? .orange : .blue)
        .clipShape(Capsule())
    }

    private func formatted(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        return hours > 0 ? "\(hours)h \(minutes)m" : "\(minutes)m"
    }
}

#Preview {
    NavigationStack {
        PendingVerificationView(
            resolution: ComplaintResolution(
                id: UUID(),
                complaintID: "WD-14-3821",
                proofPhotoURL: URL(string: "https://picsum.photos/600/400")!,
                submittedAt: .now,
                autoCloseDeadline: .now.addingTimeInterval(48 * 3600)
            ),
            onConfirm: {},
            onReject: {}
        )
    }
}
