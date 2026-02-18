import 'dart:async';
import 'dart:developer' as dev show log;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_dragmarker/flutter_map_dragmarker.dart';
import 'package:handover_simulator/latlang_extension.dart';
import 'package:handover_simulator/typedefs.dart';
import 'package:latlong2/latlong.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int tttInMs = 0;
  double hom = 0;

  late TextEditingController homController;
  late TextEditingController tttController;

  static LatLng homePos = LatLng(51.509364, -0.128928);
  LatLng cell1Pos = homePos;
  LatLng cell2Pos = homePos;
  LatLng userPos = homePos;

  double rsrpCell1 = 0;
  double rsrpCell2 = 0;

  double userCell1Cell2RSRPDiff = 0;

  int connectedCellId = 1;

  final double iconSize = 50;

  bool tttStarted = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((t) {
      homController = TextEditingController(text: hom.toString());
      tttController = TextEditingController(text: tttInMs.toString());

      final double shiftRadius = 2e-4;
      userPos = homePos;
      cell1Pos = homePos.add(toLat: shiftRadius, toLong: shiftRadius);
      cell2Pos = homePos.add(toLat: -2 * shiftRadius, toLong: -2 * shiftRadius);
      connectedCellId = userPos.distance(cell1Pos) < userPos.distance(cell2Pos)
          ? 1
          : 2;
      setState(() {
        checkHandover();
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    homController.dispose();
    tttController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text("Settings"),
                  content: Column(
                    mainAxisSize: .min,
                    children: [
                      TextField(
                        controller: homController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hint: Text("HOM"),
                          label: Text("HOM"),
                        ),
                      ),
                      TextField(
                        controller: tttController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hint: Text("TTT (ms)"),
                          label: Text("TTT (ms)"),
                        ),
                      ),

                      Row(
                        mainAxisAlignment: .spaceAround,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();

                              tttController.text = tttInMs.toString();
                              homController.text = hom.toString();
                            },
                            child: const Text("Cancel"),
                          ),

                          TextButton(
                            onPressed: () {
                              final double? inputHome = double.tryParse(
                                homController.text,
                              );
                              final int? inputttt = int.tryParse(
                                tttController.text,
                              );
                              setState(() {
                                hom = inputHome ?? hom;
                                tttInMs = inputttt ?? tttInMs;
                              });
                              Navigator.of(context).pop();
                              tttController.text = tttInMs.toString();
                              homController.text = hom.toString();
                            },
                            child: const Text("OK"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
            child: Icon(Icons.settings),
          ),
          body: Stack(
            children: [
              FlutterMap(
                options: MapOptions(initialCenter: homePos, initialZoom: 18),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: "com.example.handover_simulator",
                  ),

                  DragMarkers(
                    markers: [
                      DragMarker(
                        point: userPos,
                        builder: (context, pos, isDragging) =>
                            Icon(Icons.person, size: iconSize),
                        size: Size.square(iconSize),
                        onDragUpdate: (details, latLng) {
                          setState(() {
                            userPos = latLng;
                            dev.log("userPos: $userPos");
                            checkHandover();
                          });
                        },
                      ),

                      DragMarker(
                        point: cell1Pos,
                        builder: (context, pos, isDragging) => Icon(
                          Icons.cell_tower,
                          color: Colors.blue,
                          size: iconSize,
                        ),
                        size: Size.square(iconSize),
                        onDragUpdate: (details, latLng) {
                          setState(() {
                            cell1Pos = latLng;
                            dev.log("cell1Pos: $cell1Pos");
                            checkHandover();
                          });
                        },
                      ),

                      DragMarker(
                        point: cell2Pos,
                        builder: (context, pos, isDragging) => Icon(
                          Icons.cell_tower,
                          color: Colors.blue,
                          size: iconSize,
                        ),
                        size: Size.square(iconSize),
                        onDragUpdate: (details, latLng) {
                          setState(() {
                            cell2Pos = latLng;
                            dev.log("cell2Pos: $cell2Pos");
                            checkHandover();
                          });
                        },
                      ),
                    ],
                  ),
                  PolylineLayer(
                    polylines: <Polyline>[
                      // tower 1
                      Polyline(
                        points: [userPos, cell1Pos],
                        strokeWidth: 3,
                        color: connectedCellId == 1 ? Colors.green : Colors.red,
                      ),
                      // tower 2
                      Polyline(
                        points: [userPos, cell2Pos],
                        strokeWidth: 3,
                        color: connectedCellId == 2 ? Colors.green : Colors.red,
                      ),
                    ],
                  ),
                ],
              ),

              Container(
                width: MediaQuery.sizeOf(context).width,

                color: Colors.white,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("TOWER: $connectedCellId"),
                    Text("RSRP TOWER 1: $rsrpCell1"),
                    Text("RSRP $rsrpCell2"),
                    Text(
                      "User - Cell 1 RSRP - Cell 2 RSRP Diff: $userCell1Cell2RSRPDiff",
                    ),
                    Text("TTT MOVING: $tttStarted"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> checkConditionForTime({
    required Duration duration,
    required TTTCallback tttCallback,
  }) async {
    Completer<bool> completer = Completer<bool>();

    const Duration checkDuration = Duration(milliseconds: 100);

    int timeBuffer = 0;
    Timer.periodic(checkDuration, (timer) {
      if (timeBuffer >= duration.inMilliseconds) {
        // reached TTT
        timer.cancel();
        completer.complete(tttCallback.call());
        return;
      } else {
        final bool pass = tttCallback.call();
        if (!pass) {
          timer.cancel();
          completer.complete(false);
          return;
        }
      }
      timeBuffer += checkDuration.inMilliseconds;
    });

    return await completer.future;
  }

  void checkHandover() {
    rsrpCell1 = getSSR(userPos: userPos, cellPos: cell1Pos);
    rsrpCell2 = getSSR(userPos: userPos, cellPos: cell2Pos);

    userCell1Cell2RSRPDiff = (rsrpCell1 - rsrpCell2).abs();
    final bool homSat = userCell1Cell2RSRPDiff >= hom;

    bool shouldStartTTT =
        (rsrpCell1 < rsrpCell2 && connectedCellId == 2 && homSat) ||
        (rsrpCell2 < rsrpCell1 && connectedCellId == 1 && homSat);
    if (shouldStartTTT) {
      tttStarted = true;
      tttCheck();
    }
  }

  Future<void> tttCheck() async {
    final Duration ttt = Duration(milliseconds: tttInMs);
    final bool cell1Optimal = await checkConditionForTime(
      duration: ttt,
      tttCallback: () {
        final cell1SSR = getSSR(userPos: userPos, cellPos: cell1Pos);
        final cell2SSR = getSSR(userPos: userPos, cellPos: cell2Pos);
        return cell1SSR < cell2SSR;
      },
    );

    final bool cell2Optimal = await checkConditionForTime(
      duration: ttt,
      tttCallback: () {
        final cell1SSR = getSSR(userPos: userPos, cellPos: cell1Pos);
        final cell2SSR = getSSR(userPos: userPos, cellPos: cell2Pos);
        return cell1SSR > cell2SSR;
      },
    );

    if (cell1Optimal && connectedCellId != 1) {
      setState(() {
        connectedCellId = 1;
      });
    }
    if (cell2Optimal && connectedCellId != 2) {
      setState(() {
        connectedCellId = 2;
      });
    }
    tttStarted = false;
  }

  double getSSR({required LatLng userPos, required LatLng cellPos}) {
    // distance = SSR (for now)
    return cellPos.distance(userPos);
  }
}
