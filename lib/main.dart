import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

import 'package:worklife/providers/game_state.dart';
import 'package:worklife/screens/schedule_screen.dart';
import 'package:worklife/screens/bank_screen.dart';
// 如果有 inbox_screen，也用这种格式：
// import 'package:worklife/screens/inbox_screen.dart';
// --- 数据模型 (Models) ---
// 随机事件的数据结构


// --- 应用入口 (App Entry) ---
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    // 注入 Provider 状态管理，让全 App 都能读取 GameState
    ChangeNotifierProvider(
      create: (context) => GameState()..initGame(),
      child: const LifeSimApp(),
    ),
  );
}

class LifeSimApp extends StatelessWidget {
  const LifeSimApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Life Simulator',
      theme: ThemeData(
        brightness: Brightness.dark, // 开启全局暗黑模式
        scaffoldBackgroundColor: Colors.black, // 将页面背景强制设为纯黑
        primarySwatch: Colors.blueGrey,
      ),
      home: const MainScreen(),
    );
  }
}

// --- 主界面 (Main Screen) ---
// 包含底部导航栏的框架页面
class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // 三个主要页面的占位，目前只有 Inbox 做了具体 UI
  final List<Widget> _pages = [
    const InboxScreen(), // 收件箱 (如果在别的文件夹记得import)
    const BankScreen(), // 银行页面
    const ScheduleScreen(), // <--- 替换成日程页面  // 日程页面（开发中）
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Life Dashboard'),
        actions: [
          // 顶部右上角实时显示现金余额
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Consumer<GameState>(
              builder: (context, state, child) => Text(
                'Cash: \$${state.cash.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.mail), label: 'Inbox'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance), label: 'Bank'),
          BottomNavigationBarItem(icon: Icon(Icons.schedule), label: 'Schedule'),
        ],
      ),
    );
  }
}

// --- 收件箱页面 (Inbox Screen) ---
class InboxScreen extends StatelessWidget {
  const InboxScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 获取当前的游戏状态数据
    final state = Provider.of<GameState>(context);

    // 如果没有事件，显示提示语
    if (state.inboxEvents.isEmpty) {
      return const Center(child: Text("No new events at the moment."));
    }

    // 渲染事件列表
    return ListView.builder(
      itemCount: state.inboxEvents.length,
      itemBuilder: (context, index) {
        final event = state.inboxEvents[index];
        final isPenalty = event.amount < 0; // 判断是罚金还是奖励

        return Card(
          margin: const EdgeInsets.all(8.0),
          child: ListTile(
            title: Text(event.title),
            subtitle: Text(event.description),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isPenalty ? Colors.red : Colors.green, // 罚款用红色，奖励用绿色
              ),
              onPressed: () => state.resolveEvent(event), // 点击处理事件
              child: Text(isPenalty ? 'Pay \$${-event.amount}' : 'Claim \$${event.amount}'),
            ),
          ),
        );
      },
    );
  }
}