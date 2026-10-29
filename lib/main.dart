import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const MotrichApp());
}

// Data Models
class Wallet {
  final String id;
  final String name;
  final String type; // Cash, Bank, E-Wallet
  double balance;

  Wallet({required this.id, required this.name, required this.type, required this.balance});

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'type': type, 'balance': balance};
  factory Wallet.fromJson(Map<String, dynamic> json) => Wallet(
        id: json['id'],
        name: json['name'],
        type: json['type'],
        balance: json['balance'],
      );
}

class Transaction {
  final String id;
  final String title;
  final double amount;
  final bool isIncome;
  final String category;
  final String walletId;
  final DateTime date;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.isIncome,
    required this.category,
    required this.walletId,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'isIncome': isIncome,
        'category': category,
        'walletId': walletId,
        'date': date.toIso8601String(),
      };

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: json['id'],
        title: json['title'],
        amount: json['amount'],
        isIncome: json['isIncome'],
        category: json['category'],
        walletId: json['walletId'] ?? '1',
        date: DateTime.parse(json['date']),
      );
}

class Budget {
  final String period; // Harian, Bulanan, Tahunan
  final double limit;
  Budget({required this.period, required this.limit});

  Map<String, dynamic> toJson() => {'period': period, 'limit': limit};
  factory Budget.fromJson(Map<String, dynamic> json) => Budget(
        period: json['period'],
        limit: json['limit'],
      );
}

class SavingGoal {
  final String id;
  final String title;
  final double targetAmount;
  double currentAmount;

  SavingGoal({required this.id, required this.title, required this.targetAmount, required this.currentAmount});

  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'targetAmount': targetAmount, 'currentAmount': currentAmount};
  factory SavingGoal.fromJson(Map<String, dynamic> json) => SavingGoal(
        id: json['id'],
        title: json['title'],
        targetAmount: json['targetAmount'],
        currentAmount: json['currentAmount'],
      );
}

class Bill {
  final String id;
  final String title;
  final double amount;
  final DateTime dueDate;
  bool isPaid;

  Bill({required this.id, required this.title, required this.amount, required this.dueDate, required this.isPaid});

  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'amount': amount, 'dueDate': dueDate.toIso8601String(), 'isPaid': isPaid};
  factory Bill.fromJson(Map<String, dynamic> json) => Bill(
        id: json['id'],
        title: json['title'],
        amount: json['amount'],
        dueDate: DateTime.parse(json['dueDate']),
        isPaid: json['isPaid'],
      );
}

class Debt {
  final String id;
  final String name;
  final double amount;
  final bool isPayable; // true = Utang (saya pinjam), false = Piutang (orang pinjam ke saya)
  bool isSettled;

  Debt({required this.id, required this.name, required this.amount, required this.isPayable, required this.isSettled});

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'amount': amount, 'isPayable': isPayable, 'isSettled': isSettled};
  factory Debt.fromJson(Map<String, dynamic> json) => Debt(
        id: json['id'],
        name: json['name'],
        amount: json['amount'],
        isPayable: json['isPayable'],
        isSettled: json['isSettled'],
      );
}

// App Root
class MotrichApp extends StatelessWidget {
  const MotrichApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Motrich Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, primary: Colors.blue.shade700),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey.shade100,
        appBarTheme: const AppBarTheme(backgroundColor: Colors.blue, foregroundColor: Colors.white, elevation: 0),
      ),
      home: const MainDashboard(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _currentIndex = 0;
  List<Wallet> _wallets = [];
  List<Transaction> _transactions = [];
  List<Budget> _budgets = [];
  List<SavingGoal> _savings = [];
  List<Bill> _bills = [];
  List<Debt> _debts = [];

  final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Wallets
    final String? wData = prefs.getString('wallets');
    if (wData != null) {
      _wallets = (jsonDecode(wData) as List).map((e) => Wallet.fromJson(e)).toList();
    } else {
      _wallets = [
        Wallet(id: '1', name: 'Dompet Cash', type: 'Cash', balance: 500000),
        Wallet(id: '2', name: 'BCA Utama', type: 'Bank', balance: 2500000),
        Wallet(id: '3', name: 'GoPay / DANA', type: 'E-Wallet', balance: 350000),
      ];
    }

    // Transactions
    final String? tData = prefs.getString('transactions');
    if (tData != null) {
      _transactions = (jsonDecode(tData) as List).map((e) => Transaction.fromJson(e)).toList();
    }

    // Budgets
    final String? bData = prefs.getString('budgets');
    if (bData != null) {
      _budgets = (jsonDecode(bData) as List).map((e) => Budget.fromJson(e)).toList();
    } else {
      _budgets = [
        Budget(period: 'Harian', limit: 100000),
        Budget(period: 'Bulanan', limit: 3000000),
        Budget(period: 'Tahunan', limit: 36000000),
      ];
    }

    // Savings
    final String? sData = prefs.getString('savings');
    if (sData != null) {
      _savings = (jsonDecode(sData) as List).map((e) => SavingGoal.fromJson(e)).toList();
    } else {
      _savings = [SavingGoal(id: '1', title: 'Beli Laptop Baru', targetAmount: 10000000, currentAmount: 3500000)];
    }

    // Bills
    final String? billData = prefs.getString('bills');
    if (billData != null) {
      _bills = (jsonDecode(billData) as List).map((e) => Bill.fromJson(e)).toList();
    } else {
      _bills = [Bill(id: '1', title: 'Listrik & WiFi', amount: 350000, dueDate: DateTime.now().add(const Duration(days: 3)), isPaid: false)];
    }

    // Debts
    final String? dData = prefs.getString('debts');
    if (dData != null) {
      _debts = (jsonDecode(dData) as List).map((e) => Debt.fromJson(e)).toList();
    } else {
      _debts = [Debt(id: '1', name: 'Pinjam Teman', amount: 150000, isPayable: true, isSettled: false)];
    }

    setState(() {});
  }

  Future<void> _saveAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('wallets', jsonEncode(_wallets.map((e) => e.toJson()).toList()));
    await prefs.setString('transactions', jsonEncode(_transactions.map((e) => e.toJson()).toList()));
    await prefs.setString('budgets', jsonEncode(_budgets.map((e) => e.toJson()).toList()));
    await prefs.setString('savings', jsonEncode(_savings.map((e) => e.toJson()).toList()));
    await prefs.setString('bills', jsonEncode(_bills.map((e) => e.toJson()).toList()));
    await prefs.setString('debts', jsonEncode(_debts.map((e) => e.toJson()).toList()));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeDashboardTab(
        wallets: _wallets,
        transactions: _transactions,
        currencyFormatter: currencyFormatter,
        onAddTransaction: (tx, walletId) {
          setState(() {
            _transactions.insert(0, tx);
            final w = _wallets.firstWhere((element) => element.id == walletId);
            if (tx.isIncome) {
              w.balance += tx.amount;
            } else {
              w.balance -= tx.amount;
            }
          });
          _saveAllData();
        },
        onDeleteTransaction: (id) {
          final tx = _transactions.firstWhere((element) => element.id == id);
          final w = _wallets.firstWhere((element) => element.id == tx.walletId);
          setState(() {
            if (tx.isIncome) {
              w.balance -= tx.amount;
            } else {
              w.balance += tx.amount;
            }
            _transactions.removeWhere((element) => element.id == id);
          });
          _saveAllData();
        },
        budgets: _budgets,
      ),
      ReportTab(transactions: _transactions, currencyFormatter: currencyFormatter),
      BudgetTab(budgets: _budgets, transactions: _transactions, currencyFormatter: currencyFormatter, onUpdateBudget: (budgets) {
        setState(() => _budgets = budgets);
        _saveAllData();
      }),
      MoreModulesTab(
        savings: _savings,
        bills: _bills,
        debts: _debts,
        currencyFormatter: currencyFormatter,
        onUpdate: () => _saveAllData(),
      ),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (val) => setState(() => _currentIndex = val),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Utama'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'Laporan'),
          NavigationDestination(icon: Icon(Icons.pie_chart_outline), selectedIcon: Icon(Icons.pie_chart), label: 'Budget'),
          NavigationDestination(icon: Icon(Icons.folder_open_outlined), selectedIcon: Icon(Icons.folder), label: 'Fitur Lain'),
        ],
      ),
    );
  }
}

// 1. Tab Utama (Dashboard & Dompet)
class HomeDashboardTab extends StatelessWidget {
  final List<Wallet> wallets;
  final List<Transaction> transactions;
  final NumberFormat currencyFormatter;
  final Function(Transaction, String) onAddTransaction;
  final Function(String) onDeleteTransaction;
  final List<Budget> budgets;

  const HomeDashboardTab({
    super.key,
    required this.wallets,
    required this.transactions,
    required this.currencyFormatter,
    required this.onAddTransaction,
    required this.onDeleteTransaction,
    required this.budgets,
  });

  double get totalBalance => wallets.fold(0, (sum, item) => sum + item.balance);
  double get totalIncome => transactions.where((t) => t.isIncome).fold(0, (sum, t) => sum + t.amount);
  double get totalExpense => transactions.where((t) => !t.isIncome).fold(0, (sum, t) => sum + t.amount);

  void _showAddModal(BuildContext context) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    bool isIncome = false;
    String category = 'Makanan';
    String selectedWalletId = wallets.isNotEmpty ? wallets.first.id : '1';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 20, right: 20, top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Catat Transaksi', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue), textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  TextField(controller: titleController, decoration: InputDecoration(labelText: 'Keterangan', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                  const SizedBox(height: 12),
                  TextField(controller: amountController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Jumlah (Rp)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Tipe: '),
                      ChoiceChip(label: const Text('Pengeluaran'), selected: !isIncome, selectedColor: Colors.red.shade100, onSelected: (val) => setModalState(() => isIncome = false)),
                      const SizedBox(width: 8),
                      ChoiceChip(label: const Text('Pemasukan'), selected: isIncome, selectedColor: Colors.green.shade100, onSelected: (val) => setModalState(() => isIncome = true)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: category,
                    items: ['Makanan', 'Transport', 'Belanja', 'Gaji', 'Tagihan', 'Hiburan', 'Investasi', 'Kesehatan', 'Pendidikan', 'Lainnya']
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) => setModalState(() => category = val!),
                    decoration: InputDecoration(labelText: 'Kategori', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedWalletId,
                    items: wallets.map((w) => DropdownMenuItem(value: w.id, child: Text('${w.name} (${w.type})'))).toList(),
                    onChanged: (val) => setModalState(() => selectedWalletId = val!),
                    decoration: InputDecoration(labelText: 'Sumber Dompet', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    onPressed: () {
                      final title = titleController.text.trim();
                      final amount = double.tryParse(amountController.text) ?? 0;
                      if (title.isNotEmpty && amount > 0) {
                        final tx = Transaction(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          title: title,
                          amount: amount,
                          isIncome: isIncome,
                          category: category,
                          walletId: selectedWalletId,
                          date: DateTime.now(),
                        );
                        onAddTransaction(tx, selectedWalletId);
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Simpan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Motrich Financial Manager', style: TextStyle(fontWeight: FontWeight.bold))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Total Balance Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.blue.shade900, Colors.blue.shade600]),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total Saldo Seluruh Dompet', style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 4),
                Text(currencyFormatter.format(totalBalance), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                const Divider(color: Colors.white24, height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      const Icon(Icons.arrow_downward, color: Colors.greenAccent, size: 18),
                      const SizedBox(width: 4),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Masuk', style: TextStyle(color: Colors.white70, fontSize: 10)),
                        Text(currencyFormatter.format(totalIncome), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      ]),
                    ]),
                    Row(children: [
                      const Icon(Icons.arrow_upward, color: Colors.redAccent, size: 18),
                      const SizedBox(width: 4),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Keluar', style: TextStyle(color: Colors.white70, fontSize: 10)),
                        Text(currencyFormatter.format(totalExpense), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      ]),
                    ]),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Wallets Section
          const Text('Dompet & Rekening', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: wallets.length,
              itemBuilder: (context, index) {
                final w = wallets[index];
                return Container(
                  width: 150,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(w.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(currencyFormatter.format(w.balance), style: TextStyle(color: Colors.blue.shade800, fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(w.type, style: TextStyle(color: Colors.grey.shade500, fontSize: 10)),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          // Recent Transactions
          const Text('Transaksi Terbaru', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          transactions.isEmpty
              ? const Center(child: Padding(padding: EdgeInsets.all(30), child: Text('Belum ada transaksi.', style: TextStyle(color: Colors.grey))))
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: transactions.length > 5 ? 5 : transactions.length,
                  itemBuilder: (context, index) {
                    final tx = transactions[index];
                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: tx.isIncome ? Colors.green.shade50 : Colors.red.shade50,
                          child: Icon(tx.isIncome ? Icons.arrow_downward : Icons.arrow_upward, color: tx.isIncome ? Colors.green : Colors.red),
                        ),
                        title: Text(tx.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${tx.category} • ${DateFormat('dd MMM', 'id_ID').format(tx.date)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('${tx.isIncome ? '+' : '-'}${currencyFormatter.format(tx.amount)}', style: TextStyle(fontWeight: FontWeight.bold, color: tx.isIncome ? Colors.green : Colors.red)),
                            IconButton(icon: const Icon(Icons.delete_outline, size: 20, color: Colors.grey), onPressed: () => onDeleteTransaction(tx.id)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        onPressed: () => _showAddModal(context),
        icon: const Icon(Icons.add),
        label: const Text('Transaksi'),
      ),
    );
  }
}

// 2. Tab Laporan (Harian, Mingguan, Bulanan, Tahunan)
class ReportTab extends StatefulWidget {
  final List<Transaction> transactions;
  final NumberFormat currencyFormatter;

  const ReportTab({super.key, required this.transactions, required this.currencyFormatter});

  @override
  State<ReportTab> createState() => _ReportTabState();
}

class _ReportTabState extends State<ReportTab> {
  String _period = 'Bulanan'; // Harian, Mingguan, Bulanan, Tahunan

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    List<Transaction> filtered = widget.transactions.where((tx) {
      if (_period == 'Harian') {
        return tx.date.year == now.year && tx.date.month == now.month && tx.date.day == now.day;
      } else if (_period == 'Mingguan') {
        return now.difference(tx.date).inDays <= 7;
      } else if (_period == 'Bulanan') {
        return tx.date.year == now.year && tx.date.month == now.month;
      } else { // Tahunan
        return tx.date.year == now.year;
      }
    }).toList();

    double income = filtered.where((t) => t.isIncome).fold(0, (sum, t) => sum + t.amount);
    double expense = filtered.where((t) => !t.isIncome).fold(0, (sum, t) => sum + t.amount);

    return Scaffold(
      appBar: AppBar(title: const Text('Laporan Keuangan', style: TextStyle(fontWeight: FontWeight.bold))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'Harian', label: Text('Hari')),
                ButtonSegment(value: 'Mingguan', label: Text('Minggu')),
                ButtonSegment(value: 'Bulanan', label: Text('Bulan')),
                ButtonSegment(value: 'Tahunan', label: Text('Tahun')),
              ],
              selected: {_period},
              onSelectionChanged: (val) => setState(() => _period = val.first),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.blue.shade100)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(children: [
                  const Text('Pemasukan', style: TextStyle(color: Colors.grey)),
                  Text(widget.currencyFormatter.format(income), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16)),
                ]),
                const VerticalDivider(),
                Column(children: [
                  const Text('Pengeluaran', style: TextStyle(color: Colors.grey)),
                  Text(widget.currencyFormatter.format(expense), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 16)),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('Tidak ada laporan untuk periode ini.', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final tx = filtered[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: tx.isIncome ? Colors.green.shade50 : Colors.red.shade50,
                          child: Icon(tx.isIncome ? Icons.arrow_downward : Icons.arrow_upward, color: tx.isIncome ? Colors.green : Colors.red),
                        ),
                        title: Text(tx.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${tx.category} • ${DateFormat('dd MMM yyyy', 'id_ID').format(tx.date)}'),
                        trailing: Text('${tx.isIncome ? '+' : '-'}${widget.currencyFormatter.format(tx.amount)}', style: TextStyle(fontWeight: FontWeight.bold, color: tx.isIncome ? Colors.green : Colors.red)),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// 3. Tab Budget (Atur Batas Harian, Bulanan, Tahunan)
class BudgetTab extends StatelessWidget {
  final List<Budget> budgets;
  final List<Transaction> transactions;
  final NumberFormat currencyFormatter;
  final Function(List<Budget>) onUpdateBudget;

  const BudgetTab({super.key, required this.budgets, required this.transactions, required this.currencyFormatter, required this.onUpdateBudget});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    double dailyExp = transactions.where((t) => !t.isIncome && t.date.day == now.day && t.date.month == now.month && t.date.year == now.year).fold(0, (sum, t) => sum + t.amount);
    double monthlyExp = transactions.where((t) => !t.isIncome && t.date.month == now.month && t.date.year == now.year).fold(0, (sum, t) => sum + t.amount);
    double yearlyExp = transactions.where((t) => !t.isIncome && t.date.year == now.year).fold(0, (sum, t) => sum + t.amount);

    return Scaffold(
      appBar: AppBar(title: const Text('Anggaran Pengeluaran', style: TextStyle(fontWeight: FontWeight.bold))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: budgets.map((b) {
          double spent = b.period == 'Harian' ? dailyExp : (b.period == 'Bulanan' ? monthlyExp : yearlyExp);
          double progress = b.limit > 0 ? (spent / b.limit).clamp(0.0, 1.0) : 0.0;
          bool isOver = spent > b.limit;

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Budget ${b.period}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('${currencyFormatter.format(spent)} / ${currencyFormatter.format(b.limit)}', style: TextStyle(fontWeight: FontWeight.bold, color: isOver ? Colors.red : Colors.blue.shade700)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(value: progress, color: isOver ? Colors.red : Colors.blue, backgroundColor: Colors.grey.shade200, minHeight: 8),
                  const SizedBox(height: 8),
                  Text(isOver ? '⚠️ Pengeluaran melewati batas budget!' : 'Aman dalam batas anggaran.', style: TextStyle(color: isOver ? Colors.red : Colors.green, fontSize: 12)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// 4. Tab Modul Lainnya (Tabungan, Tagihan, Utang)
class MoreModulesTab extends StatelessWidget {
  final List<SavingGoal> savings;
  final List<Bill> bills;
  final List<Debt> debts;
  final NumberFormat currencyFormatter;
  final VoidCallback onUpdate;

  const MoreModulesTab({super.key, required this.savings, required this.bills, required this.debts, required this.currencyFormatter, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fitur Keuangan Lainnya', style: TextStyle(fontWeight: FontWeight.bold))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('🎯 Target Tabungan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...savings.map((s) => Card(
                child: ListTile(
                  title: Text(s.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Terkumpul: ${currencyFormatter.format(s.currentAmount)} dari ${currencyFormatter.format(s.targetAmount)}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.blue),
                    onPressed: () {
                      s.currentAmount += 100000;
                      onUpdate();
                    },
                  ),
                ),
              )),
          const SizedBox(height: 20),
          const Text('💡 Pengingat Tagihan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...bills.map((bill) => Card(
                child: ListTile(
                  title: Text(bill.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Rp ${bill.amount} • Jatuh tempo: ${DateFormat('dd MMM yyyy', 'id_ID').format(bill.dueDate)}'),
                  trailing: Checkbox(
                    value: bill.isPaid,
                    onChanged: (val) {
                      bill.isPaid = val ?? false;
                      onUpdate();
                    },
                  ),
                ),
              )),
          const SizedBox(height: 20),
          const Text('🤝 Utang & Piutang', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...debts.map((d) => Card(
                child: ListTile(
                  leading: Icon(d.isPayable ? Icons.call_made : Icons.call_received, color: d.isPayable ? Colors.red : Colors.green),
                  title: Text(d.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${d.isPayable ? "Utang saya" : "Piutang orang"} • ${currencyFormatter.format(d.amount)}'),
                  trailing: Switch(
                    value: d.isSettled,
                    onChanged: (val) {
                      d.isSettled = val;
                      onUpdate();
                    },
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
