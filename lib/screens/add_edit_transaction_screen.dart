import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/my_transaction.dart';
import '../providers/transaction_provider.dart';

class AddEditTransactionScreen extends StatefulWidget {
  final MyTransaction? transaction;

  const AddEditTransactionScreen({super.key, this.transaction});

  @override
  State<AddEditTransactionScreen> createState() => _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState extends State<AddEditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  TransactionType _selectedType = TransactionType.expense;

  @override
  void initState() {
    super.initState();
    // ถ้าเป็นการแก้ไข นำข้อมูลเดิมมาใส่ใน Form
    if (widget.transaction != null) {
      _titleController.text = widget.transaction!.title;
      _amountController.text = widget.transaction!.amount.toString();
      _selectedDate = widget.transaction!.date;
      _selectedType = widget.transaction!.type;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate == null) return;
      setState(() {
        _selectedDate = pickedDate;
      });
    });
  }

  void _saveForm() {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text;
    final amount = double.parse(_amountController.text);
    final provider = context.read<TransactionProvider>();

    if (widget.transaction == null) {
      // เพิ่มรายการใหม่
      provider.addTransaction(title, amount, _selectedDate, _selectedType);
    } else {
      // แก้ไขรายการเดิม
      final updatedTx = MyTransaction(
        id: widget.transaction!.id,
        title: title,
        amount: amount,
        date: _selectedDate,
        type: _selectedType,
      );
      provider.updateTransaction(widget.transaction!.id!, updatedTx);
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.transaction != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'แก้ไขรายการ' : 'เพิ่มรายการใหม่'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'ชื่อรายการ'),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'กรุณากรอกชื่อรายการ';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'จำนวนเงิน (บาท)'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (val) {
                  if (val == null || double.tryParse(val) == null) {
                    return 'กรุณากรอกตัวเลขจำนวนเงินที่ถูกต้อง';
                  }
                  if (double.parse(val) <= 0) {
                    return 'จำนวนเงินต้องมากกว่า 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'วันที่: ${DateFormat.yMMMd().format(_selectedDate)}',
                    ),
                  ),
                  TextButton(
                    onPressed: _presentDatePicker,
                    child: const Text('เลือกวันที่'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TransactionType>(
                value: _selectedType,
                decoration: const InputDecoration(labelText: 'ประเภทธุรกรรม'),
                items: const [
                  DropdownMenuItem(
                    value: TransactionType.expense,
                    child: Text('รายจ่าย'),
                  ),
                  DropdownMenuItem(
                    value: TransactionType.income,
                    child: Text('รายรับ'),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedType = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveForm,
                child: Text(isEditing ? 'บันทึกการแก้ไข' : 'เพิ่มรายการ'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}