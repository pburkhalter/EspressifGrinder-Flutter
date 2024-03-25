
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wheel_slider/wheel_slider.dart';

import '../widgets/description.dart';
import '../widgets/title.dart';


class DevicePage extends ConsumerStatefulWidget {

  const DevicePage({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DevicePageState();
}


class _DevicePageState extends ConsumerState<DevicePage> {
  double _currentValueSingle = 0.0;
  double _currentValueDouble = 0.0;
  int _totalCount = 400;
  double _initValueSingle = 7.5;
  double _initValueDouble = 15.0;

  @override
  void initState() {
    super.initState();
    _currentValueSingle = _initValueSingle;
    _currentValueDouble = _initValueDouble;
  }

  @override
  Widget build(BuildContext context) {

    final Widget illustration = SvgPicture.asset(
      'assets/images/coffee_grinder.svg',
      width: 200,
      height: 200,
    );

    return Scaffold(
      backgroundColor: Color(0xFFFEFAFE),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 55),
            CircleAvatar(
              radius: 100,
              backgroundColor: Color(0xF8F8F8),
              child: Padding(child: illustration, padding: EdgeInsets.all(20)),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const TitleText(text: "Macap M2D", padding: 16),
                    Card(
                        shadowColor: Color(0xFFFFFF),
                        color: Color(0xF8F8F8),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          child: Column(

                            children: [
                              const DescriptionText(text: "Single Grind Duration"),
                              // If you need a separate value for double grind, introduce another state variable like _currentValueDouble.
                              WheelSlider(
                                interval: 0.5,
                                totalCount: _totalCount,
                                initValue: _initValueSingle,
                                isVibrate: false,
                                onValueChanged: (val) {
                                  setState(() {
                                    _currentValueSingle = val;
                                  });
                                },
                              ),
                              Text("${_currentValueSingle} s"),
                            ],
                          ),
                        )

                    ),
                    const SizedBox(height: 25),
                    Card(
                      shadowColor: Color(0xFFFFFF),
                      color: Color(0xF8F8F8),
                      child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          child: Column(

                            children: [
                              const DescriptionText(text: "Double Grind Duration"),
                              // If you need a separate value for double grind, introduce another state variable like _currentValueDouble.
                              WheelSlider(
                                interval: 0.5,
                                totalCount: _totalCount,
                                initValue: _initValueDouble,
                                isVibrate: false,
                                onValueChanged: (val) {
                                  setState(() {
                                    _currentValueDouble = val;
                                  });
                                },
                              ),
                              Text("${_currentValueDouble} s"),
                            ],
                          ),
                      )

                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}