import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:worklife/providers/game_state.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<GameState>(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 职业信息卡片
          Card(
            elevation: 4,
            child: ListTile(
              leading: const Icon(Icons.work, size: 40, color: Colors.blueGrey),
              title: Text("Current Job: ${state.jobTitle}"),
              subtitle: Text("Daily Salary: \$${state.dailySalary.toStringAsFixed(2)}"),
              trailing: Text("Day ${state.currentDay}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 30),
          
          // 工作时间设置区
          const Text("Set Working Hours (Auto-Earnings)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text("Start Time: ${state.workStartHour}:00", style: const TextStyle(fontSize: 16)),
          Slider(
            value: state.workStartHour.toDouble(),
            min: 0,
            max: 23,
            divisions: 23,
            label: "${state.workStartHour}:00",
            onChanged: (value) {
              if (value < state.workEndHour) {
                state.updateWorkHours(value.toInt(), state.workEndHour);
              }
            },
          ),
          Text("End Time: ${state.workEndHour}:00", style: const TextStyle(fontSize: 16)),
          Slider(
            value: state.workEndHour.toDouble(),
            min: 0,
            max: 23,
            divisions: 23,
            label: "${state.workEndHour}:00",
            onChanged: (value) {
              if (value > state.workStartHour) {
                state.updateWorkHours(state.workStartHour, value.toInt());
              }
            },
          ),
          
          const Spacer(),
          
        ],
      ),
    );
  }
}