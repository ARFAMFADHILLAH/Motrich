import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'package:supabase_flutter/supabase_flutter.dart' as supabase_auth;

// SUPABASE CONFIG
const String supabaseUrl = 'https://pbqvrcjnqrrexwuddoey.supabase.co';
const String supabasePublishableKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBicXZyY2pucXJyZXh3dWRkb2V5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTM4NTMxMDgsImV4cCI6MjEwOTQyOTEwOH0.DKXRIp3NTLW3KlLKgxcg2SzxDo19z1pXeaJpLPsuPN8';

final Uuid _uuid = Uuid();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  try {
    await Supabase.initialize(
      url: supabaseUrl,
      publishableKey: supabasePublishableKey,
    );
  } catch (e) {
    debugPrint('Supabase init error: $e');
  }

  runApp(const MotrichApp());
}

// Data Models
class Wallet {
  final String id;
  final String userId;
  final String name;
  final String type; // Cash, Bank, E-Wallet
  double balance;

  Wallet({required this.id, required this.userId, required this.name, required this.type, required this.balance});

  Map<String, dynamic> toJson() => {'id': id, 'user_id': userId, 'name': name, 'type': type, 'balance': balance};
  factory Wallet.fromJson(Map<String, dynamic> json) => Wallet(
        id: json['id'].toString(),
        userId: json['user_id']?.toString() ?? '',
        name: json['name'],
        type: json['type'],
        balance: (json['balance'] as num).toDouble(),
      );
}

class TransactionModel {
  final String id;
  final String userId;
  final String title;
  final double amount;
  final bool isIncome;
  final String category;
  final String walletId;
  final DateTime date;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.isIncome,
    required this.category,
    required this.walletId,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'title': title,
        'amount': amount,
        'is_income': isIncome,
        'category': category,
        'wallet_id': walletId,
        'date': date.toIso8601String(),
      };

  factory TransactionModel.fromJson(Map<String, dynamic> json) => TransactionModel(
        id: json['id'].toString(),
        userId: json['user_id']?.toString() ?? '',
        title: json['title'],
        amount: (json['amount'] as num).toDouble(),
        isIncome: json['is_income'] ?? json['isIncome'] ?? false,
        category: json['category'],
        walletId: (json['wallet_id'] ?? json['walletId'] ?? '').toString(),
        date: DateTime.parse(json['date']),
      );
}

class SavingGoal {
  final String id;
  final String userId;
  final String title;
  final double targetAmount;
  double currentAmount;

  SavingGoal({required this.id, required this.userId, required this.title, required this.targetAmount, required this.currentAmount});

  Map<String, dynamic> toJson() => {'id': id, 'user_id': userId, 'title': title, 'target_amount': targetAmount, 'current_amount': currentAmount};
  factory SavingGoal.fromJson(Map<String, dynamic> json) => SavingGoal(
        id: json['id'].toString(),
        userId: json['user_id']?.toString() ?? '',
        title: json['title'],
        targetAmount: (json['target_amount'] ?? json['targetAmount'] as num).toDouble(),
        currentAmount: (json['current_amount'] ?? json['currentAmount'] as num).toDouble(),
      );
}

class Bill {
  final String id;
  final String userId;
  final String title;
  final double amount;
  final DateTime dueDate;
  bool isPaid;

  Bill({required this.id, required this.userId, required this.title, required this.amount, required this.dueDate, required this.isPaid});

  Map<String, dynamic> toJson() => {'id': id, 'user_id': userId, 'title': title, 'amount': amount, 'due_date': dueDate.toIso8601String(), 'is_paid': isPaid};
  factory Bill.fromJson(Map<String, dynamic> json) => Bill(
        id: json['id'].toString(),
        userId: json['user_id']?.toString() ?? '',
        title: json['title'],
        amount: (json['amount'] as num).toDouble(),
        dueDate: DateTime.parse(json['due_date'] ?? json['dueDate']),
        isPaid: json['is_paid'] ?? json['isPaid'] ?? false,
      );
}

class Debt {
  final String id;
  final String userId;
  final String name;
  final double amount;
  final bool isPayable;
  bool isSettled;

  Debt({required this.id, required this.userId, required this.name, required this.amount, required this.isPayable, required this.isSettled});

  Map<String, dynamic> toJson() => {'id': id, 'user_id': userId, 'name': name, 'amount': amount, 'is_payable': isPayable, 'is_settled': isSettled};
  factory Debt.fromJson(Map<String, dynamic> json) => Debt(
        id: json['id'].toString(),
        userId: json['user_id']?.toString() ?? '',
        name: json['name'],
        amount: (json['amount'] as num).toDouble(),
        isPayable: json['is_payable'] ?? json['isPayable'] ?? true,
        isSettled: json['is_settled'] ?? json['isSettled'] ?? false,
      );
}

// Theme Notifier
class ThemeNotifier extends ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  ThemeNotifier() {
    _loadTheme();
  }

  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }
}

final themeNotifier = ThemeNotifier();

// App Root
class MotrichApp extends StatelessWidget {
  const MotrichApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeNotifier,
      builder: (context, _) {
        return MaterialApp(
          title: 'Motrich Manager',
          themeMode: themeNotifier.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, primary: Colors.blue.shade700),
            useMaterial3: true,
            scaffoldBackgroundColor: Colors.grey.shade100,
            appBarTheme: const AppBarTheme(backgroundColor: Colors.blue, foregroundColor: Colors.white, elevation: 0),
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark, primary: Colors.blue.shade300),
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFF121212),
            appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF1F1F1F), foregroundColor: Colors.white, elevation: 0),
          ),
          home: const AuthGate(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

// Auth Gate (Pilih Guest atau Login)
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isChecking = true;
  bool _isLoggedIn = false;
  bool _isGuest = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final guestMode = prefs.getBool('is_guest') ?? false;
    
    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        setState(() {
          _isLoggedIn = true;
          _isChecking = false;
        });
        return;
      }
    } catch (_) {}

    if (guestMode) {
      setState(() {
        _isGuest = true;
        _isChecking = false;
      });
    } else {
      setState(() => _isChecking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_isLoggedIn || _isGuest) {
      return const MainDashboard();
    }

    return const WelcomeScreen();
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.blue.shade600],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.account_balance_wallet, size: 80, color: Colors.white),
            const SizedBox(height: 20),
            const Text('Motrich Manager', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            const Text('Pencatat Keuangan Pribadi dengan Kendali Penuh', style: TextStyle(fontSize: 14, color: Colors.white70), textAlign: TextAlign.center),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.blue.shade800, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
              },
              child: const Text('Masuk / Daftar (Cloud Sync)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('is_guest', true);
                if (context.mounted) {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainDashboard()));
                }
              },
              child: const Text('Gunakan Mode Tamu (Lokal)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

// Login & Register Screen
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isRegister = false;
  bool isLoading = false;

  Future<void> _submit() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email dan Password wajib diisi'), backgroundColor: Colors.red),
      );
      return;
    }
    if (!email.contains('@') || !email.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Format email tidak valid'), backgroundColor: Colors.red),
      );
      return;
    }
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password minimal 6 karakter'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      final client = Supabase.instance.client;
      if (isRegister) {
        await client.auth.signUp(email: email, password: password);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registrasi sukses! Silakan login.'), backgroundColor: Colors.green),
          );
          setState(() => isRegister = false);
        }
      } else {
        await client.auth.signInWithPassword(email: email, password: password);
        if (mounted) {
          // Auto-create default wallet if not exists
          await _ensureDefaultWallet(client);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainDashboard()));
        }
      }
    } on supabase_auth.AuthException catch (e) {
      if (mounted) {
        String msg = e.message;
        if (e.message.contains('Invalid login credentials') || e.message.contains('Invalid credentials')) {
          msg = 'Email atau password salah';
        } else if (e.message.contains('User already registered') || e.message.contains('already exists')) {
          msg = 'Email sudah terdaftar';
        } else if (e.message.contains('Password should be at least 6 characters')) {
          msg = 'Password minimal 6 karakter';
        } else if (e.message.contains('Invalid email')) {
          msg = 'Format email tidak valid';
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _ensureDefaultWallet(SupabaseClient client) async {
    try {
      final user = client.auth.currentUser;
      if (user == null) return;
      
      // Check if user already has wallets
      final existing = await client.from('wallets').select('id').eq('user_id', user.id).limit(1);
      if (existing.isNotEmpty) return;
      
      // Create default wallet
      await client.from('wallets').insert({
        'id': _uuid.v4(),
        'user_id': user.id,
        'name': 'Dompet Utama',
        'type': 'Cash',
        'balance': 0,
      });
    } catch (_) {
      // Ignore wallet creation errors, wallet can be created manually later
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isRegister ? 'Daftar Akun' : 'Masuk Akun')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            TextField(controller: passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder())),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              onPressed: isLoading ? null : _submit,
              child: isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(isRegister ? 'Daftar' : 'Masuk', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () => setState(() => isRegister = !isRegister),
              child: Text(isRegister ? 'Sudah punya akun? Masuk' : 'Belum punya akun? Daftar'),
            ),
          ],
        ),
      ),
    );
  }
}

// Main Dashboard
class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _currentIndex = 0;
  List<Wallet> _wallets = [];
  List<TransactionModel> _transactions = [];
  List<Budget> _budgets = [
    Budget(period: 'Harian', limit: 100000),
    Budget(period: 'Bulanan', limit: 3000000),
    Budget(period: 'Tahunan', limit: 36000000),
  ];
  List<SavingGoal> _savings = [];
  List<Bill> _bills = [];
  List<Debt> _debts = [];
  List<String> _categories = ['Makanan', 'Transport', 'Belanja', 'Gaji', 'Tagihan', 'Hiburan', 'Investasi', 'Kesehatan', 'Pendidikan', 'Lainnya'];

  final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  String get _currentUserId {
    try {
      return Supabase.instance.client.auth.currentUser?.id ?? 'guest';
    } catch (_) {
      return 'guest';
    }
  }

  Future<void> _loadData() async {
    bool isGuest = true;
    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) isGuest = false;
    } catch (_) {}

    if (!isGuest) {
      try {
        final client = Supabase.instance.client;
        final resW = await client.from('wallets').select();
        
        // Auto-create default wallet if none exists
        if (resW.isEmpty) {
          final user = client.auth.currentUser;
          if (user != null) {
            await client.from('wallets').insert({
              'id': _uuid.v4(),
              'user_id': user.id,
              'name': 'Dompet Utama',
              'type': 'Cash',
              'balance': 0,
            });
            // Re-fetch wallets
            final newResW = await client.from('wallets').select();
            setState(() {
              _wallets = (newResW as List).map((e) => Wallet.fromJson(e)).toList();
            });
          }
        } else {
          setState(() {
            _wallets = (resW as List).map((e) => Wallet.fromJson(e)).toList();
          });
        }
        
        final resT = await client.from('transactions').select();
        final resS = await client.from('savings').select();
        final resB = await client.from('bills').select();
        final resD = await client.from('debts').select();

        setState(() {
          _transactions = (resT as List).map((e) => TransactionModel.fromJson(e)).toList();
          _savings = (resS as List).map((e) => SavingGoal.fromJson(e)).toList();
          _bills = (resB as List).map((e) => Bill.fromJson(e)).toList();
          _debts = (resD as List).map((e) => Debt.fromJson(e)).toList();
        });
        return;
      } catch (e) {
        debugPrint('Supabase fetch error, fallback local: $e');
      }
    }

    // Local Storage Fallback
    final prefs = await SharedPreferences.getInstance();
    final wData = prefs.getString('wallets');
    if (wData != null) _wallets = (jsonDecode(wData) as List).map((e) => Wallet.fromJson(e)).toList();

    final tData = prefs.getString('transactions');
    if (tData != null) _transactions = (jsonDecode(tData) as List).map((e) => TransactionModel.fromJson(e)).toList();

    final sData = prefs.getString('savings');
    if (sData != null) _savings = (jsonDecode(sData) as List).map((e) => SavingGoal.fromJson(e)).toList();

    final bData = prefs.getString('bills');
    if (bData != null) _bills = (jsonDecode(bData) as List).map((e) => Bill.fromJson(e)).toList();

    final dData = prefs.getString('debts');
    if (dData != null) _debts = (jsonDecode(dData) as List).map((e) => Debt.fromJson(e)).toList();

    final catData = prefs.getString('categories');
    if (catData != null) _categories = List<String>.from(jsonDecode(catData));

    setState(() {});
  }

  Future<void> _saveAllData() async {
    bool isGuest = true;
    try {
      if (Supabase.instance.client.auth.currentSession != null) isGuest = false;
    } catch (_) {}

    if (!isGuest) {
      // Sync cloud handled by Supabase direct operations or triggers
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('wallets', jsonEncode(_wallets.map((e) => e.toJson()).toList()));
    await prefs.setString('transactions', jsonEncode(_transactions.map((e) => e.toJson()).toList()));
    await prefs.setString('savings', jsonEncode(_savings.map((e) => e.toJson()).toList()));
    await prefs.setString('bills', jsonEncode(_bills.map((e) => e.toJson()).toList()));
    await prefs.setString('debts', jsonEncode(_debts.map((e) => e.toJson()).toList()));
    await prefs.setString('categories', jsonEncode(_categories));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeDashboardTab(
        wallets: _wallets,
        transactions: _transactions,
        categories: _categories,
        currencyFormatter: currencyFormatter,
        userId: _currentUserId,
        onAddTransaction: (tx, walletId) async {
          setState(() {
            _transactions.insert(0, tx);
            if (walletId.isNotEmpty) {
              final w = _wallets.firstWhere((e) => e.id == walletId);
              if (tx.isIncome) {
                w.balance += tx.amount;
              } else {
                w.balance -= tx.amount;
              }
            }
          });
          try {
            await Supabase.instance.client.from('transactions').insert(tx.toJson());
          } catch (_) {}
          _saveAllData();
        },
        onDeleteTransaction: (id) async {
          final tx = _transactions.firstWhere((e) => e.id == id);
          setState(() {
            if (tx.walletId.isNotEmpty) {
              try {
                final w = _wallets.firstWhere((e) => e.id == tx.walletId);
                if (tx.isIncome) {
                  w.balance -= tx.amount;
                } else {
                  w.balance += tx.amount;
                }
              } catch (_) {}
            }
            _transactions.removeWhere((e) => e.id == id);
          });
          try {
            await Supabase.instance.client.from('transactions').delete().eq('id', id);
          } catch (_) {}
          _saveAllData();
        },
        onAddWallet: (wallet) async {
          setState(() => _wallets.add(wallet));
          try {
            await Supabase.instance.client.from('wallets').insert(wallet.toJson());
          } catch (_) {}
          _saveAllData();
        },
        onDeleteWallet: (id) async {
          setState(() => _wallets.removeWhere((w) => w.id == id));
          try {
            await Supabase.instance.client.from('wallets').delete().eq('id', id);
          } catch (_) {}
          _saveAllData();
        },
        onAddCategory: (cat) {
          setState(() => _categories.add(cat));
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
        userId: _currentUserId,
        onUpdate: () => _saveAllData(),
        onAddSaving: (s) async {
          setState(() => _savings.add(s));
          try { await Supabase.instance.client.from('savings').insert(s.toJson()); } catch (_) {}
          _saveAllData();
        },
        onAddBill: (b) async {
          setState(() => _bills.add(b));
          try { await Supabase.instance.client.from('bills').insert(b.toJson()); } catch (_) {}
          _saveAllData();
        },
        onAddDebt: (d) async {
          setState(() => _debts.add(d));
          try { await Supabase.instance.client.from('debts').insert(d.toJson()); } catch (_) {}
          _saveAllData();
        },
        onDeleteSaving: (id) async {
          setState(() => _savings.removeWhere((s) => s.id == id));
          try { await Supabase.instance.client.from('savings').delete().eq('id', id); } catch (_) {}
          _saveAllData();
        },
        onDeleteBill: (id) async {
          setState(() => _bills.removeWhere((b) => b.id == id));
          try { await Supabase.instance.client.from('bills').delete().eq('id', id); } catch (_) {}
          _saveAllData();
        },
        onDeleteDebt: (id) async {
          setState(() => _debts.removeWhere((d) => d.id == id));
          try { await Supabase.instance.client.from('debts').delete().eq('id', id); } catch (_) {}
          _saveAllData();
        },
      ),
      ProfileTab(
        userId: _currentUserId,
        isGuest: _currentUserId == 'guest',
        wallets: _wallets,
        transactions: _transactions,
        savings: _savings,
        bills: _bills,
        debts: _debts,
        currencyFormatter: currencyFormatter,
        onLogout: () async {
          try {
            await Supabase.instance.client.auth.signOut();
          } catch (_) {}
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('is_guest');
          if (mounted) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AuthGate()));
          }
        },
        onSwitchToGuest: () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('is_guest', true);
          if (mounted) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainDashboard()));
          }
        },
      ),
      HelpTab(),
    ];

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: pages[_currentIndex],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (val) => setState(() => _currentIndex = val),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Utama'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'Laporan'),
          NavigationDestination(icon: Icon(Icons.pie_chart_outline), selectedIcon: Icon(Icons.pie_chart), label: 'Budget'),
          NavigationDestination(icon: Icon(Icons.folder_open_outlined), selectedIcon: Icon(Icons.folder), label: 'Fitur Lain'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profil'),
          NavigationDestination(icon: Icon(Icons.help_outline), selectedIcon: Icon(Icons.help), label: 'Panduan'),
        ],
      ),
    );
  }
}

// 1. Tab Utama
class HomeDashboardTab extends StatelessWidget {
  final List<Wallet> wallets;
  final List<TransactionModel> transactions;
  final List<String> categories;
  final NumberFormat currencyFormatter;
  final String userId;
  final Function(TransactionModel, String) onAddTransaction;
  final Function(String) onDeleteTransaction;
  final Function(Wallet) onAddWallet;
  final Function(String) onDeleteWallet;
  final Function(String) onAddCategory;
  final List<Budget> budgets;

  const HomeDashboardTab({
    super.key,
    required this.wallets,
    required this.transactions,
    required this.categories,
    required this.currencyFormatter,
    required this.userId,
    required this.onAddTransaction,
    required this.onDeleteTransaction,
    required this.onAddWallet,
    required this.onDeleteWallet,
    required this.onAddCategory,
    required this.budgets,
  });

  double get totalBalance => wallets.fold(0, (sum, item) => sum + item.balance);
  double get totalIncome => transactions.where((t) => t.isIncome).fold(0, (sum, t) => sum + t.amount);
  double get totalExpense => transactions.where((t) => !t.isIncome).fold(0, (sum, t) => sum + t.amount);

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 10) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  String get _userName {
    if (userId == 'guest') return 'Sobat Motrich';
    final email = Supabase.instance.client.auth.currentUser?.email ?? '';
    return email.split('@').first;
  }

  IconData _getTimeIcon() {
    final hour = DateTime.now().hour;
    if (hour < 10) return Icons.wb_sunny_outlined;
    if (hour < 15) return Icons.wb_sunny;
    if (hour < 18) return Icons.brightness_4;
    return Icons.nightlight_round;
  }

  String _getMotivationalMessage() {
    final hour = DateTime.now().hour;
    if (hour < 10) return 'Mulai hari dengan catatan keuangan yang rapi!';
    if (hour < 15) return 'Tetap semangat mengelola keuangan hari ini!';
    if (hour < 18) return 'Waktunya evaluasi pengeluaran siang ini.';
    return 'Akhirkan hari dengan mencatat keuanganmu.';
  }

  void _showAddWalletModal(BuildContext context) {
    final nameController = TextEditingController();
    final balanceController = TextEditingController();
    String type = 'Cash';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20, left: 20, right: 20, top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Tambah Dompet / Rekening', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nama Dompet / Bank (cth: BCA)', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: balanceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Saldo Awal (Rp)', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: type,
                items: ['Cash', 'Bank', 'E-Wallet', 'Investasi'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (val) => setModalState(() => type = val!),
                decoration: const InputDecoration(labelText: 'Tipe', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                onPressed: () {
                  final name = nameController.text.trim();
                  final balance = double.tryParse(balanceController.text) ?? 0;
                  if (name.isNotEmpty) {
                    final w = Wallet(
                      id: _uuid.v4(),
                      userId: userId,
                      name: name,
                      type: type,
                      balance: balance,
                    );
                    onAddWallet(w);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Simpan Dompet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddCategoryModal(BuildContext context) {
    final catController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20, left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Tambah Kategori Baru', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            TextField(controller: catController, decoration: const InputDecoration(labelText: 'Nama Kategori (cth: Hobi, Langganan)', border: OutlineInputBorder())),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              onPressed: () {
                final cat = catController.text.trim();
                if (cat.isNotEmpty && !categories.contains(cat)) {
                  onAddCategory(cat);
                  Navigator.pop(context);
                }
              },
              child: const Text('Simpan Kategori', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddModal(BuildContext context) {
    if (wallets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Buat Dompet/Rekening terlebih dahulu!')));
      return;
    }

    final titleController = TextEditingController();
    final amountController = TextEditingController();
    bool isIncome = false;
    String category = categories.first;
    String selectedWalletId = wallets.first.id;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20, left: 20, right: 20, top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Catat Transaksi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Keterangan', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: amountController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Jumlah (Rp)', border: OutlineInputBorder())),
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
                items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setModalState(() => category = val!),
                decoration: const InputDecoration(labelText: 'Kategori', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedWalletId,
                items: wallets.map((w) => DropdownMenuItem(value: w.id, child: Text('${w.name} (${w.type})'))).toList(),
                onChanged: (val) => setModalState(() => selectedWalletId = val!),
                decoration: const InputDecoration(labelText: 'Sumber Dompet', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                onPressed: () {
                  final title = titleController.text.trim();
                  // Hapus titik/koma untuk parsing angka format Indonesia (misal: 50.000 -> 50000)
                  final cleanAmount = amountController.text.replaceAll(RegExp(r'[.,]'), '');
                  final amount = double.tryParse(cleanAmount) ?? 0;
                  
                  if (title.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Keterangan wajib diisi'), backgroundColor: Colors.red),
                    );
                    return;
                  }
                  if (amount <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Jumlah harus lebih dari 0'), backgroundColor: Colors.red),
                    );
                    return;
                  }
                  if (wallets.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Buat Dompet/Rekening terlebih dahulu!'), backgroundColor: Colors.red),
                    );
                    return;
                  }
                  
                  final tx = TransactionModel(
                    id: _uuid.v4(),
                    userId: userId,
                    title: title,
                    amount: amount,
                    isIncome: isIncome,
                    category: category,
                    walletId: selectedWalletId,
                    date: DateTime.now(),
                  );
                  onAddTransaction(tx, selectedWalletId);
                  Navigator.pop(context);
                },
                child: const Text('Simpan Transaksi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Motrich Financial Manager', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: Icon(themeNotifier.isDarkMode ? Icons.light_mode : Icons.dark_mode), onPressed: () => themeNotifier.toggleTheme()),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              try {
                await Supabase.instance.client.auth.signOut();
              } catch (_) {}
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('is_guest');
              if (context.mounted) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AuthGate()));
              }
            },
          ),
        ],
      ),
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
                const Text('Total Saldo Keseluruhan', style: TextStyle(color: Colors.white70, fontSize: 13)),
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

          // Greeting Card
      Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getTimeIcon(),
                  color: Colors.blue.shade700,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$_greeting, $_userName! 👋',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getMotivationalMessage(),
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 20),

      // Wallets Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Dompet & Rekening', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  TextButton.icon(onPressed: () => _showAddCategoryModal(context), icon: const Icon(Icons.category, size: 14), label: const Text('Kategori')),
                  TextButton.icon(onPressed: () => _showAddWalletModal(context), icon: const Icon(Icons.add, size: 14), label: const Text('Dompet')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          wallets.isEmpty
              ? Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade300)),
                  child: const Center(child: Text('Belum ada dompet/rekening. Klik "Dompet" untuk tambah.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey))),
                )
              : SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: wallets.length,
                    itemBuilder: (context, index) {
                      final w = wallets[index];
                      return Container(
                        width: 160,
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.blue.withOpacity(0.3))),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: Text(w.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), overflow: TextOverflow.ellipsis)),
                                InkWell(onTap: () => onDeleteWallet(w.id), child: const Icon(Icons.close, size: 14, color: Colors.grey)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(currencyFormatter.format(w.balance), style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(height: 2),
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

// 2. Tab Laporan
class ReportTab extends StatefulWidget {
  final List<TransactionModel> transactions;
  final NumberFormat currencyFormatter;

  const ReportTab({super.key, required this.transactions, required this.currencyFormatter});

  @override
  State<ReportTab> createState() => _ReportTabState();
}

class _ReportTabState extends State<ReportTab> {
  String _period = 'Bulanan';

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    List<TransactionModel> filtered = widget.transactions.where((tx) {
      if (_period == 'Harian') {
        return tx.date.year == now.year && tx.date.month == now.month && tx.date.day == now.day;
      } else if (_period == 'Mingguan') {
        return now.difference(tx.date).inDays <= 7;
      } else if (_period == 'Bulanan') {
        return tx.date.year == now.year && tx.date.month == now.month;
      } else {
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
            decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.blue.withOpacity(0.3))),
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

// 3. Tab Budget
class BudgetTab extends StatelessWidget {
  final List<Budget> budgets;
  final List<TransactionModel> transactions;
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
                  LinearProgressIndicator(value: progress, color: isOver ? Colors.red : Colors.blue, backgroundColor: Colors.grey.shade300, minHeight: 8),
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

class Budget {
  final String period;
  final double limit;
  Budget({required this.period, required this.limit});
}

// 4. Tab Fitur Lainnya (Tabungan, Tagihan, Utang)
class MoreModulesTab extends StatelessWidget {
  final List<SavingGoal> savings;
  final List<Bill> bills;
  final List<Debt> debts;
  final NumberFormat currencyFormatter;
  final String userId;
  final VoidCallback onUpdate;
  final Function(SavingGoal) onAddSaving;
  final Function(Bill) onAddBill;
  final Function(Debt) onAddDebt;
  final Function(String) onDeleteSaving;
  final Function(String) onDeleteBill;
  final Function(String) onDeleteDebt;

  const MoreModulesTab({
    super.key,
    required this.savings,
    required this.bills,
    required this.debts,
    required this.currencyFormatter,
    required this.userId,
    required this.onUpdate,
    required this.onAddSaving,
    required this.onAddBill,
    required this.onAddDebt,
    required this.onDeleteSaving,
    required this.onDeleteBill,
    required this.onDeleteDebt,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fitur Keuangan Lainnya', style: TextStyle(fontWeight: FontWeight.bold))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('🎯 Target Tabungan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              TextButton.icon(onPressed: () => _showAddSavingModal(context), icon: const Icon(Icons.add, size: 16), label: const Text('Tambah')),
            ],
          ),
          const SizedBox(height: 8),
          savings.isEmpty
              ? Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade300)),
                  child: const Center(child: Text('Belum ada target tabungan.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey))),
                )
              : Column(
                  children: savings.map((s) => Card(
                        child: ListTile(
                          title: Text(s.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Terkumpul: ${currencyFormatter.format(s.currentAmount)} dari ${currencyFormatter.format(s.targetAmount)}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.add_circle, color: Colors.blue),
                                onPressed: () {
                                  s.currentAmount += 100000;
                                  onUpdate();
                                },
                              ),
                              IconButton(icon: const Icon(Icons.delete_outline, color: Colors.grey), onPressed: () => onDeleteSaving(s.id)),
                            ],
                          ),
                        ),
                      )).toList(),
                ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('💡 Pengingat Tagihan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              TextButton.icon(onPressed: () => _showAddBillModal(context), icon: const Icon(Icons.add, size: 16), label: const Text('Tambah')),
            ],
          ),
          const SizedBox(height: 8),
          bills.isEmpty
              ? Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade300)),
                  child: const Center(child: Text('Belum ada tagihan.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey))),
                )
              : Column(
                  children: bills.map((bill) => Card(
                        child: ListTile(
                          title: Text(bill.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${currencyFormatter.format(bill.amount)} • Jatuh tempo: ${DateFormat('dd MMM yyyy', 'id_ID').format(bill.dueDate)}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Checkbox(
                                value: bill.isPaid,
                                onChanged: (val) {
                                  bill.isPaid = val ?? false;
                                  onUpdate();
                                },
                              ),
                              IconButton(icon: const Icon(Icons.delete_outline, color: Colors.grey), onPressed: () => onDeleteBill(bill.id)),
                            ],
                          ),
                        ),
                      )).toList(),
                ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('🤝 Utang & Piutang', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              TextButton.icon(onPressed: () => _showAddDebtModal(context), icon: const Icon(Icons.add, size: 16), label: const Text('Tambah')),
            ],
          ),
          const SizedBox(height: 8),
          debts.isEmpty
              ? Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade300)),
                  child: const Center(child: Text('Belum ada utang/piutang.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey))),
                )
              : Column(
                  children: debts.map((d) => Card(
                        child: ListTile(
                          leading: Icon(d.isPayable ? Icons.call_made : Icons.call_received, color: d.isPayable ? Colors.red : Colors.green),
                          title: Text(d.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${d.isPayable ? "Utang saya" : "Piutang orang"} • ${currencyFormatter.format(d.amount)}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Switch(
                                value: d.isSettled,
                                onChanged: (val) {
                                  d.isSettled = val;
                                  onUpdate();
                                },
                              ),
                              IconButton(icon: const Icon(Icons.delete_outline, color: Colors.grey), onPressed: () => onDeleteDebt(d.id)),
                            ],
                          ),
                        ),
                      )).toList(),
                ),
        ],
      ),
    );
  }

  void _showAddSavingModal(BuildContext context) {
    final titleController = TextEditingController();
    final targetController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20, left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Tambah Target Tabungan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Nama Target (cth: Beli Laptop)', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: targetController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Target Amount (Rp)', border: OutlineInputBorder())),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              onPressed: () {
                final title = titleController.text.trim();
                final target = double.tryParse(targetController.text) ?? 0;
                if (title.isNotEmpty && target > 0) {
                  final s = SavingGoal(
                    id: _uuid.v4(),
                    userId: userId,
                    title: title,
                    targetAmount: target,
                    currentAmount: 0,
                  );
                  onAddSaving(s);
                  Navigator.pop(context);
                }
              },
              child: const Text('Simpan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddBillModal(BuildContext context) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    DateTime dueDate = DateTime.now().add(const Duration(days: 7));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20, left: 20, right: 20, top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Tambah Tagihan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Nama Tagihan (cth: Listrik)', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: amountController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Jumlah (Rp)', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              ListTile(
                title: const Text('Jatuh Tempo'),
                subtitle: Text(DateFormat('dd MMM yyyy', 'id_ID').format(dueDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: dueDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) setModalState(() => dueDate = picked);
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                onPressed: () {
                  final title = titleController.text.trim();
                  final amount = double.tryParse(amountController.text) ?? 0;
                  if (title.isNotEmpty && amount > 0) {
                    final b = Bill(
                      id: _uuid.v4(),
                      userId: userId,
                      title: title,
                      amount: amount,
                      dueDate: dueDate,
                      isPaid: false,
                    );
                    onAddBill(b);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Simpan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddDebtModal(BuildContext context) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    bool isPayable = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20, left: 20, right: 20, top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Tambah Utang / Piutang', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nama Orang', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: amountController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Jumlah (Rp)', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Tipe: '),
                  ChoiceChip(label: const Text('Utang Saya'), selected: isPayable, selectedColor: Colors.red.shade100, onSelected: (val) => setModalState(() => isPayable = true)),
                  const SizedBox(width: 8),
                  ChoiceChip(label: const Text('Piutang Orang'), selected: !isPayable, selectedColor: Colors.green.shade100, onSelected: (val) => setModalState(() => isPayable = false)),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                onPressed: () {
                  final name = nameController.text.trim();
                  final amount = double.tryParse(amountController.text) ?? 0;
                  if (name.isNotEmpty && amount > 0) {
                    final d = Debt(
                      id: _uuid.v4(),
                      userId: userId,
                      name: name,
                      amount: amount,
                      isPayable: isPayable,
                      isSettled: false,
                    );
                    onAddDebt(d);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Simpan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Profile Tab
class ProfileTab extends StatelessWidget {
  final String userId;
  final bool isGuest;
  final List<Wallet> wallets;
  final List<TransactionModel> transactions;
  final List<SavingGoal> savings;
  final List<Bill> bills;
  final List<Debt> debts;
  final NumberFormat currencyFormatter;
  final VoidCallback onLogout;
  final VoidCallback onSwitchToGuest;

  const ProfileTab({
    super.key,
    required this.userId,
    required this.isGuest,
    required this.wallets,
    required this.transactions,
    required this.savings,
    required this.bills,
    required this.debts,
    required this.currencyFormatter,
    required this.onLogout,
    required this.onSwitchToGuest,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil & Pengaturan', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: SingleChildScrollView(
          key: ValueKey(isGuest),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Account Status Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: isGuest ? Colors.orange.shade100 : Colors.blue.shade100,
                        child: Icon(
                          isGuest ? Icons.person_outline : Icons.account_circle,
                          size: 48,
                          color: isGuest ? Colors.orange.shade700 : Colors.blue.shade700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isGuest ? 'Mode Tamu (Guest)' : 'Terhubung ke Cloud',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isGuest ? Colors.orange.shade800 : Colors.blue.shade800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isGuest
                            ? 'Data tersimpan lokal di perangkat. Login untuk sinkronisasi cloud.'
                            : 'Email: ${Supabase.instance.client.auth.currentUser?.email ?? userId}',
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      if (isGuest)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                          },
                          icon: const Icon(Icons.cloud_upload),
                          label: const Text('Masuk / Daftar ke Cloud', style: TextStyle(fontWeight: FontWeight.bold)),
                        )
                      else
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red.shade700,
                            side: BorderSide(color: Colors.red.shade300),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: onLogout,
                          icon: const Icon(Icons.logout),
                          label: const Text('Keluar (Logout)', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // App Info
              const Text('Informasi Aplikasi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.blue.shade100, borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.info_outline, color: Colors.blue),
                      ),
                      title: const Text('Versi Aplikasi'),
                      trailing: const Text('v1.0.0+1', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.copyright, color: Colors.green),
                      ),
                      title: const Text('Copyright'),
                      subtitle: const Text('© 2026 Motrich Manager. All rights reserved.'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.purple.shade100, borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.security, color: Colors.purple),
                      ),
                      title: const Text('Keamanan Data'),
                      subtitle: Text(isGuest
                          ? 'Data tersimpan lokal (SharedPreferences). Tidak ada enkripsi cloud.'
                          : 'Data disinkronkan ke Supabase (PostgreSQL) dengan RLS per user.'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.sync, color: Colors.orange),
                      ),
                      title: const Text('Mode Penyimpanan'),
                      subtitle: Text(isGuest ? 'Lokal (Offline-First)' : 'Cloud (Supabase) + Cache Lokal'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Statistics Summary
              const Text('Ringkasan Data', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.3,
                children: [
                  _buildStatCard(context, 'Dompet', wallets.length.toString(), Icons.account_balance_wallet, Colors.blue),
                  _buildStatCard(context, 'Transaksi', transactions.length.toString(), Icons.receipt_long, Colors.green),
                  _buildStatCard(context, 'Tabungan', savings.length.toString(), Icons.savings, Colors.purple),
                  _buildStatCard(context, 'Tagihan', bills.length.toString(), Icons.notifications_active, Colors.orange),
                  _buildStatCard(context, 'Utang/Piutang', debts.length.toString(), Icons.people, Colors.red),
                  _buildStatCard(context, 'Total Saldo', currencyFormatter.format(wallets.fold(0.0, (sum, w) => sum + w.balance)), Icons.attach_money, Colors.teal),
                ],
              ),
              const SizedBox(height: 24),

              // Switch Mode Button (if logged in)
              if (!isGuest)
                Center(
                  child: TextButton.icon(
                    onPressed: onSwitchToGuest,
                    icon: const Icon(Icons.person_outline, color: Colors.orange),
                    label: const Text('Beralih ke Mode Tamu', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w600)),
                  ),
                ),
              const SizedBox(height: 20),

              // Copyright footer
              Center(
                child: Text(
                  '© 2026 Motrich Manager — v1.0.0+1\nDibuat dengan Flutter & Supabase',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 10),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}

// Help / Guide Tab
class HelpTab extends StatelessWidget {
  const HelpTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panduan & Bantuan', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero / Welcome
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade600, Colors.blue.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.auto_awesome, size: 48, color: Colors.white),
                    const SizedBox(height: 16),
                    const Text('Selamat Datang di Motrich!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 8),
                    const Text('Aplikasi pencatat keuangan pribadi dengan kendali penuh. Kelola dompet, catat transaksi, atur budget, dan target tabungan dengan mudah.', style: TextStyle(fontSize: 14, color: Colors.white70, height: 1.4)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Guide Sections
            _buildGuideSection(context, '🚀 Memulai', [
              'Pilih **Mode Tamu** untuk penggunaan instan tanpa login (data di HP saja).',
              'Pilih **Masuk/Daftar** untuk sinkronisasi ke Cloud (Supabase) — aman saat ganti HP.',
              'Mode Tamu bisa beralih ke Cloud kapan saja dari halaman Profil.',
            ]),
            _buildGuideSection(context, '💰 Manajemen Dompet & Rekening', [
              'Klik tombol **"+ Dompet"** di halaman Utama untuk menambah dompet/rekening baru.',
              'Pilih tipe: **Cash** (Tunai), **Bank** (Rekening), **E-Wallet** (GoPay, OVO, dll), atau **Investasi**.',
              'Set saldo awal, lalu klik **Simpan Dompet**.',
              'Hapus dompet dengan klik ikon **✕** pada kartu dompet (hanya jika saldo 0).',
            ]),
            _buildGuideSection(context, '📝 Mencatat Transaksi', [
              'Tekan tombol **FAB (+)** di kanan bawah halaman Utama.',
              'Isi keterangan, jumlah, pilih **Pemasukan** atau **Pengeluaran**.',
              'Pilih **Kategori** (bisa ditambah sendiri via tombol "Kategori").',
              'Pilih **Sumber Dompet** asal dana.',
              'Saldo dompet otomatis berkurang/bertambah sesuai jenis transaksi.',
              'Hapus transaksi dengan ikon **sampah** pada daftar transaksi.',
            ]),
            _buildGuideSection(context, '🏷️ Kustomisasi Kategori', [
              'Klik tombol **"Kategori"** di halaman Utama untuk menambah kategori baru.',
              'Kategori bebas: "Nongkrong", "Hobi", "Langganan", dll.',
              'Kategori baru langsung muncul di dropdown saat catat transaksi.',
            ]),
            _buildGuideSection(context, '📊 Anggaran (Budget)', [
              'Tab **Budget** menampilkan batas Harian / Bulanan / Tahunan.',
              'Progress bar otomatis hitung pengeluaran vs batas yang ditetapkan.',
              'Merah = melebihi batas. Hijau = aman.',
              'Budget default bisa diubah di kode (budget Harian/Bulanan/Tahunan).',
            ]),
            _buildGuideSection(context, '🎯 Target Tabungan', [
              'Tab **Fitur Lain > Target Tabungan**.',
              'Tambah target: nama (cth: "Beli Laptop") + nominal target.',
              'Klik **"+ Rp100.000"** untuk menambah progress tabungan.',
            ]),
            _buildGuideSection(context, '💡 Pengingat Tagihan', [
              'Tab **Fitur Lain > Pengingat Tagihan**.',
              'Tambah tagihan: nama, jumlah, tanggal jatuh tempo.',
              'Centang **checkbox** saat sudah bayar (badge "Lunas").',
            ]),
            _buildGuideSection(context, '🤝 Utang & Piutang', [
              'Tab **Fitur Lain > Utang & Piutang**.',
              'Pilih tipe: **Utang Saya** (pinjam orang) atau **Piutang** (orang pinjam ke saya).',
              'Toggle **switch** saat sudah lunas/lunas dibayar.',
            ]),
            _buildGuideSection(context, '🌓 Mode Gelap / Terang', [
              'Klik ikon **matahari/bulan** di AppBar halaman Utama.',
              'Preferensi otomatis tersimpan dan dipulihkan saat buka aplikasi.',
            ]),
            _buildGuideSection(context, '☁️ Sinkronisasi Cloud', [
              'Login dengan Email/Password via Supabase Auth.',
              'Data otomatis tersimpan ke database PostgreSQL (RLS per user).',
              'Ganti HP → Login akun sama → Data lengkap kembali.',
            ]),
            _buildGuideSection(context, '📤 Ekspor / Impor Data (Manual)', [
              'Data tersimpan di SharedPreferences (mode Tamu) / Supabase (Cloud).',
              'Untuk backup manual: gunakan fitur Export/Import di pengajuan pengembangan lanjutan.',
            ]),

            const SizedBox(height: 24),

            // FAQ
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ExpansionTile(
                leading: const Icon(Icons.question_answer, color: Colors.blue),
                title: const Text('Pertanyaan Umum (FAQ)', style: TextStyle(fontWeight: FontWeight.bold)),
                children: [
                  _buildFaqItem('Apakah data saya aman?', 'Ya. Mode Cloud menggunakan Supabase dengan Row Level Security — hanya Anda yang bisa akses data milik Anda. Mode Tamu data di HP Anda saja.'),
                  _buildFaqItem('Bisa pakai di beberapa HP?', 'Ya, gunakan Mode Cloud (Login). Data akan sinkron otomatis.'),
                  _buildFaqItem('Bisa pindah dari Tamu ke Cloud?', 'Ya, buka halaman Profil → klik "Masuk / Daftar ke Cloud".'),
                  _buildFaqItem('Bagaimana cara hapus semua data?', 'Mode Tamu: Hapus aplikasi / Clear Storage. Mode Cloud: Hapus akun di Supabase Dashboard.'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Footer
            Center(
              child: Text(
                'Motrich Manager v1.0.0+1\n© 2026 — Dibuat dengan ❤️ Flutter & Supabase',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideSection(BuildContext context, String title, List<String> steps) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        initiallyExpanded: false,
        leading: const Icon(Icons.arrow_right, color: Colors.blue),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        children: steps.map((step) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Text('• $step', style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.5)),
        )).toList(),
      ),
    );
  }

  Widget _buildFaqItem(String q, String a) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('❓ $q', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 4),
          Text(a, style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
          const SizedBox(height: 8),
          const Divider(height: 1),
        ],
      ),
    );
  }
}
