import SwiftUI

struct MonthYearFilterView: View {
    @Binding var monthYear: MonthYear

    var body: some View {
        HStack(spacing: SpacingTokens.sm) {
            Button("Mois précédent", systemImage: "chevron.left", action: goToPreviousMonth)
                .labelStyle(.iconOnly)
            Text(monthYear.title)
                .font(.headline)
                .frame(minWidth: 160)
            Button("Mois suivant", systemImage: "chevron.right", action: goToNextMonth)
                .labelStyle(.iconOnly)
            Button("Aujourd’hui", action: goToCurrentMonth)
        }
    }

    private func goToPreviousMonth() {
        shift(by: -1)
    }

    private func goToNextMonth() {
        shift(by: 1)
    }

    private func goToCurrentMonth() {
        monthYear = .current
    }

    private func shift(by value: Int) {
        var components = DateComponents()
        components.month = monthYear.month
        components.year = monthYear.year
        components.day = 1
        let calendar = AppLocale.calendar
        guard let date = calendar.date(from: components),
              let shifted = calendar.date(byAdding: .month, value: value, to: date) else { return }
        let next = calendar.dateComponents([.month, .year], from: shifted)
        monthYear = MonthYear(month: next.month ?? 1, year: next.year ?? monthYear.year)
    }
}

#Preview {
    MonthYearFilterView(monthYear: .constant(.current))
        .padding()
}
