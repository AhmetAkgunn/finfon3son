import Foundation

// Harcama kategorileri
enum ExpenseCategory: String, Codable, CaseIterable {
    case food = "Yemek"
    case transportation = "Ulaşım"
    case accommodation = "Konaklama"
    case health = "Sağlık"
    case other = "Diğer"
    
    var icon: String {
        switch self {
        case .food: return "🍽️"
        case .transportation: return "🚗"
        case .accommodation: return "🏨"
        case .health: return "💊"
        case .other: return "📦"
        }
    }
}

// Harcama modeli
struct Expense: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var amount: Double
    let date: Date
    var category: ExpenseCategory
    var paidBy: String?
    var splitBetween: [String]?
    let userId: String
    
    // Formatlı tarih
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.string(from: date)
    }
    
    // Kişi başı düşen miktar
    var amountPerPerson: Double {
        guard let split = splitBetween, !split.isEmpty else { return amount }
        return amount / Double(split.count)
    }
    
    enum CodingKeys: String, CodingKey {
        case id, title, amount, date, category, paidBy, splitBetween, userId
    }
    
    // Kişisel harcama için initializer
    init(title: String, amount: Double, date: Date, category: ExpenseCategory, userId: String) {
        self.id = UUID()
        self.title = title
        self.amount = amount
        self.date = date
        self.category = category
        self.paidBy = nil
        self.splitBetween = nil
        self.userId = userId
    }
    
    // Grup harcaması için initializer
    init(title: String, amount: Double, date: Date, category: ExpenseCategory, paidBy: String, splitBetween: [String], userId: String) {
        self.id = UUID()
        self.title = title
        self.amount = amount
        self.date = date
        self.category = category
        self.paidBy = paidBy
        self.splitBetween = splitBetween
        self.userId = userId
    }
} 