import Foundation

enum TailwindPalette {
    static let families: [TailwindColorFamily] = [
        TailwindColorFamily(name: "Slate", shades: [
            .init(step: 50, hex: "#F8FAFC"), .init(step: 100, hex: "#F1F5F9"), .init(step: 200, hex: "#E2E8F0"),
            .init(step: 300, hex: "#CBD5E1"), .init(step: 400, hex: "#94A3B8"), .init(step: 500, hex: "#64748B"),
            .init(step: 600, hex: "#475569"), .init(step: 700, hex: "#334155"), .init(step: 800, hex: "#1E293B"),
            .init(step: 900, hex: "#0F172A"), .init(step: 950, hex: "#020617"),
        ]),
        TailwindColorFamily(name: "Gray", shades: [
            .init(step: 50, hex: "#F9FAFB"), .init(step: 100, hex: "#F3F4F6"), .init(step: 200, hex: "#E5E7EB"),
            .init(step: 300, hex: "#D1D5DB"), .init(step: 400, hex: "#9CA3AF"), .init(step: 500, hex: "#6B7280"),
            .init(step: 600, hex: "#4B5563"), .init(step: 700, hex: "#374151"), .init(step: 800, hex: "#1F2937"),
            .init(step: 900, hex: "#111827"), .init(step: 950, hex: "#030712"),
        ]),
        TailwindColorFamily(name: "Zinc", shades: [
            .init(step: 50, hex: "#FAFAFA"), .init(step: 100, hex: "#F4F4F5"), .init(step: 200, hex: "#E4E4E7"),
            .init(step: 300, hex: "#D4D4D8"), .init(step: 400, hex: "#A1A1AA"), .init(step: 500, hex: "#71717A"),
            .init(step: 600, hex: "#52525B"), .init(step: 700, hex: "#3F3F46"), .init(step: 800, hex: "#27272A"),
            .init(step: 900, hex: "#18181B"), .init(step: 950, hex: "#09090B"),
        ]),
        TailwindColorFamily(name: "Neutral", shades: [
            .init(step: 50, hex: "#FAFAFA"), .init(step: 100, hex: "#F5F5F5"), .init(step: 200, hex: "#E5E5E5"),
            .init(step: 300, hex: "#D4D4D4"), .init(step: 400, hex: "#A3A3A3"), .init(step: 500, hex: "#737373"),
            .init(step: 600, hex: "#525252"), .init(step: 700, hex: "#404040"), .init(step: 800, hex: "#262626"),
            .init(step: 900, hex: "#171717"), .init(step: 950, hex: "#0A0A0A"),
        ]),
        TailwindColorFamily(name: "Stone", shades: [
            .init(step: 50, hex: "#FAFAF9"), .init(step: 100, hex: "#F5F5F4"), .init(step: 200, hex: "#E7E5E4"),
            .init(step: 300, hex: "#D6D3D1"), .init(step: 400, hex: "#A8A29E"), .init(step: 500, hex: "#78716C"),
            .init(step: 600, hex: "#57534E"), .init(step: 700, hex: "#44403C"), .init(step: 800, hex: "#292524"),
            .init(step: 900, hex: "#1C1917"), .init(step: 950, hex: "#0C0A09"),
        ]),
        TailwindColorFamily(name: "Red", shades: [
            .init(step: 50, hex: "#FEF2F2"), .init(step: 100, hex: "#FEE2E2"), .init(step: 200, hex: "#FECACA"),
            .init(step: 300, hex: "#FCA5A5"), .init(step: 400, hex: "#F87171"), .init(step: 500, hex: "#EF4444"),
            .init(step: 600, hex: "#DC2626"), .init(step: 700, hex: "#B91C1C"), .init(step: 800, hex: "#991B1B"),
            .init(step: 900, hex: "#7F1D1D"), .init(step: 950, hex: "#450A0A"),
        ]),
        TailwindColorFamily(name: "Orange", shades: [
            .init(step: 50, hex: "#FFF7ED"), .init(step: 100, hex: "#FFEDD5"), .init(step: 200, hex: "#FED7AA"),
            .init(step: 300, hex: "#FDBA74"), .init(step: 400, hex: "#FB923C"), .init(step: 500, hex: "#F97316"),
            .init(step: 600, hex: "#EA580C"), .init(step: 700, hex: "#C2410C"), .init(step: 800, hex: "#9A3412"),
            .init(step: 900, hex: "#7C2D12"), .init(step: 950, hex: "#431407"),
        ]),
        TailwindColorFamily(name: "Amber", shades: [
            .init(step: 50, hex: "#FFFBEB"), .init(step: 100, hex: "#FEF3C7"), .init(step: 200, hex: "#FDE68A"),
            .init(step: 300, hex: "#FCD34D"), .init(step: 400, hex: "#FBBF24"), .init(step: 500, hex: "#F59E0B"),
            .init(step: 600, hex: "#D97706"), .init(step: 700, hex: "#B45309"), .init(step: 800, hex: "#92400E"),
            .init(step: 900, hex: "#78350F"), .init(step: 950, hex: "#451A03"),
        ]),
        TailwindColorFamily(name: "Yellow", shades: [
            .init(step: 50, hex: "#FEFCE8"), .init(step: 100, hex: "#FEF9C3"), .init(step: 200, hex: "#FEF08A"),
            .init(step: 300, hex: "#FDE047"), .init(step: 400, hex: "#FACC15"), .init(step: 500, hex: "#EAB308"),
            .init(step: 600, hex: "#CA8A04"), .init(step: 700, hex: "#A16207"), .init(step: 800, hex: "#854D0E"),
            .init(step: 900, hex: "#713F12"), .init(step: 950, hex: "#422006"),
        ]),
        TailwindColorFamily(name: "Lime", shades: [
            .init(step: 50, hex: "#F7FEE7"), .init(step: 100, hex: "#ECFCCB"), .init(step: 200, hex: "#D9F99D"),
            .init(step: 300, hex: "#BEF264"), .init(step: 400, hex: "#A3E635"), .init(step: 500, hex: "#84CC16"),
            .init(step: 600, hex: "#65A30D"), .init(step: 700, hex: "#4D7C0F"), .init(step: 800, hex: "#3F6212"),
            .init(step: 900, hex: "#365314"), .init(step: 950, hex: "#1A2E05"),
        ]),
        TailwindColorFamily(name: "Green", shades: [
            .init(step: 50, hex: "#F0FDF4"), .init(step: 100, hex: "#DCFCE7"), .init(step: 200, hex: "#BBF7D0"),
            .init(step: 300, hex: "#86EFAC"), .init(step: 400, hex: "#4ADE80"), .init(step: 500, hex: "#22C55E"),
            .init(step: 600, hex: "#16A34A"), .init(step: 700, hex: "#15803D"), .init(step: 800, hex: "#166534"),
            .init(step: 900, hex: "#14532D"), .init(step: 950, hex: "#052E16"),
        ]),
        TailwindColorFamily(name: "Emerald", shades: [
            .init(step: 50, hex: "#ECFDF5"), .init(step: 100, hex: "#D1FAE5"), .init(step: 200, hex: "#A7F3D0"),
            .init(step: 300, hex: "#6EE7B7"), .init(step: 400, hex: "#34D399"), .init(step: 500, hex: "#10B981"),
            .init(step: 600, hex: "#059669"), .init(step: 700, hex: "#047857"), .init(step: 800, hex: "#065F46"),
            .init(step: 900, hex: "#064E3B"), .init(step: 950, hex: "#022C22"),
        ]),
        TailwindColorFamily(name: "Teal", shades: [
            .init(step: 50, hex: "#F0FDFA"), .init(step: 100, hex: "#CCFBF1"), .init(step: 200, hex: "#99F6E4"),
            .init(step: 300, hex: "#5EEAD4"), .init(step: 400, hex: "#2DD4BF"), .init(step: 500, hex: "#14B8A6"),
            .init(step: 600, hex: "#0D9488"), .init(step: 700, hex: "#0F766E"), .init(step: 800, hex: "#115E59"),
            .init(step: 900, hex: "#134E4A"), .init(step: 950, hex: "#042F2E"),
        ]),
        TailwindColorFamily(name: "Cyan", shades: [
            .init(step: 50, hex: "#ECFEFF"), .init(step: 100, hex: "#CFFAFE"), .init(step: 200, hex: "#A5F3FC"),
            .init(step: 300, hex: "#67E8F9"), .init(step: 400, hex: "#22D3EE"), .init(step: 500, hex: "#06B6D4"),
            .init(step: 600, hex: "#0891B2"), .init(step: 700, hex: "#0E7490"), .init(step: 800, hex: "#155E75"),
            .init(step: 900, hex: "#164E63"), .init(step: 950, hex: "#083344"),
        ]),
        TailwindColorFamily(name: "Sky", shades: [
            .init(step: 50, hex: "#F0F9FF"), .init(step: 100, hex: "#E0F2FE"), .init(step: 200, hex: "#BAE6FD"),
            .init(step: 300, hex: "#7DD3FC"), .init(step: 400, hex: "#38BDF8"), .init(step: 500, hex: "#0EA5E9"),
            .init(step: 600, hex: "#0284C7"), .init(step: 700, hex: "#0369A1"), .init(step: 800, hex: "#075985"),
            .init(step: 900, hex: "#0C4A6E"), .init(step: 950, hex: "#082F49"),
        ]),
        TailwindColorFamily(name: "Blue", shades: [
            .init(step: 50, hex: "#EFF6FF"), .init(step: 100, hex: "#DBEAFE"), .init(step: 200, hex: "#BFDBFE"),
            .init(step: 300, hex: "#93C5FD"), .init(step: 400, hex: "#60A5FA"), .init(step: 500, hex: "#3B82F6"),
            .init(step: 600, hex: "#2563EB"), .init(step: 700, hex: "#1D4ED8"), .init(step: 800, hex: "#1E40AF"),
            .init(step: 900, hex: "#1E3A8A"), .init(step: 950, hex: "#172554"),
        ]),
        TailwindColorFamily(name: "Indigo", shades: [
            .init(step: 50, hex: "#EEF2FF"), .init(step: 100, hex: "#E0E7FF"), .init(step: 200, hex: "#C7D2FE"),
            .init(step: 300, hex: "#A5B4FC"), .init(step: 400, hex: "#818CF8"), .init(step: 500, hex: "#6366F1"),
            .init(step: 600, hex: "#4F46E5"), .init(step: 700, hex: "#4338CA"), .init(step: 800, hex: "#3730A3"),
            .init(step: 900, hex: "#312E81"), .init(step: 950, hex: "#1E1B4B"),
        ]),
        TailwindColorFamily(name: "Violet", shades: [
            .init(step: 50, hex: "#F5F3FF"), .init(step: 100, hex: "#EDE9FE"), .init(step: 200, hex: "#DDD6FE"),
            .init(step: 300, hex: "#C4B5FD"), .init(step: 400, hex: "#A78BFA"), .init(step: 500, hex: "#8B5CF6"),
            .init(step: 600, hex: "#7C3AED"), .init(step: 700, hex: "#6D28D9"), .init(step: 800, hex: "#5B21B6"),
            .init(step: 900, hex: "#4C1D95"), .init(step: 950, hex: "#2E1065"),
        ]),
        TailwindColorFamily(name: "Purple", shades: [
            .init(step: 50, hex: "#FAF5FF"), .init(step: 100, hex: "#F3E8FF"), .init(step: 200, hex: "#E9D5FF"),
            .init(step: 300, hex: "#D8B4FE"), .init(step: 400, hex: "#C084FC"), .init(step: 500, hex: "#A855F7"),
            .init(step: 600, hex: "#9333EA"), .init(step: 700, hex: "#7E22CE"), .init(step: 800, hex: "#6B21A8"),
            .init(step: 900, hex: "#581C87"), .init(step: 950, hex: "#3B0764"),
        ]),
        TailwindColorFamily(name: "Fuchsia", shades: [
            .init(step: 50, hex: "#FDF4FF"), .init(step: 100, hex: "#FAE8FF"), .init(step: 200, hex: "#F5D0FE"),
            .init(step: 300, hex: "#F0ABFC"), .init(step: 400, hex: "#E879F9"), .init(step: 500, hex: "#D946EF"),
            .init(step: 600, hex: "#C026D3"), .init(step: 700, hex: "#A21CAF"), .init(step: 800, hex: "#86198F"),
            .init(step: 900, hex: "#701A75"), .init(step: 950, hex: "#4A044E"),
        ]),
        TailwindColorFamily(name: "Pink", shades: [
            .init(step: 50, hex: "#FDF2F8"), .init(step: 100, hex: "#FCE7F3"), .init(step: 200, hex: "#FBCFE8"),
            .init(step: 300, hex: "#F9A8D4"), .init(step: 400, hex: "#F472B6"), .init(step: 500, hex: "#EC4899"),
            .init(step: 600, hex: "#DB2777"), .init(step: 700, hex: "#BE185D"), .init(step: 800, hex: "#9D174D"),
            .init(step: 900, hex: "#831843"), .init(step: 950, hex: "#500724"),
        ]),
        TailwindColorFamily(name: "Rose", shades: [
            .init(step: 50, hex: "#FFF1F2"), .init(step: 100, hex: "#FFE4E6"), .init(step: 200, hex: "#FECDD3"),
            .init(step: 300, hex: "#FDA4AF"), .init(step: 400, hex: "#FB7185"), .init(step: 500, hex: "#F43F5E"),
            .init(step: 600, hex: "#E11D48"), .init(step: 700, hex: "#BE123C"), .init(step: 800, hex: "#9F1239"),
            .init(step: 900, hex: "#881337"), .init(step: 950, hex: "#4C0519"),
        ]),
    ]

    static let defaultHex = "#3B82F6"

    static func normalized(_ hex: String) -> String {
        var value = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if value.hasPrefix("#") {
            value.removeFirst()
        }
        return value
    }
}

struct TailwindColorFamily: Identifiable {
    let name: String
    let shades: [TailwindColorShade]

    var id: String { name }
}

struct TailwindColorShade: Identifiable {
    let step: Int
    let hex: String

    var id: String { "\(step)-\(hex)" }

    var displayHex: String {
        hex.hasPrefix("#") ? hex : "#\(hex)"
    }
}
