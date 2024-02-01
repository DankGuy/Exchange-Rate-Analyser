import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:exchange_rate_analyser/components/line_chart.dart';
import 'package:exchange_rate_analyser/components/outline_button.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GraphPage extends StatefulWidget {
  const GraphPage({super.key});

  @override
  State<GraphPage> createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  String? selectedYear;
  bool isLoading = false;
  List<Map<String, dynamic>> middleRatesResult = [];

  // fetch data from API
  Future<void> fetchData({required String year}) async {
    Map<String, List<double>> middleRatesMap = {};
    List<String> sessions = ['0900', '1200', '1700'];

    DateTime date = DateTime.parse('$year-01-01');
    DateTime nextYear = DateTime.parse('${int.parse(year) + 1}-01-01');

    setState(() {
      isLoading = true;
    });

    while (date.isBefore(nextYear)) {
      for (var session in sessions) {
        String month = date.month.toString().padLeft(2, '0');
        String day = date.day.toString().padLeft(2, '0');
        final response = await http.get(Uri.parse(
            'http://172.16.0.2/bnm-exchange-rate/$year/$month/$day/$session.json'));

        // check if the response status is 200 before decoding
        if (response.statusCode == 200) {
          final parsedData = jsonDecode(response.body);
          for (var rateData in parsedData) {
            if (rateData['currency_code'] == 'USD') {
              String dateKey = rateData['rate']['date'];
              if (!middleRatesMap.containsKey(dateKey)) {
                middleRatesMap[dateKey] = [];
              }
              middleRatesMap[dateKey]!.add(rateData['rate']['middle_rate']);
              break;
            }
          }
        }
      }
      date = date.add(const Duration(days: 1));
    }

    List<Map<String, dynamic>> middleRatesResult = [];
    middleRatesMap.forEach((date, rates) {
      double averageRate = rates.reduce((a, b) => a + b) / rates.length;
      middleRatesResult
          .add({'date': DateTime.parse(date), 'middle_rate': averageRate});
    });

    middleRatesResult.sort((a, b) => a['date'].compareTo(b['date']));

    setState(() {
      isLoading = false;
      this.middleRatesResult = middleRatesResult;
    });
    print(this.middleRatesResult);
  }

  void onPressed() {
    if (selectedYear != null) {
      fetchData(year: selectedYear!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Column(
                    children: [
                      DropdownSearch<String>(
                        popupProps: const PopupProps.menu(
                          showSelectedItems: true,
                        ),
                        items: List<String>.generate(
                                10, (i) => (DateTime.now().year - i).toString())
                            .toList(),
                        dropdownDecoratorProps: const DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            labelText: "Year",
                            hintText: "Year in menu mode",
                          ),
                        ),
                        onChanged: (String? value) {
                          if (value != null) {
                            setState(
                              () {
                                selectedYear = value;
                              },
                            );
                          }
                        },
                        selectedItem: "Select Year",
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 50.0,
                  ),
                  OutlineBtn(onPressed: onPressed, btnText: 'Show Graph'),
                  const SizedBox(
                    height: 50.0,
                  ),
                  Column(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Graph for Year 2021',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      LineChart(middleRates: middleRatesResult),
                    ],
                  ),
                ],
              ),
            ),
            isLoading // Check if data is loading
                ? Expanded(
                  child: Center(
                      child: Container(
                        color: Colors.black.withOpacity(1),
                        child: const CircularProgressIndicator(),
                      ),
                    ),
                )
                : const SizedBox.shrink(), // Show nothing when not loading
          ],
        ),
      ),
    );
  }
}
