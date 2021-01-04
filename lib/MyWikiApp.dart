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
  final _searchBloc = SearchResultBloc(); //Instance of bloc

  @override
  void initState() {
    super.initState();
    _searchBloc.searchEventSink
        .add(""); //To avoid display of loading spinner on start of the app
  }

  @override
  void dispose() {
    _searchBloc.dispose(); //To avoid memory leak
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
                        _searchBloc.searchEventSink.add(
                            searchWord); //Passing search word as input to event sink
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
                    stream: _searchBloc
                        .searchResultStream, //Listening to output stream
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Padding(
                          padding: const EdgeInsets.all(30.0),
                          child: Text("Something went wrong. Try again later"),
                        );
                      }

                      if (snapshot.hasData) {
                        List<SearchResult> results = snapshot
                            .data; //List of search results based on search word

                        return SingleChildScrollView(
                          child: Column(
                            children: [
                              _searchBloc
                                      .offlineContent //Check if content is from cache, if yes, display offline message accordingly
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
                                      child: Column(
                                        children: [
                                          Opacity(
                                            opacity: 0.6,
                                            child: Image.asset(
                                                "images/wiki_placeholder.png",
                                                height: 200,
                                                width: 200),
                                          ),
                                          (_searchbar.text != "")
                                              ? Text("No search results")
                                              : Container()
                                        ],
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
