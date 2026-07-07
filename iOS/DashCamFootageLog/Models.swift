import Foundation

struct ClipEntry: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String        // Clip title
    var detail: String      // Incident type
    var date: Date           // Date
    var note: String = ""
}
