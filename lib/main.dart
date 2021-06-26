import 'package:flutter/material.dart';
import 'package:favors_manager/mock_values.dart';
import 'package:favors_manager/favor.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: FavorsPage(
        pendingAnswerFavors: mockPendingFavors,
        completedFavors: mockCompletedFavors,
        refusedFavors: mockRefusedFavors,
        acceptedFavors: mockDoingFavors,
      ),
    );
  }
}

class FavorsPage extends StatelessWidget {
  // using mock values from mock_favors file for now
  final List<Favor> pendingAnswerFavors;
  final List<Favor> acceptedFavors;
  final List<Favor> completedFavors;
  final List<Favor> refusedFavors;

  FavorsPage({
    Key? key,
    required this.pendingAnswerFavors,
    required this.acceptedFavors,
    required this.completedFavors,
    required this.refusedFavors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Your favors"),
          bottom: TabBar(tabs: [
            _buildCategoryTab("Requests"),
            _buildCategoryTab("Doing"),
            _buildCategoryTab("Completed"),
            _buildCategoryTab("Refused"),
          ]),
        ),
        body: TabBarView(children: [
          _favorsList("Pending Requests", pendingAnswerFavors),
          _favorsList("Doing", acceptedFavors),
          _favorsList("Completed", completedFavors),
          _favorsList("Refused", refusedFavors),
        ]),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          tooltip: 'Ask a favor',
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildCategoryTab(String title) {
    return Tab(
      child: Text(title),
    );
  }
}
