import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'info_page.dart';
import 'analysis_page.dart';

class NextPage extends StatefulWidget {
  const NextPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _NextPageState createState() => _NextPageState();
}
class _NextPageState extends State<NextPage> {
  late Future<List<User>> _usersFuture;
  List<User> _allUsers = [];
  List<User> _filteredUsers = [];
  late List<User> users;

  @override
  void initState() {
    super.initState();
    _usersFuture = _getUsers();
    _usersFuture.then((users) {
      setState(() {
        _allUsers = users;
        _filteredUsers = users;
        this.users = users;
      });
    });
  }

  Future<List<User>> _getUsers() async {
    try {
      final data = await http.get(Uri.parse('http://10.0.2.2:5000/api'));
      if (data.statusCode == 200) {
        var jsonData = json.decode(data.body);
        List<User> users = [];
        for (var u in jsonData) {
          User user = User(
              u["id"],
              u["academic_status"],
              u["degree"],
              u["email"],
              u["google_citation"],
              u["google_h_index"],
              u["google_i10_index"],
              u["google_link"],
              u["name"],
              u["phone"],
              u["photopath"],
              u["scopus_citation"],
              u["scopus_h_index"],
              u["scopus_works_amount"],
              u["scopus_link"],
              u["web_of_science_citation"],
              u["web_of_science_h_index"],
              u["web_of_science_work_amount"],
              u["web_of_science_link"]
          );
          users.add(user);
        }
        return users;
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  void _filterUsers(String query) {
    setState(() {
      _filteredUsers = _allUsers
          .where((user) => user.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Color _getColor(int index) {
    List<Color> colors = [
      Colors.blue[100]!,
      Colors.blue[300]!,
      Colors.blue[200]!,
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
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
            title: Text(widget.title),
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Autocomplete<User>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<User>.empty();
                } else {
                  return _allUsers.where((User user) {
                    return user.name
                        .toLowerCase()
                        .contains(textEditingValue.text.toLowerCase());
                  });
                }
              },
              displayStringForOption: (User option) => option.name,
              onSelected: (User selection) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InfoPage(user: selection, users: _allUsers),
                  ),
                );
              },
              fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                return TextField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  onChanged: (text) {
                    _filterUsers(text);
                  },
                  decoration: InputDecoration(
                    labelText: 'Search by last name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                );
              },
              optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<User> onSelected, Iterable<User> options) {
                if (options.isEmpty) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      child: Container(
                        color: Colors.lightBlue[50],
                        width: MediaQuery.of(context).size.width * 0.8,
                        padding: EdgeInsets.all(16.0),
                        child: Text('немає відповідного викладача', style: TextStyle(color: Colors.black)),
                      ),
                    ),
                  );
                }
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    child: Container(
                      color: Colors.lightBlue[50],
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: ListView.builder(
                        padding: EdgeInsets.all(8.0),
                        itemCount: options.length,
                        itemBuilder: (BuildContext context, int index) {
                          final User option = options.elementAt(index);
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Card(
                              color: _getColor(index),
                              child: ListTile(
                                title: Text(option.name),
                                onTap: () {
                                  onSelected(option);
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
            Expanded(
              child: FutureBuilder(
                future: _usersFuture,
                builder: (BuildContext context, AsyncSnapshot<List<User>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No users found'));
                  } else {
                    List<User> users = snapshot.data!;
                    return ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (BuildContext context, int index) {
                        final User user = users[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                          child: Card(
                            color: _getColor(index),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            elevation: 5,
                            child: Column(
                              children: [
                                ListTile(
                                  leading: CircleAvatar(
                                    radius: 30.0,
                                    backgroundImage: AssetImage(user.photopath),
                                    backgroundColor: Colors.transparent,
                                  ),
                                  title: Text('${index + 1}. ${user.name}'),
                                  subtitle: Text(user.email),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => InfoPage(user: user, users: _allUsers),
                                      ),
                                    );
                                  },
                                ),
                                // Add any other user information widgets here
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AnalysisPage(users: users),
            ),
          );
        },
        child: Icon(Icons.info),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

class User {
  final int id;
  final String academic_status;
  final String degree;
  final String email;
  final int google_citation;
  final int google_h_index;
  final int google_i10_index;
  final String google_link;
  final String name;
  final String phone;
  final String photopath;
  final int scopus_citation;
  final int scopus_h_index;
  final int scopus_works_amount;
  final String scopus_link;
  final int web_of_science_citation;
  final int web_of_science_h_index;
  final int web_of_science_work_amount;
  final String web_of_science_link;


  User(
      this.id,
      this.academic_status,
      this.degree,
      this.email,
      this.google_citation,
      this.google_h_index,
      this.google_i10_index,
      this.google_link,
      this.name,
      this.phone,
      this.photopath,
      this.scopus_citation,
      this.scopus_h_index,
      this.scopus_works_amount,
      this.scopus_link,
      this.web_of_science_citation,
      this.web_of_science_h_index,
      this.web_of_science_work_amount,
      this.web_of_science_link,
      );
}
