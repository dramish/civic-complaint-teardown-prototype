import SwiftUI

/// Masks a citizen's phone number at the routing layer so field staff only ever see
/// geo-coordinates + complaint content — never the raw number. Mirrors the Ola/Uber
/// pattern referenced in the "Citizen data exposure" mitigation.
enum PhoneMasking {
    /// e.g. "+919876543210" -> "+91 98••••10"
    static func masked(_ rawNumber: String) -> String {
        let digits = rawNumber.filter(\.isNumber)
        guard digits.count >= 6 else { return "••••••" }

        // Treat everything before the last 10 digits as country code.
        let localDigits = digits.suffix(10)
        let countryCode = digits.dropLast(localDigits.count)

        let visibleStart = localDigits.prefix(2)
        let visibleEnd = localDigits.suffix(2)
        let middleCount = max(0, localDigits.count - visibleStart.count - visibleEnd.count)
        let maskedMiddle = String(repeating: "•", count: middleCount)

        let ccPrefix = countryCode.isEmpty ? "" : "+\(countryCode) "
        return "\(ccPrefix)\(visibleStart)\(maskedMiddle)\(visibleEnd)"
    }
}

/// Small reusable badge for showing a masked contact number in inspector-facing UI.
struct MaskedContactBadge: View {
    let rawNumber: String

    var body: some View {
        Label(PhoneMasking.masked(rawNumber), systemImage: "lock.fill")
            .font(.footnote)
            .foregroundStyle(.secondary)
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 12) {
        MaskedContactBadge(rawNumber: "+919876543210")
        MaskedContactBadge(rawNumber: "9876543210")
    }
    .padding()
}
