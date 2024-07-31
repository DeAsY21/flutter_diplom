import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'next_page.dart';

class InfoPage extends StatelessWidget {
  final User user;
  final List<User> users;
  InfoPage({required this.user, required this.users});

  Future<void> _launchURL(BuildContext context, String url) async {
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.inAppWebView);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Не вдалося відкрити посилання: $url'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Помилка при відкритті посилання: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalGoogleCitations = users.fold(0, (sum, user) => sum + user.google_citation);
    int totalGoogleHIndex = users.fold(0, (sum, user) => sum + user.google_h_index);
    int totalGoogleI10Index = users.fold(0, (sum, user) => sum + user.google_i10_index);

    int totalScopusCitations = users.fold(0, (sum, user) => sum + user.scopus_citation);
    int totalScopusHIndex = users.fold(0, (sum, user) => sum + user.scopus_h_index);
    int totalScopusWorks = users.fold(0, (sum, user) => sum + user.scopus_works_amount);

    int totalWebOfScienceHIndex = users.fold(0, (sum, user) => sum + user.web_of_science_h_index);
    int totalWebOfScienceWorks = users.fold(0, (sum, user) => sum + user.web_of_science_work_amount);
    int totalWebOfScienceCitations = users.fold(0, (sum, user) => sum + user.web_of_science_citation);

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
            title: Text(user.name),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Container(
                  width: double.infinity,
                  height: 400,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue, width: 5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset(
                      user.photopath,
                      width: double.infinity,
                      height: 400,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              buildInfoBlock(
                title: 'Інформація',
                content: [
                  'Науковий ступінь: ${user.degree}',
                  'Вчене звання: ${user.academic_status}',
                  'Пошта: ${user.email}',
                  'Телефон: ${user.phone}',
                ],
              ),
              SizedBox(height: 20),
              buildInfoBlock(
                title: 'Google Академія',
                content: [
                  'Цитування: ${user.google_citation} (${((user.google_citation/totalGoogleCitations) * 100).toStringAsFixed(1)}%)',
                  'H-індекс: ${user.google_h_index} (${((user.google_h_index/totalGoogleHIndex) * 100).toStringAsFixed(1)}%)',
                  'i10-індекс: ${user.google_i10_index} (${((user.google_i10_index/totalGoogleI10Index) * 100).toStringAsFixed(1)}%)',
                ],
                buttonText: 'Посилання на Google Академію',
                buttonUrl: user.google_link,
                context: context,
              ),
              SizedBox(height: 20),
              buildInfoBlock(
                title: 'Scopus',
                content: [
                  'Цитування: ${user.scopus_citation} (${((user.scopus_citation/totalScopusCitations) * 100).toStringAsFixed(1)}%)',
                  'H-індекс: ${user.scopus_h_index} (${((user.scopus_h_index/totalScopusHIndex) * 100).toStringAsFixed(1)}%)',
                  'Кількість робіт: ${user.scopus_works_amount} (${((user.scopus_works_amount/totalScopusWorks) * 100).toStringAsFixed(1)}%)',
                ],
                buttonText: 'Посилання на Scopus',
                buttonUrl: user.scopus_link,
                context: context,
              ),
              SizedBox(height: 20),
              buildInfoBlock(
                title: 'Web of Science',
                content: [
                  'Цитування: ${user.web_of_science_citation} (${((user.web_of_science_citation/totalWebOfScienceCitations) * 100).toStringAsFixed(1)}%)',
                  'H-індекс: ${user.web_of_science_h_index} (${((user.web_of_science_h_index/totalWebOfScienceHIndex) * 100).toStringAsFixed(1)}%)',
                  'Кількість робіт: ${user.web_of_science_work_amount} (${((user.web_of_science_work_amount/totalWebOfScienceWorks) * 100).toStringAsFixed(1)}%)',
                ],
                buttonText: 'Посилання на Web of Science',
                buttonUrl: user.web_of_science_link,
                context: context,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInfoBlock({
    required String title,
    required List<String> content,
    String? buttonText,
    String? buttonUrl,
    BuildContext? context,
  }) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        color: Colors.lightBlue[100],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              for (var text in content) Text(text, style: TextStyle(fontSize: 16)),
              if (buttonText != null && buttonUrl != null && context != null) ...[
                SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[300],
                  ),
                  onPressed: () => _launchURL(context, buttonUrl),
                  child: Text(
                    buttonText,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
