import 'package:exchange_rate_analyser/components/calendar_view.dart';
import 'package:exchange_rate_analyser/components/outline_button.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  List<String> sesionList = ['0900', '1200', '1700'];
  String currencyCode = 'N/A';
  dynamic session;
  DateTime? _selectedDay = DateTime.now();
  String buyRate = 'N/A';
  String sellRate = 'N/A';
  String middleRate = 'N/A';

  @override
  void initState() {
    super.initState();
    // set session to 0900 by default
    session = sesionList[0];
  }

  Future<void> fetchData(
      {required DateTime date, required String session}) async {
    // split the date into year, month and day
    String year = date.year.toString();
    String month = date.month.toString();
    String day = date.day.toString();

    // if month is less than 10, add a 0 in front of it
    if (month.length == 1) {
      month = '0$month';
    }
    // if day is less than 10, add a 0 in front of it
    if (day.length == 1) {
      day = '0$day';
    }

// get the data from the API
    var response = await http.get(Uri.parse(
        'http://172.16.0.2/bnm-exchange-rate/$year/$month/$day/$session.json'));

// if the response is successful, update the UI
    if (response.statusCode == 200) {
      final parsedData = jsonDecode(response.body);
      bool foundUSD = false;
      for (var rateData in parsedData) {
        if (rateData['currency_code'] == 'USD') {
          setState(
            () {
              currencyCode = rateData['currency_code'] ?? 'N/A';
              buyRate = rateData['rate']['buying_rate']?.toString() ?? 'N/A';
              sellRate = rateData['rate']['selling_rate']?.toString() ?? 'N/A';
              middleRate = rateData['rate']['middle_rate']?.toString() ?? 'N/A';
            },
          );
          foundUSD = true;
          break;
        }
      }
      if (!foundUSD) {
        setState(() {
          currencyCode = 'N/A';
          buyRate = 'N/A';
          sellRate = 'N/A';
          middleRate = 'N/A';
        });
      }
    } else {
      setState(() {
        currencyCode = 'N/A';
        buyRate = 'N/A';
        sellRate = 'N/A';
        middleRate = 'N/A';
      });
    }
  }

  void _onPressed() {
    setState(() {
      // get the index of current session
      int index = sesionList.indexOf(session);
      // if current session is the last session, set it to the first session
      if (index == sesionList.length - 1) {
        session = sesionList[0];
      } else {
        // else, set it to the next session
        session = sesionList[index + 1];
      }
      fetchData(date: _selectedDay!, session: session);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              CalendarView(
                onDaySelected: (selectedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                  });
                  fetchData(date: _selectedDay!, session: session);
                },
              ),
              const SizedBox(
                height: 20.0,
              ),
              const Text(
                'Rates of the Day',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10.0,
              ),
              Builder(
                builder: (context) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Container(
                    alignment: Alignment.centerRight,
                    child: OutlineBtn(
                        onPressed: _onPressed, btnText: "Next Session"),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: 400,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      buildRow('Session', Icons.access_time_outlined, session),
                      buildRow('Currency Code', Icons.money, currencyCode),
                      buildRow('Buy Rate', Icons.trending_up, buyRate),
                      buildRow('Sell Rate', Icons.trending_down, sellRate),
                      buildRow('Middle Rate', Icons.compare_arrows, middleRate),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildRow(String title, IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          const SizedBox(width: 20),
          Expanded(
            child: Row(
              children: [
                Icon(icon, color: Colors.black),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(width: 50),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Text(
                value,
                style: TextStyle(
                  fontWeight: title == 'Currency Code' || title == 'Session'
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
