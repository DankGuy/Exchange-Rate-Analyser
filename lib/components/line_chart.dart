import 'package:d_chart/d_chart.dart';
import 'package:flutter/material.dart';

class LineChart extends StatefulWidget {
  final List<Map<String, dynamic>> middleRates;
  const LineChart({super.key, required this.middleRates});

  @override
  State<LineChart> createState() => _LineChartState();
}

class _LineChartState extends State<LineChart> {
  late List<TimeData> timeDataList;
  late List<TimeGroup> timeGroupList;

@override
void initState() {
  super.initState();
  timeDataList = widget.middleRates
      .map((entry) {
        DateTime parsedDate = DateTime.parse(entry['date']);
        DateTime formattedDate = DateTime(parsedDate.year, parsedDate.month, parsedDate.day);
        return TimeData(
          domain: formattedDate,
          measure: entry['middle_rate'],
        );
      })
      .toList();
  timeGroupList = [
    TimeGroup(
      id: '1',
      data: timeDataList,
    ),
  ];
}

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: DChartLineT(
        groupList: timeGroupList,
        allowSliding: true,
        configRenderLine:
            ConfigRenderLine(includeArea: true, includePoints: true), // default
        areaColor: (group, timeData, index) => Colors.blue.withOpacity(0.2),
      ),
    );
  }
}
