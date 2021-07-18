import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:favors_manager/mock_values.dart';
import 'package:favors_manager/favor.dart';
import 'package:favors_manager/friend.dart';
import 'package:favors_manager/app_theme.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoApp(
        home: FavorsPage(),
      );
    }
    return MaterialApp(
      title: 'Flutter Demo',
      home: FavorsPage(),
      theme: lightTheme,
    );
  }
}

class FavorsPage extends StatefulWidget {
  FavorsPage({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => FavorsPageState();
}

class FavorsPageState extends State<FavorsPage> {
  // using mock values from mock_favors file for now
  late List<Favor> pendingAnswerFavors;
  late List<Favor> acceptedFavors;
  late List<Favor> completedFavors;
  late List<Favor> refusedFavors;

  @override
  void initState() {
    super.initState();

    pendingAnswerFavors = [];
    acceptedFavors = [];
    completedFavors = [];
    refusedFavors = [];

    loadFavors();
  }

  void loadFavors() {
    pendingAnswerFavors.addAll(mockPendingFavors);
    acceptedFavors.addAll(mockDoingFavors);
    completedFavors.addAll(mockCompletedFavors);
    refusedFavors.addAll(mockRefusedFavors);
  }

  static FavorsPageState of(BuildContext context) {
    return context.findAncestorStateOfType<FavorsPageState>()!;
  }

  @override
  Widget build(BuildContext context) {
    var tabs = [
      _buildCategoryTab("Requests", Icons.help_outline),
      _buildCategoryTab("Doing", Icons.directions_run),
      _buildCategoryTab("Completed", Icons.done),
      _buildCategoryTab("Refused", Icons.close),
    ];

    if (Platform.isIOS) {
      return SafeArea(
          child: CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          items: tabs.map((e) => e as BottomNavigationBarItem).toList(),
        ),
        tabBuilder: (BuildContext context, int index) {
          return CupertinoTabView(
            builder: (context) {
              switch (index) {
                case 0:
                  return FavorsList(
                    title: "Pending Requests",
                    favors: pendingAnswerFavors,
                  );
                case 1:
                  return FavorsList(title: "Doing", favors: acceptedFavors);
                case 2:
                  return FavorsList(
                      title: "Completed", favors: completedFavors);
                case 3:
                  return FavorsList(title: "Refused", favors: refusedFavors);

                default:
                  return RequestFavorPage(friends: mockFriends);
              }
            },
          );
        },
      ));
    }

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
            title: Text("Your favors"),
            bottom: TabBar(
              isScrollable: true,
              tabs: tabs.map((e) => e as Widget).toList(),
            )),
        body: TabBarView(children: [
          FavorsList(title: "Pending Requests", favors: pendingAnswerFavors),
          FavorsList(title: "Doing", favors: acceptedFavors),
          FavorsList(title: "Completed", favors: completedFavors),
          FavorsList(title: "Refused", favors: refusedFavors),
        ]),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => RequestFavorPage(
                      friends: mockFriends,
                    )));
          },
          tooltip: 'Ask a favor',
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  _buildCategoryTab(String title, IconData iconData) {
    if (Platform.isIOS) {
      return BottomNavigationBarItem(icon: Icon(iconData), label: title);
    }
    return Tab(
      icon: Icon(iconData),
      child: Text(title),
    );
  }

  void refuseToDo(Favor favor) {
    setState(() {
      pendingAnswerFavors.remove(favor);

      refusedFavors.add(favor.copyWith(accepted: false));
    });
  }

  void acceptToDo(Favor favor) {
    setState(() {
      pendingAnswerFavors.remove(favor);

      acceptedFavors.add(favor.copyWith(accepted: true));
    });
  }

  void giveUp(Favor favor) {
    setState(() {
      acceptedFavors.remove(favor);

      refusedFavors.add(favor.copyWith(accepted: false));
    });
  }

  void complete(Favor favor) {
    setState(() {
      acceptedFavors.remove(favor);

      completedFavors.add(favor.copyWith(completed: DateTime.now()));
    });
  }
}

class FavorsList extends StatelessWidget {
  final String title;
  final List<Favor> favors;

  const FavorsList({Key? key, required this.title, required this.favors})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.headline6;

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Padding(
            padding: EdgeInsets.only(top: 16.0),
            child: Text(
              title,
              style: titleStyle,
            )),
        Expanded(
            child: ListView.builder(
                itemBuilder: (BuildContext context, int index) {
                  final favor = favors[index];
                  return FavorCardItem(favor: favor);
                },
                itemCount: favors.length,
                physics: BouncingScrollPhysics()))
      ],
    );
  }
}

class FavorCardItem extends StatelessWidget {
  final Favor favor;

  const FavorCardItem({Key? key, required this.favor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bodyStyle = Theme.of(context).textTheme.headline6;

    return Card(
      key: ValueKey(favor.uuid),
      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            _itemHeader(context, favor),
            Text(favor.description, style: bodyStyle),
            _itemFooter(context, favor),
          ],
        ),
      ),
    );
  }

  Row _itemHeader(BuildContext context, Favor favor) {
    final headerStyle = Theme.of(context).textTheme.subtitle1;

    return Row(
      children: <Widget>[
        CircleAvatar(
          backgroundImage: NetworkImage(
            favor.friend.photoURL,
          ),
        ),
        Expanded(
            child: Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Text(
            "${favor.friend.name} asked you to",
            style: headerStyle,
          ),
        ))
      ],
    );
  }

  Widget _itemFooter(BuildContext context, Favor favor) {
    if (favor.isCompleted) {
      final format = DateFormat();
      final completedTextWidget = Text(
        "Completed at: ${format.format(favor.completed!)}",
      );
      return Container(
        margin: EdgeInsets.only(top: 8.0),
        alignment: Alignment.centerRight,
        child: Platform.isIOS
            ? completedTextWidget
            : Chip(
                label: completedTextWidget,
              ),
      );
    }

    if (favor.isRequested) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          TextButton(
              onPressed: () {
                FavorsPageState.of(context).refuseToDo(favor);
              },
              child: Text("Refuse")),
          TextButton(
              onPressed: () {
                FavorsPageState.of(context).acceptToDo(favor);
              },
              child: Text("Do")),
        ],
      );
    }

    if (favor.isDoing) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          TextButton(
              onPressed: () {
                FavorsPageState.of(context).giveUp(favor);
              },
              child: Text("Give up")),
          TextButton(
              onPressed: () {
                FavorsPageState.of(context).complete(favor);
              },
              child: Text("Complete")),
        ],
      );
    }

    return Container();
  }
}

class RequestFavorPage extends StatefulWidget {
  final List<Friend> friends;

  RequestFavorPage({Key? key, required this.friends}) : super(key: key);

  @override
  State<StatefulWidget> createState() => RequestFavorPageState();
}

class RequestFavorPageState extends State<RequestFavorPage> {
  final _formKey = GlobalKey<FormState>();
  Friend? _selectedFriend;

  static RequestFavorPageState of(BuildContext context) {
    return context.findAncestorStateOfType<RequestFavorPageState>()!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Requesting a favor"),
          leading: CloseButton(),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                save();
              },
              child: Text("SAVE"),
              style: ButtonStyle(
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white)),
            ),
          ],
        ),
        body: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("Request a favor to: "),
                  DropdownButtonFormField(
                    value: _selectedFriend,
                    onChanged: (Friend? friend) {
                      setState(() {
                        _selectedFriend = friend;
                      });
                    },
                    items: widget.friends
                        .map((e) => DropdownMenuItem(
                              child: Text(e.name),
                              value: e,
                            ))
                        .toList(),
                    validator: (friend) {
                      if (friend == null) {
                        return "You must select a friend to ask the favor";
                      }
                      return null;
                    },
                  ),
                  Container(
                    height: 16.0,
                  ),
                  Text("Favor description:"),
                  TextFormField(
                    maxLines: 5,
                    inputFormatters: [LengthLimitingTextInputFormatter(200)],
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "You must detail the favor";
                      }
                      return null;
                    },
                  ),
                  Container(
                    height: 16.0,
                  ),
                  Text("Due Date:"),
                  DateTimeField(
                    format: DateFormat("EEEE, MMMM d, yyyy 'at' h:mma"),
                    onShowPicker: (context, currentValue) async {
                      final date = await showDatePicker(
                          context: context,
                          firstDate: DateTime(1900),
                          initialDate: currentValue ?? DateTime.now(),
                          lastDate: DateTime(2100));
                      if (date != null) {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(
                              currentValue ?? DateTime.now()),
                        );
                        return DateTimeField.combine(date, time);
                      } else {
                        return currentValue;
                      }
                    },
                    validator: (dateTime) {
                      if (dateTime == null) {
                        return "You must select a due date time for the favor";
                      }
                      return null;
                    },
                  )
                ],
              ),
            )) // continues below,
        );
  }

  void save() {
    if (_formKey.currentState!.validate()) {
      // store the favor request on firebase
      Navigator.pop(context);
    }
  }
}
