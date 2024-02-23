import 'package:espressif_grinder_flutter/views/firstrun/wifi.dart';
import 'package:flutter/material.dart';
import '../../widgets/button.dart';
import 'connect.dart';
import 'instructions.dart';
import 'welcome.dart';
import 'setup.dart';
import 'success.dart';

class FirstrunProcess extends StatefulWidget {
  const FirstrunProcess({Key? key}) : super(key: key);

  @override
  FirstrunProcessState createState() => FirstrunProcessState();
}

class FirstrunProcessState extends State<FirstrunProcess> {
  final PageController _pageController = PageController();
  static const int _numPages = 6;
  int _currentPage = 0;
  String _buttonText = 'Start';
  bool _showButton = true;

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
  }

  void _nextPage() {
    if (_currentPage < _numPages - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
    }
  }

  void _setButtonText(String text) {
      _buttonText = text;
  }

  void _changeButtonVisibility(bool visible) {
    _showButton = visible;
  }

  void _finishFirstrun() {
    // Implement the logic to finish the first run process.
  }

  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 5),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.black : Colors.grey,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: _buildTopNavigation()),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  FirstrunWelcomePage(onNextPressed: _nextPage),
                  FirstrunInstructionsPage(
                      onNextPressed: _nextPage,
                      onButtonTextChange: _setButtonText,
                      onButtonVisibilityChange: _changeButtonVisibility),
                  FirstrunConnectPage(
                      onNextPressed: _nextPage,
                      onButtonTextChange: _setButtonText,
                      onButtonVisibilityChange: _changeButtonVisibility),
                  FirstrunWifiPage(
                      onNextPressed: _nextPage,
                      onButtonTextChange: _setButtonText,
                      onButtonVisibilityChange: _changeButtonVisibility),
                  FirstrunSetupPage(
                      onNextPressed: _nextPage,
                      onButtonVisibilityChange: _changeButtonVisibility,
                  ),
                  FirstrunSuccessPage(
                      onFinishPressed: _finishFirstrun,
                      onButtonTextChange: _setButtonText,
                      onButtonVisibilityChange: _changeButtonVisibility)
                ],
              ),
            ),
            Visibility(
              visible: _showButton,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: CustomElevatedButton(
                  buttonText: _buttonText,
                  onPressed: _nextPage
              ),
            ),

            _buildPageIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopNavigation() {
    return SizedBox(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Visibility(
            visible: _currentPage > 0 && _currentPage != 6,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            child: IconButton(
              onPressed: _previousPage,
              icon: const Icon(Icons.arrow_back, size: 32),
              padding: const EdgeInsets.all(20)
            ),
          ),
          const Text(
            'EspressifGrinder',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 4),
          ),
          Visibility(
            visible: _currentPage < _numPages - 1,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            child: IconButton(
              onPressed: _nextPage,
              icon: const Icon(Icons.arrow_forward, size: 32),
              padding: const EdgeInsets.all(20)
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildPageIndicator() {
    return SizedBox(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_numPages, (index) => _buildIndicator(index == _currentPage)),
      ),
    );
  }
}
