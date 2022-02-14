// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_key_in_widget_constructors, prefer_const_constructors_in_immutables, no_logic_in_create_state, avoid_print, deprecated_member_use, unnecessary_cast

import 'package:carousel_slider/carousel_slider.dart';
import 'package:experi/showroom/showroom_logic.dart';
import 'package:flutter/material.dart';
import 'package:experi/model.dart';

class Showroom extends StatefulWidget {
  Showroom(this.pictures);
  final List pictures;
  @override
  _Showroom createState() => _Showroom(pictures);
}

class _Showroom extends State<Showroom> {
  _Showroom(this.pictures);
  final List pictures;

  @override
  Widget build(BuildContext context) {
    print('in');
    Model.currentRoute = "Showroom";
    Model.prefs.setString("currentRoute", "Showroom");

    if (refreshed == false) {
      showroomPics = pictures;
    }
    print('done');

    if (showroomPics.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          brightness: Brightness.dark,
          leadingWidth: 15,
          automaticallyImplyLeading: false,
          leading: Navigator.canPop(context)
              ? IconButton(
                  onPressed: () {
                    Navigator.of(context).maybePop();
                  },
                  padding: EdgeInsets.only(left: 8),
                  color: Colors.black,
                  icon: Icon(Icons.arrow_back))
              : null,
          title: Column(
            children: [
              Text(
                "eventGig",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                "Showroom",
                style: TextStyle(fontSize: 12),
              ),
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            print('calling addPic');
            addPic();
          },
          child: Icon(Icons.add),
        ),
        body: Container(
          padding: EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: Column(
              children: [
                CarouselSlider(
                  items: (showroomPics.isNotEmpty)
                      ? showroomPics
                          .map(
                            (pic) => Image.network(
                              Model.domain + 'img/' + pic[1],
                              height: MediaQuery.of(context).size.height * 0.4,
                              width: MediaQuery.of(context).size.width * 0.95,
                            ),
                          )
                          .toList()
                      : [
                          Image.network(
                            Model.domain + 'img/' + 'default.png',
                            height: MediaQuery.of(context).size.height * 0.4,
                            width: MediaQuery.of(context).size.width * 0.95,
                          ),
                        ],
                  options: CarouselOptions(
                      onScrolled: (value) {
                        currentPosition = value as int;
                        print(currentPosition);
                      },
                      enableInfiniteScroll: false),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        print('calling deletePic');
                        deletePic((showroomPics[currentPosition as int][0])
                            .toString());
                      },
                      icon: Icon(Icons.delete),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          brightness: Brightness.dark,
          leadingWidth: 15,
          automaticallyImplyLeading: false,
          leading: Navigator.canPop(context)
              ? IconButton(
                  onPressed: () {
                    Navigator.of(context).maybePop();
                  },
                  padding: EdgeInsets.only(left: 8),
                  color: Colors.black,
                  icon: Icon(Icons.arrow_back))
              : null,
          title: Column(
            children: [
              Text(
                "eventGig",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                "Showroom",
                style: TextStyle(fontSize: 12),
              ),
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            print('calling addPic');
            addPic();
          },
          child: Icon(Icons.add),
        ),
        body: Text(''),
      );
    }
  }
}
