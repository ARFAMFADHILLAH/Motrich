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

class Transaction {
  final String id;
  final String title;
  final double amount;
  final bool isIncome;
  final String category;
  final DateTime date;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.isIncome,
    required this.category,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'isIncome': isIncome,
        'category': category,
        'date': date.toIso8601String(),
      };

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: json['id'],
        title: json['title'],
        amount: json['amount'],
        isIncome: json['isIncome'],
        category: json['category'],
        date: DateTime.parse(json['date']),
      );
}

class MotrichApp extends StatelessWidget {
  const MotrichApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Motrich Money Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          primary: Colors.blue.shade700,
          surface: Colors.grey.shade50,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey.shade100,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  List<Transaction> _transactions = [];
  String _filter = 'Semua'; // Semua, Pemasukan, Pengeluaran
  final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeInOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('transactions');
    if (data != null) {
      final List decoded = jsonDecode(data);
      setState(() {
        _transactions = decoded.map((e) => Transaction.fromJson(e)).toList();
      });
    }
  }

  Future<void> _saveTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_transactions.map((e) => e.toJson()).toList());
    await prefs.setString('transactions', encoded);
  }

  void _addTransaction(String title, double amount, bool isIncome, String category) {
    setState(() {
      _transactions.insert(
        0,
        Transaction(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: title,
          amount: amount,
          isIncome: isIncome,
          category: category,
          date: DateTime.now(),
        ),
      );
    });
    _saveTransactions();
    _animController.forward(from: 0.0);
  }

  void _deleteTransaction(String id) {
    setState(() {
      _transactions.removeWhere((tx) => tx.id == id);
    });
    _saveTransactions();
  }

  double get _totalBalance {
    return _transactions.fold(0, (sum, tx) => tx.isIncome ? sum + tx.amount : sum - tx.amount);
  }

  double get _totalIncome {
    return _transactions.where((tx) => tx.isIncome).fold(0, (sum, tx) => sum + tx.amount);
  }

  double get _totalExpense {
    return _transactions.where((tx) => !tx.isIncome).fold(0, (sum, tx) => sum + tx.amount);
  }

  List<Transaction> get _filteredTransactions {
    if (_filter == 'Pemasukan') {
      return _transactions.where((tx) => tx.isIncome).toList();
    } else if (_filter == 'Pengeluaran') {
      return _transactions.where((tx) => !tx.isIncome).toList();
    }
    return _transactions;
  }

  void _showAddModal(BuildContext context) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    bool isIncome = false;
    String category = 'Makanan';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Tambah Transaksi Baru',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Nama Transaksi',
                      prefixIcon: const Icon(Icons.description_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Jumlah (Rp)',
                      prefixIcon: const Icon(Icons.money),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Tipe Transaksi: ', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Pengeluaran'),
                        selected: !isIncome,
                        selectedColor: Colors.red.shade100,
                        onSelected: (val) => setModalState(() => isIncome = false),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Pemasukan'),
                        selected: isIncome,
                        selectedColor: Colors.green.shade100,
                        onSelected: (val) => setModalState(() => isIncome = true),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: category,
                    items: ['Makanan', 'Transport', 'Belanja', 'Gaji', 'Tagihan', 'Lainnya']
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) => setModalState(() => category = val!),
                    decoration: InputDecoration(
                      labelText: 'Kategori',
                      prefixIcon: const Icon(Icons.category_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      final title = titleController.text.trim();
                      final amount = double.tryParse(amountController.text) ?? 0;
                      if (title.isNotEmpty && amount > 0) {
                        _addTransaction(title, amount, isIncome, category);
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Simpan Transaksi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
    final filteredList = _filteredTransactions;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.account_balance_wallet, color: Colors.white),
            SizedBox(width: 10),
            Text('Motrich Manager', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTransactions,
            tooltip: 'Muat Ulang',
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Column(
          children: [
            // Dashboard Card
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade800, Colors.blue.shade500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Saldo Tersedia', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 6),
                  Text(
                    currencyFormatter.format(_totalBalance),
                    style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(color: Colors.white24, height: 1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.white24,
                            child: Icon(Icons.arrow_downward, color: Colors.greenAccent, size: 18),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Pemasukan', style: TextStyle(color: Colors.white70, fontSize: 12)),
                              Text(currencyFormatter.format(_totalIncome), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.white24,
                            child: Icon(Icons.arrow_upward, color: Colors.redAccent, size: 18),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Pengeluaran', style: TextStyle(color: Colors.white70, fontSize: 12)),
                              Text(currencyFormatter.format(_totalExpense), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Filter Chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Text('Riwayat', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const Spacer(),
                  ChoiceChip(
                    label: const Text('Semua'),
                    selected: _filter == 'Semua',
                    selectedColor: Colors.blue.shade100,
                    onSelected: (val) => setState(() => _filter = 'Semua'),
                  ),
                  const SizedBox(width: 6),
                  ChoiceChip(
                    label: const Text('Masuk'),
                    selected: _filter == 'Pemasukan',
                    selectedColor: Colors.green.shade100,
                    onSelected: (val) => setState(() => _filter = 'Pemasukan'),
                  ),
                  const SizedBox(width: 6),
                  ChoiceChip(
                    label: const Text('Keluar'),
                    selected: _filter == 'Pengeluaran',
                    selectedColor: Colors.red.shade100,
                    onSelected: (val) => setState(() => _filter = 'Pengeluaran'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Transactions List with Animation
            Expanded(
              child: filteredList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text('Belum ada transaksi.', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredList.length,
                      padding: const EdgeInsets.only(bottom: 80),
                      itemBuilder: (context, index) {
                        final tx = filteredList[index];
                        return AnimatedContainer(
                          duration: Duration(milliseconds: 300 + (index * 50)),
                          curve: Curves.easeOut,
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              leading: CircleAvatar(
                                backgroundColor: tx.isIncome ? Colors.green.shade50 : Colors.red.shade50,
                                child: Icon(
                                  tx.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                                  color: tx.isIncome ? Colors.green : Colors.red,
                                ),
                              ),
                              title: Text(tx.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              subtitle: Text('${tx.category} • ${DateFormat('dd MMM yyyy', 'id_ID').format(tx.date)}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${tx.isIncome ? '+' : '-'}${currencyFormatter.format(tx.amount)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: tx.isIncome ? Colors.green.shade700 : Colors.red.shade700,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.grey),
                                    onPressed: () => _deleteTransaction(tx.id),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
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
