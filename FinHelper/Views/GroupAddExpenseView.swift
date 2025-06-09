import SwiftUI

struct GroupAddExpenseView: View {
    @ObservedObject var viewModel: MainViewModel
    @Environment(\.presentationMode) var presentationMode
    let group: Group // Grup parametresi ekledik
    
    @State private var title = ""
    @State private var amount = ""
    @State private var selectedCategory = ExpenseCategory.other
    @State private var paidBy = ""
    @State private var splitEqually = true
    @State private var selectedMembers: Set<String> = []
    
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
                
                // Ödeme yapan kişi
                Section(header: Text("Ödeyen Kişi")) {
                    ForEach(group.members, id: \.self) { member in
                        Button(action: {
                            paidBy = member
                        }) {
                            HStack {
                                Text(member)
                                    .foregroundColor(.primary)
                                Spacer()
                                if paidBy == member {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
                
                // Bölüşme seçenekleri
                Section(header: Text("Bölüşme Şekli")) {
                    Picker("Bölüşme Tipi", selection: $splitEqually) {
                        Text("Eşit Olarak Böl").tag(true)
                        Text("Kişileri Seç").tag(false)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    if !splitEqually {
                        ForEach(group.members, id: \.self) { member in
                            Button(action: {
                                if selectedMembers.contains(member) {
                                    selectedMembers.remove(member)
                                } else {
                                        selectedMembers.insert(member)
                                }
                            }) {
                                HStack {
                                    Text(member)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    if selectedMembers.contains(member) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Harcama Ekle")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Vazgeç") {
                        presentationMode.wrappedValue.dismiss()
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
        !title.isEmpty && !amount.isEmpty && !paidBy.isEmpty &&
        (splitEqually || (!splitEqually && !selectedMembers.isEmpty))
    }
    
    private func addExpense() {
        guard let amountValue = Double(amount) else { return }
        
        let splitBetween = splitEqually ? group.members : Array(selectedMembers)
        
        viewModel.addExpense(
            to: group,
            title: title,
            amount: amountValue,
            paidBy: paidBy,
            splitBetween: splitBetween,
            category: selectedCategory
        )
        
        presentationMode.wrappedValue.dismiss()
    }
} 
