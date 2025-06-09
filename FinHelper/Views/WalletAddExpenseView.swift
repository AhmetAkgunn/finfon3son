import SwiftUI

struct WalletAddExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: MainViewModel
    @State private var title = ""
    @State private var amount = ""
    @State private var selectedCategory = ExpenseCategory.other
    
    var body: some View {
        NavigationView {
            Form {
                // Harcama başlığı
                Section(header: Text("Harcama Detayları")) {
                    TextField("Başlık", text: $title)
                    
                    HStack {
                        Text("₺")
                        TextField("Tutar", text: $amount)
                            .keyboardType(.decimalPad)
                    }
                    
                    Picker("Kategori", selection: $selectedCategory) {
                        ForEach(ExpenseCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                }
            }
            .navigationTitle("Harcama Ekle")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Vazgeç") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Ekle") {
                        addExpense()
                    }
                    .disabled(!isFormValid)
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        !title.isEmpty && !amount.isEmpty && Double(amount) != nil
    }
    
    private func addExpense() {
        if let amountValue = Double(amount) {
            viewModel.addExpense(
                title: title,
                amount: amountValue,
                category: selectedCategory
            )
        dismiss()
        }
    }
} 