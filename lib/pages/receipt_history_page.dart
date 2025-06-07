import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';
import '../models/boxes.dart';
import '../utils/currency_util.dart';
import '../utils/session_manager.dart';
import 'welcome_page.dart';
import 'receipt_page.dart';

class ReceiptHistoryPage extends StatefulWidget {
  const ReceiptHistoryPage({super.key});

  @override
  State<ReceiptHistoryPage> createState() => _ReceiptHistoryPageState();
}

class _ReceiptHistoryPageState extends State<ReceiptHistoryPage> {
  List<Transaction> _transactions = [];
  String? _username;
  String? _region;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkSession();
    _loadTransactions();
  }

  Future<void> _checkSession() async {
    if (!await SessionManager.isLoggedIn()) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const WelcomePage()),
        );
      }
    }
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);
    
    final prefs = await SharedPreferences.getInstance();
    _username = prefs.getString('logged_in_user');
    _region = prefs.getString('user_${_username}_region') ?? 'usd';

    if (_username != null) {
      final box = await Hive.openBox<Transaction>(HiveBoxes.transaction);
      final allTransactions = box.values.toList();
      
      // Filter transactions for current user and sort by checkin date (newest first)
      _transactions = allTransactions
          .where((t) => t.username == _username)
          .toList()
        ..sort((a, b) => b.checkin.compareTo(a.checkin));
    }

    setState(() => _isLoading = false);
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  String _formatCurrency(double amount) {
    final converted = CurrencyUtil.convert(amount, _region ?? 'usd');
    return CurrencyUtil.format(converted, _region ?? 'usd');
  }

  Widget _buildTransactionCard(Transaction transaction) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReceiptPage(transaction: transaction),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      transaction.hotelName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF388E3C),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${transaction.day} ${transaction.day > 1 ? 'days' : 'day'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    '${_formatDate(transaction.checkin)} - ${_formatDate(transaction.checkout)}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Payment',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    _formatCurrency(transaction.total),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF388E3C),
                    ),
                  ),
                ],
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
        title: const Text('Receipt History'),
        backgroundColor: const Color(0xFF388E3C),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _transactions.isEmpty
              ? const Center(
                  child: Text(
                    'No transactions found',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: _transactions.length,
                  itemBuilder: (context, index) {
                    return _buildTransactionCard(_transactions[index]);
                  },
                ),
    );
  }
} 