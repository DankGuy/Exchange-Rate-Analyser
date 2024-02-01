import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:exchange_rate_analyser/components/outline_button.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MiddleRatePage extends StatefulWidget {
  const MiddleRatePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MiddleRatePageState createState() => _MiddleRatePageState();
}

class _MiddleRatePageState extends State<MiddleRatePage> {
  double highest = 0.0, lowest = 0.0, average = 0.0;
  bool isLoading = false;
  String? selectedYear;

  // fetch data from API
  Future<void> fetchData({required String year}) async {
    List<double> middleRates = [];
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
              middleRates.add(rateData['rate']['middle_rate']);
              break;
            }
          }
        }
      }
      date = date.add(const Duration(days: 1));
    }

    double highestRate = middleRates
        .reduce((value, element) => value > element ? value : element);
    double lowestRate = middleRates
        .reduce((value, element) => value < element ? value : element);
    double averageRate =
        middleRates.reduce((value, element) => value + element) /
            middleRates.length;

    // fixed to 3 decimal places
    averageRate = double.parse(averageRate.toStringAsFixed(3));
    highestRate = double.parse(highestRate.toStringAsFixed(3));
    lowestRate = double.parse(lowestRate.toStringAsFixed(3));

    setState(() {
      highest = highestRate;
      lowest = lowestRate;
      average = averageRate;
      isLoading = false;
    });
  }

  void onYearChanged(String? value) {
    if (value != null) fetchData(year: value);
  }

  void _handleButtonPress() {
    if (selectedYear != null) {
      fetchData(year: selectedYear!);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select a year',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto'),
          ),
          backgroundColor: Colors.red,
        ),
      );
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
                  const Text(
                    'Middle Rate',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  // divider for instruction
                  const Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 2,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text('Choose date and Currency Code'),
                      SizedBox(width: 10),
                      Expanded(
                        child: Divider(
                          thickness: 2,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // a row for year and currency code selection
                  Row(
                    children: [
                      Expanded(
                        child: DropdownSearch<String>(
                          popupProps: const PopupProps.menu(
                            showSelectedItems: true,
                          ),
                          items: List<String>.generate(10,
                                  (i) => (DateTime.now().year - i).toString())
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
                      ),

                      const SizedBox(width: 10), // space between dropdowns

                      Expanded(
                        child: DropdownSearch<String>(
                          popupProps: PopupProps.menu(
                            showSelectedItems: true,
                            disabledItemFn: (String s) => s != 'USD',
                          ),
                          items: const ["USD", "MYR", "TWD", "EUR"],
                          dropdownDecoratorProps: const DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                              labelText: "Currency",
                              hintText: "country in menu mode",
                            ),
                          ),
                          onChanged: print,
                          selectedItem: "USD",
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 80),

                  OutlineBtn(
                    onPressed: _handleButtonPress,
                    btnText: "Show Result",
                  ),

                  const SizedBox(height: 80),

                  const Center(
                    child: Text(
                      'Result',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 15), // space between title and table
                  // a row for table to show highest, lowest, average of middle rate
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Highest',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  highest.toString(),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Lowest',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  lowest.toString(),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Average',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  average.toString(),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            isLoading // Check if data is loading
                ? Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.5),
                      child: const Center(
                        child: CircularProgressIndicator(),
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
