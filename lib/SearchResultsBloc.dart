import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wiki/Model.dart';
import 'package:wiki/Utils.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

class SearchResultBloc {
  final _stateStreamController =
      StreamController<List<SearchResult>>(sync: true);
  StreamSink<List<SearchResult>> get _searchResultSink =>
      _stateStreamController.sink;
  Stream<List<SearchResult>> get searchResultStream =>
      _stateStreamController.stream;

  final _eventStreamController = StreamController<String>(sync: true);
  StreamSink<String> get searchEventSink => _eventStreamController.sink;
  Stream<String> get _searchEventStream => _eventStreamController.stream;

  bool offlineContent = false;

  SearchResultBloc() {
    _searchEventStream.listen((searchWord) async {
      try {
        var resultsToBeDisplayed = await _fetchResults(searchWord);
        _searchResultSink.add(resultsToBeDisplayed);
      } on Exception catch (e) {
        print(e.toString);
        _searchResultSink.addError("Something went wrong. Try again later");
      }
    });
  }

  void dispose() {
    _stateStreamController.close();
    _eventStreamController.close();
  }

  Future<List<SearchResult>> _fetchResults(String searchWord) async {
    if (await checkInternetConnectivity()) {
      offlineContent = false;
      return _fetchResultsInternet(searchWord);
    } else {
      offlineContent = true;
      return _fetchResultsCache(searchWord);
    }
  }

  Future<List<SearchResult>> _fetchResultsCache(String searchWord) async {
    List<SearchResult> results = [];

    if (searchWord.isNotEmpty) {
      var prefs = await SharedPreferences.getInstance();
      Set<String> keys = prefs.getKeys();

      for (String key in keys) {
        if (key.toLowerCase().contains(searchWord.toLowerCase())) {
          List<String> values = prefs.getStringList(key);

          SearchResult current = SearchResult();

          current.title = key;
          current.description = values[0];
          current.thumbnail = values[1];
          current.pageid = int.parse(values[2]);
          results.add(current);
        }
      }
    }
    return results;
  }

  Future<List<SearchResult>> _fetchResultsInternet(String searchWord) async {
    List<SearchResult> results = [];

    String apiUrl =
        'https://en.wikipedia.org/w/api.php?action=query&format=json&prop=pageimages|pageterms&generator=prefixsearch&redirects=1&formatversion=2&piprop=thumbnail&pithumbsize=50&pilimit=10&wbptterms=description&gpssearch=$searchWord&gpslimit=10';

    var result = await http.get(apiUrl);
    var jsonResponse = convert.jsonDecode(result.body);
    List searchResultsList =
        (jsonResponse["query"] != null) ? jsonResponse["query"]["pages"] : [];
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
      results.add(current);
    }

    return results;
  }
}
