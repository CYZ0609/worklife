import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'dart:async'; 

class GameEvent {
  final String id;
  final String title;
  final String description;
  final double amount;

  GameEvent({required this.id, required this.title, required this.description, required this.amount});

  factory GameEvent.fromJson(Map<String, dynamic> json) {
    return GameEvent(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      amount: json['amount'].toDouble(),
    );
  }
}

class GameState with ChangeNotifier {
  double _cash = 1000.0;
  double _bankBalance = 5000.0;
  List<GameEvent> _inboxEvents = [];

  String _jobTitle = "Junior Developer";
  double _dailySalary = 200.0;
  int _workStartHour = 9;
  int _workEndHour = 18;
  int _currentDay = 1;

  final double _dailyInterestRate = 0.01; 
  Timer? _timer;
  double get dailyInterestRate => _dailyInterestRate;

  double get cash => _cash;
  double get bankBalance => _bankBalance;
  List<GameEvent> get inboxEvents => _inboxEvents;
  String get jobTitle => _jobTitle;
  double get dailySalary => _dailySalary;
  int get workStartHour => _workStartHour;
  int get workEndHour => _workEndHour;
  int get currentDay => _currentDay;

  // 游戏启动时运行：加载事件，并检查现实时间
  Future<void> initGame() async {
    await _loadSavedData();
    await _checkTimeAndCalculateSalary();
    notifyListeners();

    // --- 新增：每隔 10 秒钟后台检查一次时间（正式发布可改成 1 分钟） ---
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _checkTimeAndCalculateSalary();
    });
  }

  // --- 新增：当应用完全关闭时，销毁定时器释放内存 ---
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // 从本地加载之前存下的钱数和时间
  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    _cash = prefs.getDouble('cash') ?? 1000.0;
    _bankBalance = prefs.getDouble('bankBalance') ?? 5000.0;
    _currentDay = prefs.getInt('currentDay') ?? 1;
    _workStartHour = prefs.getInt('startHour') ?? 9;
    _workEndHour = prefs.getInt('endHour') ?? 18;
  }

  // 核心逻辑：比对现实日期，发放挂机工资
  Future<void> _checkTimeAndCalculateSalary() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 获取手机现在的现实时间
    final now = DateTime.now();
    // 获取上次保存的日期字符串（如果没有，就当做是今天）
    final lastLoginDateStr = prefs.getString('lastLoginDate') ?? now.toIso8601String();
    final lastLoginDate = DateTime.parse(lastLoginDateStr);

// 判断：如果现实时间的天数不同，说明过了至少一天
    if (now.day != lastLoginDate.day || now.month != lastLoginDate.month) {
      _currentDay++; 
      _cash += _dailySalary; 
      
      if (_bankBalance > 0) {
        double interest = _bankBalance * _dailyInterestRate;
        _bankBalance += interest; 
      }
      
      final String response = await rootBundle.loadString('assets/events.json');
      final List<dynamic> data = json.decode(response);
      _inboxEvents = data.map((e) => GameEvent.fromJson(e)).toList();
      
      await prefs.setDouble('cash', _cash);
      await prefs.setDouble('bankBalance', _bankBalance); 
      await prefs.setInt('currentDay', _currentDay);
      
      // --- 关键新增：定时器在后台算完账后，立刻通知画面数字跳动 ---
      notifyListeners(); 
    }
    
    // 每次上线都更新最后登录时间
    await prefs.setString('lastLoginDate', now.toIso8601String());
  }

  void resolveEvent(GameEvent event) async {
    _cash += event.amount;
    _inboxEvents.removeWhere((e) => e.id == event.id);
    
    // 花钱后立刻存盘
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('cash', _cash);
    notifyListeners();
  }

  void updateWorkHours(int start, int end) async {
    _workStartHour = start;
    _workEndHour = end;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('startHour', _workStartHour);
    await prefs.setInt('endHour', _workEndHour);
    notifyListeners();

  // 存款
  void deposit(double amount) async {
    if (_cash >= amount && amount > 0) {
      _cash -= amount;
      _bankBalance += amount;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('cash', _cash);
      await prefs.setDouble('bankBalance', _bankBalance);
      notifyListeners();
    }
  }

  // 取款
  void withdraw(double amount) async {
    if (_bankBalance >= amount && amount > 0) {
      _bankBalance -= amount;
      _cash += amount;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('cash', _cash);
      await prefs.setDouble('bankBalance', _bankBalance);
      notifyListeners();
    }
  }
  }
  // --- 新增：存款功能 ---
  void deposit(double amount) async {
    if (_cash >= amount && amount > 0) {
      _cash -= amount;
      _bankBalance += amount;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('cash', _cash);
      await prefs.setDouble('bankBalance', _bankBalance);
      notifyListeners();
    }
  }

  // --- 新增：取款功能 ---
  void withdraw(double amount) async {
    if (_bankBalance >= amount && amount > 0) {
      _bankBalance -= amount;
      _cash += amount;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('cash', _cash);
      await prefs.setDouble('bankBalance', _bankBalance);
      notifyListeners();
    }
  }
}