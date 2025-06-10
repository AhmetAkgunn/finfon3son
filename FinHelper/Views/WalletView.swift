import SwiftUI

struct WalletView: View {
    @ObservedObject var viewModel: MainViewModel
    @State private var showingAddExpense = false
    @State private var showingExpenseDetail = false
    @State private var selectedExpense: Expense?
    
    var body: some View {
        NavigationView {
            VStack {
                // Kullanıcı profil bilgisi
                HStack {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                    VStack(alignment: .leading) {
                        Text(viewModel.currentUser.name)
                            .font(.headline)
                        Text("Aylık Harcamalarım")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                .padding()
                
                // Toplam harcama göstergesi
                if let totalExpense = viewModel.totalExpenses {
                    Text("₺\(String(format: "%.2f", totalExpense))")
                        .font(.system(size: 40, weight: .bold))
                        .padding()
                } else {
                    Text("₺0.00")
                    .font(.system(size: 40, weight: .bold))
                    .padding()
                }
                
                // Harcama listesi
                if viewModel.expenses.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "creditcard")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("Henüz harcama bulunmuyor")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text("Yeni harcama eklemek için + butonuna tıklayın")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding()
                    Spacer()
                } else {
                List {
                        ForEach(viewModel.expenses) { expense in
                            Button(action: {
                                selectedExpense = expense
                            }) {
                                ExpenseRow(expense: expense)
                            }
                    }
                    .onDelete { indexSet in
                            deleteExpenses(at: indexSet)
                        }
                    }
                }
            }
            .navigationTitle("Cüzdan")
            .navigationBarItems(trailing:
                Button(action: { showingAddExpense = true }) {
                    Image(systemName: "plus")
                }
            )
        }
        .sheet(isPresented: $showingAddExpense) {
            NavigationView {
                WalletAddExpenseView(viewModel: viewModel)
            }
        }
        .sheet(item: $selectedExpense) { expense in
            NavigationView {
                ExpenseDetailView(expense: expense, viewModel: viewModel) {
                    selectedExpense = nil
                }
            }
        }
    }
    
    private func deleteExpenses(at offsets: IndexSet) {
        for index in offsets {
            let expense = viewModel.expenses[index]
            viewModel.deleteExpense(expense)
        }
    }
}

// Harcama satırı bileşeni
struct ExpenseRow: View {
    let expense: Expense
    
    var body: some View {
        HStack {
            Text(expense.category.icon)
                .font(.title)
            VStack(alignment: .leading) {
                Text(expense.title)
                    .font(.headline)
                Text(expense.formattedDate)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
            Text("₺\(String(format: "%.2f", expense.amount))")
                .font(.headline)
        }
        .padding(.vertical, 8)
    }
}

// Harcama detay görünümü
struct ExpenseDetailView: View {
    let expense: Expense
    @ObservedObject var viewModel: MainViewModel
    let onDismiss: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var title: String
    @State private var amount: String
    @State private var selectedCategory: ExpenseCategory
    
    init(expense: Expense, viewModel: MainViewModel, onDismiss: @escaping () -> Void) {
        self.expense = expense
        self.viewModel = viewModel
        self.onDismiss = onDismiss
        
        // State değişkenlerini başlangıç değerleriyle ayarla
        _title = State(initialValue: expense.title)
        _amount = State(initialValue: String(format: "%.2f", expense.amount))
        _selectedCategory = State(initialValue: expense.category)
    }
    
    var body: some View {
            Form {
                Section(header: Text("Harcama Detayları")) {
                        TextField("Başlık", text: $title)
                    
                    HStack {
                        Text("₺")
                        TextField("Tutar", text: $amount)
                            .keyboardType(.decimalPad)
                    }
                    
                Picker("Kategori", selection: $selectedCategory) {
                    ForEach(ExpenseCategory.allCases, id: \.self) { category in
                    HStack {
                            Text(category.icon)
                            Text(category.rawValue)
                        }.tag(category)
                    }
                    }
                }
                
                Section {
                    Button(action: saveChanges) {
                        Text("Değişiklikleri Kaydet")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.blue)
                    }
                
                Button(action: deleteExpense) {
                    Text("Harcamayı Sil")
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.red)
                }
                }
            }
            .navigationTitle("Harcama Düzenle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Vazgeç") {
                        dismiss()
                }
            }
        }
    }
    
    private func saveChanges() {
        guard let amountValue = Double(amount) else { return }
        
        var updatedExpense = expense
        updatedExpense.title = title
        updatedExpense.amount = amountValue
        updatedExpense.category = selectedCategory
        
        // Harcamayı güncelle
        viewModel.updateExpense(updatedExpense)
        
        dismiss()
        onDismiss()
    }
    
    private func deleteExpense() {
        viewModel.deleteExpense(expense)
        dismiss()
        onDismiss()
    }
} 