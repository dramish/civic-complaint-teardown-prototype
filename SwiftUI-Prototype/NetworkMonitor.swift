import Network
import Observation

protocol NetworkReachabilityChecking {
    var isConnected: Bool { get }
}

/// Thin wrapper over NWPathMonitor. Swap for a mock conforming to
/// NetworkReachabilityChecking in tests/previews.
@Observable
final class NetworkMonitor: NetworkReachabilityChecking {
    static let shared = NetworkMonitor()

    private(set) var isConnected = true
    private let monitor = NWPathMonitor()

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                self?.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: .global(qos: .background))
    }
}
