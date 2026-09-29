import Foundation

final class SharedStringsParser: NSObject, XMLParserDelegate {
    private var strings: [String] = []
    private var current = ""
    private var isText = false
    private var skipPhonetic = false

    static func parse(data: Data) -> [String] {
        let parser = SharedStringsParser()
        let xml = XMLParser(data: data)
        xml.delegate = parser
        xml.parse()
        return parser.strings
    }

    func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes attributeDict: [String: String] = [:]
    ) {
        if elementName == "rPh" {
            skipPhonetic = true
        }
        if elementName == "t" && skipPhonetic == false {
            isText = true
            current = ""
        }
        if elementName == "si" {
            current = ""
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if isText {
            current += string
        }
    }

    func parser(
        _ parser: XMLParser,
        didEndElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?
    ) {
        if elementName == "rPh" {
            skipPhonetic = false
        }
        if elementName == "t" {
            isText = false
        }
        if elementName == "si" {
            strings.append(current)
            current = ""
        }
    }
}
