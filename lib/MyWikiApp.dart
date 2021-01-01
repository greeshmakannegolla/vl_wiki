import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wiki/Model.dart';
import 'package:wiki/SearchResultCard.dart';
import 'package:wiki/Utils.dart';

class MyWikiApp extends StatefulWidget {
  MyWikiApp({Key key}) : super(key: key);

  @override
  _MyWikiAppState createState() => _MyWikiAppState();
}

class _MyWikiAppState extends State<MyWikiApp> {
  TextEditingController _searchbar = TextEditingController();
  List<SearchResult> _resultsToBeDisplayed = [];
  bool _loading = false;
  bool _offlineMode = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _offlineMode
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "No internet, trying offline content",
                        style: TextStyle(color: Colors.red),
                      ),
                    )
                  : Container(),
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(6.0)),
                    border: Border.all(color: Colors.grey)),
                child: Center(
                  child: TextField(
                      textAlignVertical: TextAlignVertical.center,
                      maxLines: 1,
                      onChanged: (String txt) {
                        _fetchResults(txt);
                      },
                      controller: _searchbar,
                      decoration: InputDecoration(
                        hintText: "Search",
                        suffixIcon: Icon(
                          Icons.search,
                          color: Colors.black,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 8.0),
                        hintStyle: TextStyle(
                          color: Colors.grey,
                        ),
                      )),
                ),
              ),
              _loading
                  ? Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: CircularProgressIndicator(),
                    )
                  : Expanded(
                      flex: 7,
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _resultsToBeDisplayed.length,
                          itemBuilder: (BuildContext context, int index) {
                            var curResult = _resultsToBeDisplayed[index];
                            return Padding(
                                padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                                child: SearchResultCard(curResult));
                          }),
                    )
            ],
          ),
        ),
      ),
    );
  }

  void _fetchResults(String searchWord) async {
    if (await checkInternetConnectivity()) {
      _fetchResultsInternet(searchWord);
    } else {
      _fetchResultsCache(searchWord);
    }
  }

  void _fetchResultsCache(String searchWord) async {
    _offlineMode = true;
    try {
      _loading = true;
      setState(() {});

      var prefs = await SharedPreferences.getInstance();
      Set<String> keys = prefs.getKeys();
      _resultsToBeDisplayed = [];

      if (searchWord.isNotEmpty) {
        for (String key in keys) {
          if (key.toLowerCase().contains(searchWord.toLowerCase())) {
            List<String> values = prefs.getStringList(key);

            SearchResult current = SearchResult();

            current.title = key;
            current.description = values[0];
            current.thumbnail = values[1];
            current.pageid = int.parse(values[2]);
            _resultsToBeDisplayed.add(current);
          }
        }
      }

      _loading = false;
      setState(() {});
    } catch (e) {
      _loading = false;
      setState(() {});
      showAlert(
        context,
        "Oops!",
        Text("Something went wrong. Try again later"),
      );
    }
  }

  void _fetchResultsInternet(String searchWord) async {
    _offlineMode = false;
    try {
      String apiUrl =
          'https://en.wikipedia.org/w/api.php?action=query&format=json&prop=pageimages|pageterms&generator=prefixsearch&redirects=1&formatversion=2&piprop=thumbnail&pithumbsize=50&pilimit=10&wbptterms=description&gpssearch=$searchWord&gpslimit=10';

      _loading = true;
      setState(() {});
      var result = await http.get(apiUrl);
      var jsonResponse = convert.jsonDecode(result.body);
      List searchResultsList =
          (jsonResponse["query"] != null) ? jsonResponse["query"]["pages"] : [];
      _resultsToBeDisplayed = [];
      for (var result in searchResultsList) {
        SearchResult current = SearchResult();
        current.title = capitalizeFirstLetter(result["title"] ?? "");
        current.thumbnail = (result["thumbnail"] != null)
            ? (result["thumbnail"]["source"] ?? "")
            : "";
        current.description = capitalizeFirstLetter((result["terms"] != null)
            ? (result["terms"]["description"][0] ?? "")
            : "");
        current.pageid = result["pageid"];
        _resultsToBeDisplayed.add(current);
      }
      _loading = false;
      setState(() {});
    } catch (e) {
      _loading = false;
      setState(() {});
      showAlert(
        context,
        "Oops!",
        Text("Something went wrong. Try again later"),
      );
    }
  }
}
