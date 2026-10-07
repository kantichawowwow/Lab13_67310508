import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/my_transaction.dart';
import '../providers/transaction_provider.dart';
import 'add_edit_transaction_screen.dart';

class TransactionListScreen extends StatelessWidget {
  const TransactionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('รายรับ-รายจ่าย')),
      body: Consumer<TransactionProvider>(
        builder: (context, txProvider, child) => txProvider.transactions.isEmpty
            ? const Center(child: Text('ไม่มีรายการธุรกรรม'))
            : ListView.builder(
                itemCount: txProvider.transactions.length,
                itemBuilder: (ctx, i) {
                  final tx = txProvider.transactions[i];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: tx.type == TransactionType.income
                            ? Colors.green.shade100
                            : Colors.red.shade100,
                        child: Text(
                          tx.type == TransactionType.income ? 'รับ' : 'จ่าย',
                          style: TextStyle(
                            color: tx.type == TransactionType.income
                                ? Colors.green.shade900
                                : Colors.red.shade900,
                          ),
                        ),
                      ),
                      title: Text(
                        tx.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(DateFormat.yMMMd().format(tx.date)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${tx.amount.toStringAsFixed(2)} บาท',
                            style: TextStyle(
                              color: tx.type == TransactionType.income
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.grey),
                            onPressed: () {
                              context
                                  .read<TransactionProvider>()
                                  .deleteTransaction(tx.id!);
                            },
                          ),
                        ],
                      ),
                      // กดที่รายการเพื่อเปิดหน้าแก้ไข (Update)
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) =>
                                AddEditTransactionScreen(transaction: tx),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => const AddEditTransactionScreen(),
            ),
          );
        },
      ),
    );
  }
}