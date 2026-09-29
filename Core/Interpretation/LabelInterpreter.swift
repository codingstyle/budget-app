import Foundation

enum LabelInterpreter {
    private static let prefixes: [(text: String, type: PaymentType)] = [
        ("VIREMENT INSTANTANE EMIS VERS", .instantTransferOut),
        ("VIREMENT INSTANTANE RECU DE", .instantTransferIn),
        ("VIREMENT INSTANTANE EMIS", .instantTransferOut),
        ("VIREMENT INSTANTANE RECU", .instantTransferIn),
        ("VIREMENT INSTANTANE", .transfer),
        ("VIREMENT DE", .transfer),
        ("VIREMENT", .transfer),
        ("PAIEMENT CB", .cardPayment),
        ("RETRAIT DISTRIBUTEUR", .atmWithdrawal),
        ("PRELEVEMENT", .directDebit),
        ("COMMISSIONS", .bankFee)
    ]

    static func parse(originalLabel: String, effectDate _: Date) -> ParsedLabel {
        heuristicParse(originalLabel: originalLabel)
    }

    static func heuristicParse(originalLabel: String) -> ParsedLabel {
        let normalized = LabelNormalizer.normalize(originalLabel)
        let payment = detectPaymentType(in: normalized)
        let remainder = stripPrefix(normalized)
        let parts = remainder
            .components(separatedBy: " - ")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.isEmpty == false }

        var cardLastFour = ""
        var cardFirstFour = ""
        var cardCountry = ""
        var originalCurrencyAmount = ""
        var emetteur = ""
        var motif = ""
        var reference = ""
        var valueDate: Date?
        var place = ""
        var kept: [String] = []

        for part in parts {
            var current = part

            if let card = extractCard(from: current) {
                cardLastFour = card.lastFour
                cardFirstFour = card.firstFour
                cardCountry = card.country
                originalCurrencyAmount = card.originalAmount
                current = card.remainder
            }

            let labeled = extractLabeledFields(from: current)
            assignIfEmpty(&emetteur, labeled.values["EMETTEUR"])
            assignIfEmpty(&motif, labeled.values["MOTIF"])
            assignIfEmpty(&reference, labeled.values["REF"])
            current = labeled.remainder

            if let dated = extractValueDate(from: current) {
                valueDate = dated.date
                assignIfEmpty(&place, dated.place)
                current = dated.remainder
            }

            current = current
                .replacing(#/\s+/#, with: " ")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            if current.isEmpty == false {
                kept.append(current)
            }
        }

        let merchant = kept.joined(separator: " - ")
        let displayLabel: String
        if payment.isTransfer, motif.isEmpty == false {
            displayLabel = motif
        } else if merchant.isEmpty == false {
            displayLabel = merchant
        } else if motif.isEmpty == false {
            displayLabel = motif
        } else {
            displayLabel = fallbackName(for: payment, originalLabel: originalLabel)
        }

        return ParsedLabel(
            paymentType: payment,
            merchant: merchant.isEmpty ? fallbackName(for: payment, originalLabel: originalLabel) : merchant,
            displayLabel: displayLabel,
            valueDate: valueDate,
            place: place,
            cardLastFour: cardLastFour,
            cardFirstFour: cardFirstFour,
            cardCountry: cardCountry,
            originalCurrencyAmount: originalCurrencyAmount,
            motif: motif,
            reference: reference,
            emetteur: emetteur,
            normalizedKey: LabelNormalizer.learningKey(from: originalLabel),
            matchedRule: false
        )
    }

    private static func detectPaymentType(in text: String) -> PaymentType {
        for prefix in prefixes where text.hasPrefix(prefix.text) {
            return prefix.type
        }
        return .unknown
    }

    private static func stripPrefix(_ text: String) -> String {
        guard let prefix = prefixes.first(where: { text.hasPrefix($0.text) }) else {
            return text
        }
        return String(text.dropFirst(prefix.text.count)).trimmingCharacters(in: .whitespaces)
    }

    private static func extractCard(from text: String) -> (
        firstFour: String,
        lastFour: String,
        country: String,
        originalAmount: String,
        remainder: String
    )? {
        let maskedPattern = #"CARTE\s+(\d{4})X{8}(\d{4})(?:\s+([A-Z]{3}))?(?:\s+(\d+[.,]\d{2})\s*EUR)?"#
        if let regex = try? NSRegularExpression(pattern: maskedPattern),
           let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
           let firstRange = Range(match.range(at: 1), in: text),
           let lastRange = Range(match.range(at: 2), in: text),
           let fullRange = Range(match.range, in: text) {
            var remainder = text
            remainder.removeSubrange(fullRange)
            return (
                String(text[firstRange]),
                String(text[lastRange]),
                string(in: text, match: match, group: 3),
                string(in: text, match: match, group: 4),
                cleanup(remainder)
            )
        }

        let compactPattern = #"CARTE\*?\s*(\d{4})"#
        if let regex = try? NSRegularExpression(pattern: compactPattern),
           let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
           let lastRange = Range(match.range(at: 1), in: text),
           let fullRange = Range(match.range, in: text) {
            var remainder = text
            remainder.removeSubrange(fullRange)
            return ("", String(text[lastRange]), "", "", cleanup(remainder))
        }

        return nil
    }

    private static func string(in text: String, match: NSTextCheckingResult, group: Int) -> String {
        guard match.range(at: group).location != NSNotFound,
              let range = Range(match.range(at: group), in: text) else {
            return ""
        }
        return String(text[range])
    }

    private static func cleanup(_ text: String) -> String {
        text.replacing(#/\s+/#, with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static let labeledFieldKeys = [
        "NUMERO DE CLIENT",
        "NUMERO DE COMPTE",
        "EMETTEUR",
        "MOTIF",
        "REF"
    ]

    private static func extractLabeledFields(from text: String) -> (values: [String: String], remainder: String) {
        let alternation = labeledFieldKeys
            .map { NSRegularExpression.escapedPattern(for: $0) }
            .joined(separator: "|")
        guard let regex = try? NSRegularExpression(pattern: "(\(alternation))\\s*:") else {
            return ([:], text)
        }

        let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
        guard let first = matches.first else {
            return ([:], text)
        }

        var values: [String: String] = [:]
        let nsText = text as NSString
        let remainder = nsText.substring(to: first.range.location)
            .trimmingCharacters(in: .whitespacesAndNewlines)

        for (index, match) in matches.enumerated() {
            let key = nsText.substring(with: match.range(at: 1))
            let valueStart = match.range.upperBound
            let valueEnd = index + 1 < matches.count ? matches[index + 1].range.location : nsText.length
            let value = nsText.substring(with: NSRange(location: valueStart, length: valueEnd - valueStart))
                .trimmingCharacters(in: .whitespacesAndNewlines)
            if value.isEmpty == false {
                values[key] = value
            }
        }

        return (values, remainder)
    }

    private static func assignIfEmpty(_ target: inout String, _ value: String?) {
        guard let value, value.isEmpty == false, target.isEmpty else { return }
        target = value
    }

    private static func extractValueDate(from text: String) -> (date: Date, place: String, remainder: String)? {
        let pattern = #"DU\s+(\d{2}[/-]\d{2}[/-]\d{2,4}|\d{6})(?:\s+(\d{1,2})H(\d{2}))?(?:\s+A\s+(.+))?"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
              let tokenRange = Range(match.range(at: 1), in: text) else {
            return nil
        }
        let token = String(text[tokenRange])
        let hour = int(in: text, match: match, group: 2)
        let minute = int(in: text, match: match, group: 3)
        guard let date = FrenchDateParsing.parseLabelDate(token: token, hour: hour, minute: minute),
              let fullRange = Range(match.range, in: text) else {
            return nil
        }

        var remainder = text
        remainder.removeSubrange(fullRange)
        remainder = remainder
            .replacing(#/\s+/#, with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return (date, string(in: text, match: match, group: 4), remainder)
    }

    private static func int(in text: String, match: NSTextCheckingResult, group: Int) -> Int? {
        let raw = string(in: text, match: match, group: group)
        guard raw.isEmpty == false else { return nil }
        return Int(raw)
    }

    private static func fallbackName(for payment: PaymentType, originalLabel: String) -> String {
        switch payment {
        case .atmWithdrawal: "Retrait distributeur"
        case .bankFee: "Commissions"
        default: originalLabel
        }
    }
}
