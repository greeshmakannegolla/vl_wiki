import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wiki/Model.dart';
import 'package:wiki/Utils.dart';

class WikiWebView extends StatefulWidget {
  WikiWebView(this.searchResult);

  final SearchResult searchResult;

  @override
  _WikiWebViewState createState() => new _WikiWebViewState();
}

class _WikiWebViewState extends State<WikiWebView> {
  InAppWebViewController _webView;
  double _progress = 0;
  String _url;
  bool _offlineContent = false;

  @override
  void initState() {
    super.initState();
    _prepareURL();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _prepareURL() {
    checkInternetConnectivity().then((internetActive) async {
      _url =
          'https://en.m.wikipedia.org/?curid=${widget.searchResult.pageid.toString()}';
      if (!internetActive) {
        bool cacheExists = await File(
                "/storage/emulated/0/Android/data/com.example.wiki/files/${widget.searchResult.pageid.toString()}.mht")
            .exists();
        if (cacheExists) {
          _url =
              "file:///storage/emulated/0/Android/data/com.example.wiki/files/${widget.searchResult.pageid.toString()}.mht";
          _offlineContent = true;
        } else {
          await showAlert(context, "Oops!",
              Text("No Internet and no offline content available"));
          Navigator.pop(context);
        }
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black, //Color(0xffc0c0c0),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.white,
      body: _url == null
          ? Center(child: CircularProgressIndicator())
          : Column(children: <Widget>[
              _progress < 1.0
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: LinearProgressIndicator(value: _progress),
                    )
                  : _offlineContent
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "No internet, trying offline content",
                            style: TextStyle(color: Colors.red),
                          ),
                        )
                      : Container(),
              Expanded(
                child: InAppWebView(
                  initialUrl: _url,
                  initialHeaders: {},
                  initialOptions: InAppWebViewGroupOptions(
                      crossPlatform: InAppWebViewOptions(
                    debuggingEnabled: true,
                  )),
                  onWebViewCreated: (InAppWebViewController controller) async {
                    _webView = controller;
                  },
                  onLoadStop:
                      (InAppWebViewController controller, String url) async {
                    String directory;
                    if (Platform.isAndroid &&
                        await checkInternetConnectivity()) {
                      directory = (await getExternalStorageDirectory()).path;
                      await _webView.android.saveWebArchive(
                          basename:
                              '$directory/${widget.searchResult.pageid.toString()}.mht',
                          autoname: false);

                      var prefs = await SharedPreferences.getInstance();
                      prefs.setStringList(widget.searchResult.title, [
                        widget.searchResult.description,
                        widget.searchResult.thumbnail,
                        widget.searchResult.pageid.toString(),
                      ]);
                    }
                  },
                  onProgressChanged:
                      (InAppWebViewController controller, int progress) async {
                    setState(() {
                      this._progress = progress / 100;
                    });
                  },
                ),
              ),
              ButtonBar(
                alignment: MainAxisAlignment.center,
                children: <Widget>[
                  RaisedButton(
                    child: Icon(Icons.arrow_back),
                    onPressed: () {
                      if (_webView != null) {
                        _webView.goBack();
                      }
                    },
                  ),
                  RaisedButton(
                    child: Icon(Icons.arrow_forward),
                    onPressed: () {
                      if (_webView != null) {
                        _webView.goForward();
                      }
                    },
                  ),
                  RaisedButton(
                    child: Icon(Icons.refresh),
                    onPressed: () {
                      if (_webView != null) {
                        _webView.reload();
                      }
                    },
                  ),
                ],
              ),
            ]),
    );
  }
}
