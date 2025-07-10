import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:quitter/Assets/colors.dart';
import 'package:quitter/components/bar_graph/bar_graph.dart';
import 'package:quitter/pages/home_page.dart';

class GraphPage extends StatefulWidget {
  const GraphPage({super.key});

  @override
  State<GraphPage> createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {


  List<double> testData = [
    40,
    50,
    40,
    30,
    35,
    34,
    44
  ];

  @override
  Widget build(BuildContext context) {
    return
      Center(
        child: SizedBox(
              height: 400,
              child: MyBarGraph(weeklySummary: testData,)
            ),
      );
  }
}
