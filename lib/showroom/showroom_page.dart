// ignore_for_file:  avoid_print, deprecated_member_use, unnecessary_cast

import 'package:carousel_slider/carousel_slider.dart';
import 'package:experi/showroom/showroom_logic.dart';
import 'package:flutter/material.dart';
import 'package:experi/model.dart';

class Showroom extends StatefulWidget {
  const Showroom({Key? key}) : super(key: key);

  @override
  _Showroom createState() => _Showroom();
}

class _Showroom extends State<Showroom> {
  final showroomObj = ShowroomLogic();
  @override
  Widget build(BuildContext context) {
    Model.contextQueue.addLast(context);
    Model.currentContext = context;
    print('in');
    Model.currentRoute = "Showroom";
    Model.prefs.setString("currentRoute", "Showroom");

    if (showroomObj.refreshed == false) {
      showroomObj.showroomPics = ShowroomLogic.pictures;
    }
    print('done');

    if (showroomObj.showroomPics.isNotEmpty) {
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
                  padding: const EdgeInsets.only(left: 8),
                  color: Colors.black,
                  icon: const Icon(Icons.arrow_back))
              : null,
          title: Column(
            children: const [
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
            showroomObj.addPic();
          },
          child: const Icon(Icons.add),
        ),
        body: Container(
          padding: const EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: Column(
              children: [
                CarouselSlider(
                  items: (showroomObj.showroomPics.isNotEmpty)
                      ? showroomObj.showroomPics
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
                        showroomObj.currentPosition = value as int;
                        print(showroomObj.currentPosition);
                      },
                      enableInfiniteScroll: false),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        print('calling deletePic');
                        showroomObj.deletePic((showroomObj.showroomPics[
                                showroomObj.currentPosition as int][0])
                            .toString());
                      },
                      icon: const Icon(Icons.delete),
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
                  padding: const EdgeInsets.only(left: 8),
                  color: Colors.black,
                  icon: const Icon(Icons.arrow_back))
              : null,
          title: Column(
            children: const [
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
            showroomObj.addPic();
          },
          child: const Icon(Icons.add),
        ),
        body: const Text(''),
      );
    }
  }
}
