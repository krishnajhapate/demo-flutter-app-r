import 'package:app/models/student.dart';
import 'package:app/screens/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late List<Student> students = [];
  bool isLoading = false;
  bool hasMore = true;
  int documentLimit = 10;
  DocumentSnapshot? lastDocument;
  ScrollController _scrollController = ScrollController();
  bool showAlumni = false;
  bool showActive = false;
  String searchQuery = '';
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);

    fetchData();
  }

  void _scrollListener() {
    print('caleed');
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      fetchData();
    }
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });

    Query query = FirebaseFirestore.instance.collection('students');

    // Apply filters
    if (showAlumni) {
      query = query.where('isAlumni', isEqualTo: true);
    }

    if (showActive) {
      query = query.where('isActive', isEqualTo: true);
    }

    if (searchQuery.isNotEmpty) {
      String searchLowerCase = searchQuery.toLowerCase();
      String searchUpperCase = searchQuery.toUpperCase();

      // Search on all fields
      query = query
          .where('name', isGreaterThanOrEqualTo: searchLowerCase)
          .where('name', isLessThan: searchLowerCase + 'z')
          .where('name', isGreaterThanOrEqualTo: searchUpperCase)
          .where('name', isLessThan: searchUpperCase + 'z')
          .where('classRoom', isGreaterThanOrEqualTo: searchLowerCase)
          .where('classRoom', isLessThan: searchLowerCase + 'z')
          .where('classRoom', isGreaterThanOrEqualTo: searchUpperCase)
          .where('classRoom', isLessThan: searchUpperCase + 'z')
          .where('address', isGreaterThanOrEqualTo: searchLowerCase)
          .where('address', isLessThan: searchLowerCase + 'z')
          .where('address', isGreaterThanOrEqualTo: searchUpperCase)
          .where('address', isLessThan: searchUpperCase + 'z')
          .where('phone', isEqualTo: searchQuery)
          .where('phone', isGreaterThanOrEqualTo: searchLowerCase)
          .where('phone', isLessThan: searchLowerCase + 'z')
          .where('phone', isGreaterThanOrEqualTo: searchUpperCase)
          .where('phone', isLessThan: searchUpperCase + 'z')
          .where('email', isEqualTo: searchQuery)
          .where('email', isGreaterThanOrEqualTo: searchLowerCase)
          .where('email', isLessThan: searchLowerCase + 'z')
          .where('email', isGreaterThanOrEqualTo: searchUpperCase)
          .where('email', isLessThan: searchUpperCase + 'z')
          .where('parentsName', isEqualTo: searchQuery)
          .where('parentsName', isGreaterThanOrEqualTo: searchLowerCase)
          .where('parentsName', isLessThan: searchLowerCase + 'z')
          .where('parentsName', isGreaterThanOrEqualTo: searchUpperCase)
          .where('parentsName', isLessThan: searchUpperCase + 'z')
          .where('mothersName', isEqualTo: searchQuery)
          .where('mothersName', isGreaterThanOrEqualTo: searchLowerCase)
          .where('mothersName', isLessThan: searchLowerCase + 'z')
          .where('mothersName', isGreaterThanOrEqualTo: searchUpperCase)
          .where('mothersName', isLessThan: searchUpperCase + 'z')
          .where('dob', isEqualTo: searchQuery)
          .where('dob', isGreaterThanOrEqualTo: searchLowerCase)
          .where('dob', isLessThan: searchLowerCase + 'z')
          .where('dob', isGreaterThanOrEqualTo: searchUpperCase)
          .where('dob', isLessThan: searchUpperCase + 'z');
    }

    print("$startDate $endDate");

    if (startDate != null) {
      query = query.where('dob', isGreaterThanOrEqualTo: startDate);
    }

    if (endDate != null) {
      query = query.where('dob', isLessThanOrEqualTo: endDate);
    }

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument!);
    }
    // Execute query
    QuerySnapshot querySnapshot = await query.limit(documentLimit).get();

    // Update students list
    if (querySnapshot.docs.isNotEmpty) {
      print("WEHE ARE NEW ");

      List<Student> ls = students;
      ls.addAll(
        querySnapshot.docs
            .map((doc) => Student.fromMap(doc.data() as Map<String, dynamic>))
            .toList(),
      );
      setState(() {
        students = ls;
        lastDocument = querySnapshot.docs.last;
      });
    }

    // Update hasMore flag
    if (querySnapshot.docs.length < documentLimit) {
      setState(() {
        hasMore = false;
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _refreshData() async {
    setState(() {
      students.clear();
      lastDocument = null;
      hasMore = true;
    });

    await fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Students List',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(
              Icons.logout,
              color: Colors.white,
            ),
            onPressed: () {
              _handleSignOut(context);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Column(
          children: [
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                    _refreshData();
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Search',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            ExpansionTile(
              title: Text("Filters"),
              children: [
                Column(
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: showAlumni,
                          onChanged: (value) {
                            setState(() {
                              showAlumni = value ?? false;
                              _refreshData();
                            });
                          },
                        ),
                        Text('Show Alumni'),
                        SizedBox(width: 10),
                        Checkbox(
                          value: showActive,
                          onChanged: (value) {
                            setState(() {
                              showActive = value ?? false;
                              _refreshData();
                            });
                          },
                        ),
                        Text('Show Active'),
                      ],
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        final selectedDates = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (selectedDates != null) {
                          setState(() {
                            startDate = selectedDates.start;
                            endDate = selectedDates.end;
                            _refreshData();
                          });
                        }
                      },
                      child: Text('Select Dob Range'),
                    ),
                  ],
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: students.length + (hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == students.length) {
                    return _buildProgressIndicator();
                  } else {
                    return ExpansionTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(students[index].avatar ??
                            "https://cloudflare-ipfs.com/ipfs/Qmd3W5DuhgHirLHGVixi6V76LhCkZUz6pnFt5AJBiyvHye/avatar/32.jpg"),
                        backgroundColor: Colors
                            .blue, // Change the background color of the CircleAvatar
                      ),
                      title: Text(students[index].name),
                      subtitle: Text(students[index].classRoom),
                      trailing: Icon(Icons.keyboard_arrow_down),
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('Address: ${students[index].address}'),
                              Text('Phone: ${students[index].phone}'),
                              Text('Email: ${students[index].email}'),
                              Text(
                                  'School Joined At: ${students[index].schoolJoinedAt}'),
                              Text(
                                  'Roll Number: ${students[index].rollNumber}'),
                              Text(
                                  'Parents Name: ${students[index].parentsName}'),
                              Text(
                                  'Mothers Name: ${students[index].mothersName}'),
                              Text('Date of Birth: ${students[index].dob}'),
                              Text(
                                  'Is Alumni: ${students[index].isAlumni ? 'Yes' : 'No'}'),
                              Text(
                                  'Is Active: ${students[index].isActive ? 'Yes' : 'No'}'),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSignOut(BuildContext context) async {
    try {
      await _auth.signOut();
      // Navigate back to the login screen or any other screen as needed
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } catch (e) {
      // Handle sign out errors
      print('Error signing out: $e');
    }
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Center(
        child: Opacity(
          opacity: isLoading ? 1.0 : 0.0,
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
