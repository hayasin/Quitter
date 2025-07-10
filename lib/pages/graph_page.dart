import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:quitter/Assets/colors.dart';
import 'package:quitter/components/bar_graph/bar_graph.dart';
import 'package:quitter/pages/home_page.dart';
import 'package:quitter/services/auth_service.dart';

class GraphPage extends StatefulWidget {
  const GraphPage({super.key});

  @override
  State<GraphPage> createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  // List<double> testData = [
  //   40,
  //   50,
  //   40,
  //   30,
  //   35,
  //   34,
  //   44
  // ];

  List<double> weeklySummary = [0, 0, 0, 0, 0, 0, 0];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchWeeklyData();
  }

  Future<void> fetchWeeklyData() async {
    try {
      final counts = await getWeeklyHitCounts();
      setState(() {
        weeklySummary = counts.map((c) => c.toDouble()).toList();
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching data");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(height: 400, child: MyBarGraph(weeklySummary: weeklySummary)),
    );
  }
}
