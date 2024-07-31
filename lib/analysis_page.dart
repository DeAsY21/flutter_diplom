import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'next_page.dart';

class AnalysisPage extends StatelessWidget {
  final List<User> users;

  AnalysisPage({required this.users});

  @override
  Widget build(BuildContext context) {
    Widget buildChart(String title, List<NewInfo> data, String seriesId) {
      data.sort((a, b) => b.data.compareTo(a.data));

      var series = [
        charts.Series(
          id: seriesId,
          data: data,
          domainFn: (NewInfo userData, _) => userData.name,
          measureFn: (NewInfo userData, _) => userData.data,
          colorFn: (_, __) => charts.ColorUtil.fromDartColor(Colors.blue),
        ),
      ];

      return Column(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2.0),
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding: EdgeInsets.all(8.0),
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(height: 10.0),
          SizedBox(
            height: 400.0,
            child: charts.BarChart(
              series,
              animate: true,
            ),
          ),
        ],
      );
    }

    List<NewInfo> googleData = users.map((user) {
      return NewInfo((user.id).toString(), (user.google_h_index).toDouble());
    }).toList();

    List<NewInfo> scopusData = users.map((user) {
      return NewInfo((user.id).toString(), (user.scopus_h_index).toDouble());
    }).toList();

    List<NewInfo> webofsciData = users.map((user) {
      return NewInfo((user.id).toString(), (user.web_of_science_h_index).toDouble());
    }).toList();

    List<NewInfo> EfectivScopus = users.map((user) {
      double efectiv = user.scopus_works_amount !=0? user.scopus_citation  / user.scopus_works_amount : 0.0;
      return NewInfo((user.id).toString(), efectiv);
    }).toList();

    List<NewInfo> EfectivWebOfSci = users.map((user) {
      double efectiv = user.web_of_science_work_amount !=0? user.web_of_science_citation / user.web_of_science_work_amount : 0.0;
      return NewInfo((user.id).toString(), efectiv);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
          child: AppBar(
            backgroundColor: Colors.blueAccent[400],
            title: Text('Статистика'),
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: [
                buildChart('Порівняння h-індексів за даними Google Академії', googleData, 'Google_h'),
                SizedBox(height: 20.0), // Простір між графіками
                buildChart('Порівняння h-індексів за даними Scopus', scopusData, 'Scopus_h'),
                SizedBox(height: 20.0), // Простір між графіками
                buildChart('Порівняння h-індексів за даними Web of Science', webofsciData, 'Web_h'),
                SizedBox(height: 20.0), // Простір між графіками
                buildChart('Середня цитованість робіт за даними Scopus', EfectivScopus, 'Web_h'),
                SizedBox(height: 20.0), // Простір між графіками
                buildChart('Середня цитованість робіт за даними Web of Science', EfectivWebOfSci, 'Web_h'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NewInfo {
  final String name;
  final double data;

  NewInfo(this.name, this.data);
}
