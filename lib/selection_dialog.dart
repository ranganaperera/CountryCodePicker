import 'package:country_code_picker/country_code.dart';
import 'package:flutter/material.dart';

/// selection dialog used for selection of the country code
class SelectionDialog extends StatefulWidget {
  final List<CountryCode> elements;
  final bool showCountryOnly;
  final InputDecoration searchDecoration;
  final TextStyle searchStyle;
  final WidgetBuilder emptySearchBuilder;
  final bool showFlag;
  final Color backgroundColor;
  final Color searchIconColor;
  final TextStyle textStyle;

  /// elements passed as favorite
  final List<CountryCode> favoriteElements;

  SelectionDialog(this.elements, this.favoriteElements, {
    Key key,
    this.showCountryOnly,
    this.emptySearchBuilder,
    InputDecoration searchDecoration = const InputDecoration(),
    this.searchStyle,
    this.showFlag,
    this.backgroundColor,
    this.searchIconColor,
    this.textStyle,
  }) :
    assert(searchDecoration != null, 'searchDecoration must not be null!'),
    this.searchDecoration = searchDecoration.copyWith(prefixIcon: Icon(Icons.search, color: searchIconColor ?? Colors.black,)),
    super(key: key);

  @override
  State<StatefulWidget> createState() => _SelectionDialogState();
}

class _SelectionDialogState extends State<SelectionDialog> {
  /// this is useful for filtering purpose
  List<CountryCode> filteredElements;

  @override
  Widget build(BuildContext context) => SimpleDialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0)
    ),
    backgroundColor: widget.backgroundColor?? Theme.of(context).backgroundColor,
    title: TextField(
      style: widget.searchStyle,
      decoration: widget.searchDecoration,
      onChanged: _filterElements,
    ),
    children: [
      Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height / 4,
        child: ListView(
          children: [
            widget.favoriteElements.isEmpty
                ? const DecoratedBox(decoration: BoxDecoration())
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[]
                      ..addAll(widget.favoriteElements
                          .map(
                            (f) => SimpleDialogOption(
                                  child: _buildOption(f),
                                  onPressed: () {
                                    _selectItem(f);
                                  },
                                ),
                          )
                          .toList())
                      ..add(const Divider())),
          ]..addAll(filteredElements.isEmpty
              ? [_buildEmptySearchWidget(context)]
              : filteredElements.map(
                  (e) => SimpleDialogOption(
                    key: Key(e.toLongString()),
                    child: _buildOption(e),
                    onPressed: () {
                      _selectItem(e);
                    },
                  )))
          )
        ),
      ],
    );

  Widget _buildOption(CountryCode e) {
    return Container(
      width: 400,
      child: Flex(
        direction: Axis.horizontal,
        children: <Widget>[
          widget.showFlag ? Flexible(
            child: Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: Image.asset(
                e.flagUri,
                package: 'country_code_picker',
                width: 32.0,
              ),
            ),
          ) : Container(),
          Expanded(
            flex: 4,
            child: Text(
              widget.showCountryOnly
                  ? e.toCountryStringOnly()
                  : e.toLongString(),
              overflow: TextOverflow.fade,
              style: widget.textStyle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySearchWidget(BuildContext context) {
    if (widget.emptySearchBuilder != null) {
      return widget.emptySearchBuilder(context);
    }

    return Center(child: Text('No Country Found', style: widget.textStyle,));
  }

  @override
  void initState() {
    filteredElements = widget.elements;
    super.initState();
  }

  void _filterElements(String s) {
    s = s.toUpperCase();
    setState(() {
      filteredElements = widget.elements
          .where((e) =>
              e.code.contains(s) ||
              e.dialCode.contains(s) ||
              e.name.toUpperCase().contains(s))
          .toList();
    });
  }

  void _selectItem(CountryCode e) {
    Navigator.pop(context, e);
  }
}
