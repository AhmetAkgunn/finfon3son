import Foundation

// Grup modelini tanımlayan yapı
struct Group: Identifiable, Codable {
    let id: UUID
    var name: String
    var members: [String]
    var expenses: [Expense]
    var date: Date
    var icon: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, members, expenses, date, icon
    }
    
    // Gruptaki toplam harcama
    var totalExpenses: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }
    
    // Kişi başı borç hesaplama
    func calculateDebts() -> [String: Double] {
        var debts: [String: Double] = [:]
        
        // Her üye için başlangıç borcu 0
        for member in members {
            debts[member] = 0
        }
        
        // Her harcama için borç hesaplama
        for expense in expenses {
            let amountPerPerson = expense.amountPerPerson
            
            // Ödeme yapan kişiye alacak ekleme
            if let paidBy = expense.paidBy {
                debts[paidBy, default: 0] += expense.amount
            }
            
            // Harcamaya dahil olan kişilerden borç düşme
            if let splitBetween = expense.splitBetween {
                for person in splitBetween {
                debts[person, default: 0] -= amountPerPerson
                }
            }
        }
        
        return debts
    }
    
    // Grup harcaması ekleme
    mutating func addExpense(_ expense: Expense) {
        expenses.append(expense)
    }
    
    // Grup üyesi ekleme
    mutating func addMember(_ member: String) {
        if !members.contains(member) {
            members.append(member)
        }
    }
    
    // Grup üyesi çıkarma
    mutating func removeMember(_ member: String) {
        members.removeAll { $0 == member }
    }
    
    // Borç ödeme işlemi
    mutating func markDebtAsPaid(from debtor: String, to creditor: String, amount: Double, userId: String) {
        let paymentExpense = Expense(
            title: "Borç Ödemesi",
            amount: amount,
            date: Date(),
            category: .other,
            paidBy: debtor,
            splitBetween: [creditor],
            userId: userId
        )
        expenses.append(paymentExpense)
    }
    
    init(name: String, members: [String], expenses: [Expense], date: Date, icon: String) {
        self.id = UUID()
        self.name = name
        self.members = members
        self.expenses = expenses
        self.date = date
        self.icon = icon
    }
} 