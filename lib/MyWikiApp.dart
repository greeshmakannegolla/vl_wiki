import 'package:flutter/material.dart';
import 'package:wiki/Model.dart';
import 'package:wiki/SearchResultCard.dart';
import 'package:wiki/SearchResultsBloc.dart';

class MyWikiApp extends StatefulWidget {
  MyWikiApp({Key key}) : super(key: key);

  @override
  _MyWikiAppState createState() => _MyWikiAppState();
}

class _MyWikiAppState extends State<MyWikiApp> {
  TextEditingController _searchbar = TextEditingController();
  final _searchBloc = SearchResultBloc();

  @override
  void initState() {
    super.initState();
    _searchBloc.searchEventSink.add("");
  }

  @override
  void dispose() {
    _searchBloc.dispose();
    super.dispose();
  }

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
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(6.0)),
                    border: Border.all(color: Colors.black)),
                child: Center(
                  child: TextField(
                      textAlignVertical: TextAlignVertical.center,
                      maxLines: 1,
                      onChanged: (String searchWord) async {
                        _searchBloc.searchEventSink.add(searchWord);
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
              Expanded(
                flex: 7,
                child: StreamBuilder(
                    stream: _searchBloc.searchResultStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Padding(
                          padding: const EdgeInsets.all(30.0),
                          child: Text("Something went wrong. Try again later"),
                        );
                      }

                      if (snapshot.hasData) {
                        List<SearchResult> results = snapshot.data;

                        return SingleChildScrollView(
                          child: Column(
                            children: [
                              _searchBloc.offlineContent
                                  ? Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        "No internet, trying offline content",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    )
                                  : Container(),
                              results.isEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.only(top: 200),
                                      child: Opacity(
                                        opacity: 0.6,
                                        child: Image.asset(
                                            "images/wiki_placeholder.png",
                                            height: 200,
                                            width: 200),
                                      ),
                                    )
                                  : ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: results.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        var curResult = results[index];
                                        return Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                0, 8, 0, 8),
                                            child: SearchResultCard(curResult));
                                      }),
                            ],
                          ),
                        );
                      } else {
                        return Center(child: CircularProgressIndicator());
                      }
                    }),
              )
            ],
          ),
        ),
      ),
    );
  }
}
