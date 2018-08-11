import Foundation


typealias SectionConfig = [String: String]
typealias Config = [String: SectionConfig]


func trim(_ s: String) -> String {
    let whitespaces = CharacterSet(charactersIn: " \n\r\t")
    return s.trimmingCharacters(in: whitespaces)
}


func stripComment(_ line: String) -> String {
    let parts = line.split(
        separator: "#",
        maxSplits: 1,
        omittingEmptySubsequences: false)
    if parts.count > 0 {
        return String(parts[0])
    }
    return ""
}


func parseSectionHeader(_ line: String) -> String {
    let from = line.index(after: line.startIndex)
    let to = line.index(before: line.endIndex)
    return String(line[from..<to])
}


func parseLine(_ line: String) -> (String, String)? {
    let parts = stripComment(line).split(separator: "=", maxSplits: 1)
    if parts.count == 2 {
        let k = trim(String(parts[0]))
        let v = trim(String(parts[1]))
        return (k, v)
    }
    return nil
}


func parseConfig(_ filename : String) -> Config? {
    guard let f = try? String(contentsOfFile: filename) else {return nil}
    var config = Config()
    var currentSectionName = "main"
    for line in f.components(separatedBy: "\n") {
        let line = trim(line)
        if line.hasPrefix("[") && line.hasSuffix("]") {
            currentSectionName = parseSectionHeader(line)
        } else if let (k, v) = parseLine(line) {
            var section = config[currentSectionName] ?? [:]
            section[k] = v
            config[currentSectionName] = section
        }
    }
    return config
}
