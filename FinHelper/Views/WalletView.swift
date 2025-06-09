import SwiftUI

struct WalletView: View {
    @ObservedObject var viewModel: MainViewModel
    @State private var showingAddExpense = false
    @State private var showingExpenseDetail = false
    @State private var selectedExpense: ExpenseRow.Data?
    
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
                                selectedExpense = ExpenseRow.Data(
                                    id: expense.id,
                                    title: expense.title,
                                    amount: expense.amount,
                                    date: expense.formattedDate,
                                    icon: expense.category.icon,
                                    category: expense.category
                                )
                                showingExpenseDetail = true
                            }) {
                                ExpenseRow(data: ExpenseRow.Data(
                                    id: expense.id,
                                    title: expense.title,
                                    amount: expense.amount,
                                    date: expense.formattedDate,
                                    icon: expense.category.icon,
                                    category: expense.category
                                ))
                            }
                            .buttonStyle(PlainButtonStyle())
                    }
                    .onDelete { indexSet in
                            viewModel.deleteExpense(at: indexSet)
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
            WalletAddExpenseView(viewModel: viewModel)
                .presentationDetents([.medium])
        }
        .sheet(isPresented: $showingExpenseDetail, onDismiss: {
            selectedExpense = nil // Sheet kapandığında seçili harcamayı sıfırla
        }) {
            if let expense = selectedExpense {
                ExpenseDetailView(expense: expense, viewModel: viewModel)
            }
        }
    }
}

// Harcama satırı bileşeni
struct ExpenseRow: View {
    struct Data: Identifiable {
        let id: UUID
        let title: String
        let amount: Double
        let date: String
        let icon: String
        let category: ExpenseCategory
    }
    
    let data: Data
    
    var body: some View {
        HStack {
            Text(data.icon)
                .font(.title)
            VStack(alignment: .leading) {
                Text(data.title)
                    .font(.headline)
                Text(data.date)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
            Text("₺\(String(format: "%.2f", data.amount))")
                .font(.headline)
        }
        .padding(.vertical, 8)
    }
}

// Harcama detay görünümü
struct ExpenseDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let expense: ExpenseRow.Data
    @ObservedObject var viewModel: MainViewModel
    @State private var title: String
    @State private var amount: String
    @State private var selectedCategory: ExpenseCategory
    
    init(expense: ExpenseRow.Data, viewModel: MainViewModel) {
        self.expense = expense
        self.viewModel = viewModel
        _title = State(initialValue: expense.title)
        _amount = State(initialValue: String(format: "%.2f", expense.amount))
        _selectedCategory = State(initialValue: expense.category)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Harcama Detayları")) {
                    HStack {
                        Text(selectedCategory.icon)
                            .font(.title)
                        TextField("Başlık", text: $title)
                    }
                    
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
                    
                    HStack {
                        Text("Tarih")
                        Spacer()
                        Text(expense.date)
                            .foregroundColor(.gray)
                    }
                }
                
                Section {
                    Button(action: saveChanges) {
                        Text("Değişiklikleri Kaydet")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.blue)
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
        .presentationDetents([.medium])
    }
    
    private func saveChanges() {
        if let newAmount = Double(amount) {
            viewModel.updateExpense(
                id: expense.id,
                title: title,
                amount: newAmount,
                category: selectedCategory
            )
        }
        dismiss()
    }
} 