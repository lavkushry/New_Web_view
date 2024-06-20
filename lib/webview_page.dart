// I want to Fetch User location form Location package and show it on the MapKit JS WebView.
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

class WebViewPage extends StatefulWidget {
  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late WebViewController _controller;
  double _zoomLevel = 0.1;
  late Location _location;
  LocationData? _currentLocation;

  @override
  void initState() {
    super.initState();
    _location = Location();
    _initializeLocation();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {},
          onPageStarted: (String url) {},
          onPageFinished: (String url) {
            // Once the page is loaded, update the map with the current location
            if (_currentLocation != null) {
              _updateMapWithLocation(_currentLocation!);
            }
          },
          onHttpError: (HttpResponseError error) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );
    _loadHtmlFromAssets();
  }

  _loadHtmlFromAssets() async {
    String fileHtmlContents = await rootBundle.loadString('assets/html/mapkit.html');
    _controller.loadRequest(
      Uri.dataFromString(fileHtmlContents,
          mimeType: 'text/html', encoding: Encoding.getByName('utf-8')),
    );
  }

  void _zoomIn() {
    setState(() {
      _zoomLevel = (_zoomLevel - 0.01).clamp(0.01, 1.0);
      _controller.runJavaScript('setZoomLevel($_zoomLevel);');
    });
  }

  void _zoomOut() {
    setState(() {
      _zoomLevel = (_zoomLevel + 0.01).clamp(0.01, 1.0);
      _controller.runJavaScript('setZoomLevel($_zoomLevel);');
    });
  }

  Future<void> _initializeLocation() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _currentLocation = await _location.getLocation();
    if (_currentLocation != null) {
      // Once location is fetched, update the map
      _updateMapWithLocation(_currentLocation!);
    }
  }

  void _updateMapWithLocation(LocationData locationData) {
    _controller.runJavaScript(
        'updateMapLocation(${locationData.latitude}, ${locationData.longitude});'
    );
  }

  void _fetchCurrentLocation() async {
    await _initializeLocation();
    if (_currentLocation != null) {
      _updateMapWithLocation(_currentLocation!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MapKit JS WebView'),
        actions: [
          IconButton(
            icon: Icon(Icons.zoom_in),
            onPressed: _zoomIn,
          ),
          IconButton(
            icon: Icon(Icons.zoom_out),
            onPressed: _zoomOut,
          ),
        ],
      ),
      body: WebViewWidget(controller: _controller),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchCurrentLocation,
        child: Icon(Icons.location_searching),
      ),
    );
  }
}
