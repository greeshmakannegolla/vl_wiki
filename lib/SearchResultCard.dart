import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:wiki/Model.dart';
import 'package:wiki/WikiWebView.dart';

class SearchResultCard extends StatelessWidget {
  SearchResultCard(this._searchResult);
  final SearchResult _searchResult; //Instance of model

  @override
  Widget build(BuildContext context) {
    Widget cardBody = Row(
      children: [
        _searchResult.thumbnail.isEmpty
            ? Image.asset("images/no_image.png", width: 50)
            : CachedNetworkImage(
                imageUrl: _searchResult
                    .thumbnail, //Using CachedNetworkImage plugin to display offline image
                width: 50,
              ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(5, 8, 0, 5),
                  child: Text(
                    _searchResult.title,
                    style: TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(5, 6, 0, 5),
                  child: Text(_searchResult.description),
                )
              ],
            ),
          ),
        ),
      ],
    );
    return InkWell(
      child: cardBody,
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => WikiWebView(_searchResult)));
      },
    );
  }
}
