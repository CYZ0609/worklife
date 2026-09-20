import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:worklife/providers/game_state.dart';

class BankScreen extends StatefulWidget {
  const BankScreen({Key? key}) : super(key: key);

  @override
  _BankScreenState createState() => _BankScreenState();
}

class _BankScreenState extends State<BankScreen> {
  final TextEditingController _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<GameState>(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // 资产显示卡片
          Card(
            color: Colors.blueGrey[900],
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const Text("April Bank", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.amber)),
                  Text("Daily Interest Rate: ${(state.dailyInterestRate * 100).toStringAsFixed(1)}%", style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Wallet Cash:", style: TextStyle(fontSize: 16)),
                      Text("\$${state.cash.toStringAsFixed(2)}", style: const TextStyle(fontSize: 18, color: Colors.green)),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Bank Balance:", style: TextStyle(fontSize: 16)),
                      Text("\$${state.bankBalance.toStringAsFixed(2)}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),

          // 金额输入框
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: "Enter Amount (\$)",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.attach_money),
            ),
          ),
          const SizedBox(height: 20),

          // 存取款按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 存款按钮
              ElevatedButton.icon(
                icon: const Icon(Icons.arrow_downward),
                label: const Text("DEPOSIT"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15)),
                onPressed: () {
                  final amount = double.tryParse(_amountController.text) ?? 0;
                  
                  // 错误处理逻辑
                  if (amount <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter a valid amount!"), backgroundColor: Colors.red));
                  } else if (amount > state.cash) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Not enough wallet cash!"), backgroundColor: Colors.red));
                  } else {
                    // 钱足够，执行存款并提示成功
                    state.deposit(amount);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Deposited \$${amount.toStringAsFixed(2)} successfully!"), backgroundColor: Colors.green));
                    _amountController.clear();
                  }
                  FocusScope.of(context).unfocus(); // 收起键盘
                },
              ),
              
              // 取款按钮
              ElevatedButton.icon(
                icon: const Icon(Icons.arrow_upward),
                label: const Text("WITHDRAW"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15)),
                onPressed: () {
                  final amount = double.tryParse(_amountController.text) ?? 0;
                  
                  // 错误处理逻辑
                  if (amount <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter a valid amount!"), backgroundColor: Colors.red));
                  } else if (amount > state.bankBalance) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Not enough bank balance!"), backgroundColor: Colors.red));
                  } else {
                    // 钱足够，执行取款并提示成功
                    state.withdraw(amount);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Withdrew \$${amount.toStringAsFixed(2)} successfully!"), backgroundColor: Colors.green));
                    _amountController.clear();
                  }
                  FocusScope.of(context).unfocus(); // 收起键盘
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}