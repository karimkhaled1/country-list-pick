import 'dart:io';

import 'package:country_list_pick/country_selection_theme.dart';
import 'package:country_list_pick/support/code_country.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'country_list_pick.dart';

class SelectionList extends StatefulWidget {
  SelectionList(this.elements, this.initialSelection, {Key key, this.appBar, this.theme, this.countryBuilder}) : super(key: key);

  final PreferredSizeWidget appBar;
  final List elements;
  final CountryCode initialSelection;
  final CountryTheme theme;
  final Widget Function(BuildContext context, CountryCode) countryBuilder;

  @override
  _SelectionListState createState() => _SelectionListState();
}

class _SelectionListState extends State<SelectionList> {
  List countries;
  final TextEditingController _controller = TextEditingController();
  ScrollController _controllerScroll;
  var diff = 0.0;

  var posSelected = 0;
  var height = 0.0;
  var _sizeheightcontainer;
  var _heightscroller;
  var _text;
  var _oldtext;
  var _itemsizeheight = 50.0;
  double _offsetContainer = 0.0;

  bool isShow = true;

  @override
  void initState() {
    countries = widget.elements;
    countries.sort((a, b) {
      return a.name.toString().compareTo(b.name.toString());
    });
    _controllerScroll = ScrollController();
    //_controller.addListener(_scrollListener);
    super.initState();
  }

  void _sendDataBack(BuildContext context, CountryCode initialSelection) {
    Navigator.pop(context, initialSelection);
  }

  List _alphabet = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarBrightness: Platform.isAndroid ? Brightness.dark : Brightness.light,
    ));
    height = MediaQuery.of(context).size.height;
    return Directionality(
      textDirection: widget.theme?.showEnglishName ?? true ? TextDirection.ltr : TextDirection.rtl,
      child: Scaffold(
        appBar: widget.appBar,
        body: Container(
          color: Color(0xfff4f4f4),
          child: LayoutBuilder(builder: (context, contrainsts) {
            diff = height - contrainsts.biggest.height;
            _heightscroller = (contrainsts.biggest.height) / _alphabet.length;
            _sizeheightcontainer = (contrainsts.biggest.height);
            return Stack(
              children: <Widget>[
                CustomScrollView(
                  controller: _controllerScroll,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Text(widget.theme?.searchText ?? 'SEARCH'),
                          ),
                          Container(
                            color: Colors.white,
                            child: TextField(
                              controller: _controller,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                contentPadding: EdgeInsets.only(left: 15, bottom: 0, top: 0, right: 15),
                                hintText: widget.theme?.searchHintText ?? "Search...",
                              ),
                              onChanged: _filterElements,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Text(widget.theme?.lastPickText ?? 'LAST PICK'),
                          ),
                          Container(
                            color: Colors.white,
                            child: Material(
                              color: Colors.transparent,
                              child: ListTile(
                                leading: Image.asset(
                                  widget.initialSelection.flagUri,
                                  package: 'country_list_pick',
                                  width: 32.0,
                                ),
                                title: Text(widget.theme?.showEnglishName ?? true ? widget.initialSelection.name : widget.initialSelection.nameAr),
                                trailing: Padding(
                                  padding: const EdgeInsets.only(right: 20.0),
                                  child: Icon(Icons.check, color: Colors.green),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 15),
                        ],
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return widget.countryBuilder != null
                            ? widget.countryBuilder(context, countries.elementAt(index))
                            : getListCountry(countries.elementAt(index));
                      }, childCount: countries.length),
                    )
                  ],
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget getListCountry(CountryCode e) {
    return Container(
      height: 50,
      color: Colors.white,
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          leading: Image.asset(
            e.flagUri,
            package: 'country_list_pick',
            width: 30.0,
          ),
          title: Text(widget.theme?.showEnglishName ?? true ? e.name : e.nameAr ?? e.name),
          onTap: () {
            _sendDataBack(context, e);
          },
        ),
      ),
    );
  }

  _getAlphabetItem(int index) {
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            posSelected = index;
            _text = _alphabet[posSelected];
            if (_text != _oldtext) {
              for (var i = 0; i < countries.length; i++) {
                if (_text
                        .toString()
                        .compareTo((widget.theme?.showEnglishName ?? true ? countries[i].name : countries[i].nameAr).toString().toUpperCase()[0]) ==
                    0) {
                  _controllerScroll.jumpTo((i * _itemsizeheight) + 10);
                  break;
                }
              }
              _oldtext = _text;
            }
          });
        },
        child: Container(
          width: 40,
          height: 20,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: index == posSelected ? widget.theme?.alphabetSelectedBackgroundColor ?? Colors.blue : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Text(
            _alphabet[index],
            textAlign: TextAlign.center,
            style: (index == posSelected)
                ? TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: widget.theme?.alphabetSelectedTextColor ?? Colors.white)
                : TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: widget.theme?.alphabetTextColor ?? Colors.black),
          ),
        ),
      ),
    );
  }

  void _filterElements(String s) {
    setState(() {
      countries = widget.elements.where((e) {
        try {
          return e.code.contains(s.toUpperCase()) ||
              e.dialCode.contains(s.toUpperCase()) ||
              e.name.toUpperCase().contains(s.toUpperCase()) ||
              e.nameAr.contains(s);
        } catch (sse) {
          print(e.name);
          print(sse.toString());
          return null;
        }

        //
      }).toList();
      print(countries);
    });
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    setState(() {
      if ((_offsetContainer + details.delta.dy) >= 0 && (_offsetContainer + details.delta.dy) <= (_sizeheightcontainer - _heightscroller)) {
        _offsetContainer += details.delta.dy;
        posSelected = ((_offsetContainer / _heightscroller) % _alphabet.length).round();
        _text = _alphabet[posSelected];
        if (_text != _oldtext) {
          for (var i = 0; i < countries.length; i++) {
            if (_text
                    .toString()
                    .compareTo((widget.theme?.showEnglishName ?? true ? countries[i].name : countries[i].nameAr).toString().toUpperCase()[0]) ==
                0) {
              _controllerScroll.jumpTo((i * _itemsizeheight) + 15);
              break;
            }
          }
          _oldtext = _text;
        }
      }
    });
  }

  void _onVerticalDragStart(DragStartDetails details) {
    _offsetContainer = details.globalPosition.dy - diff;
  }
}
