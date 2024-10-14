import 'package:flutter/material.dart';
import 'package:theiotlab/HomePage/CustomWidgets/HumidityWidget.dart';

import 'package:theiotlab/HomePage/CustomWidgets/header.dart';
import 'package:theiotlab/HomePage/CustomWidgets/optionsBoxes.dart';
import 'package:theiotlab/HomePage/CustomWidgets/tempWidget.dart';

import '../INCOMPLETE/DoorLockScreen/doorlock.dart';
import '../EnergyMonitoringScreen/ems.dart';
import '../INCOMPLETE/ProjectorScreen/projector.dart';
import '../INCOMPLETE/SmartAccessScreen/smartAccess.dart';

class MyHomePage extends StatefulWidget {
  final String username;
  const MyHomePage({super.key, required this.username});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Map<String, dynamic>> optionsData = [
    {
      "icon": Icons.lightbulb,
      "text": "Energy Monitoring",
      "screen": EnergyMonitoringScreen(),
    },
    {
      "icon": Icons.lock,
      "text": "Doorlock",
      "screen": DoorLockScreen(),
    },
    {
      "icon": Icons.vpn_key,
      "text": "Smart Access",
      "screen": SmartAccessScreen(),
    },
    {
      "icon": Icons.cast,
      "text": "Projector",
      "screen": ProjectorScreen(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              HomeHeader(username: widget.username),
              TempretureWidget(),
              SizedBox(
                height: 10,
              ),
              HumidityWidget(),
              SizedBox(
                height: 10,
              ),
              Expanded(
                  child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 1.0,
                        mainAxisSpacing: 1.0,
                      ),
                      itemCount: optionsData.length,
                      itemBuilder: (context, index) {
                        return Options(
                          text: optionsData[index]["text"],
                          icon: optionsData[index]["icon"],
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        optionsData[index]["screen"]));
                          },
                        );
                      }))
            ],
          ),
        ));
  }
}
