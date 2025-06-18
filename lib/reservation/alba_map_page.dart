import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AlbaMapPage extends StatefulWidget {
  const AlbaMapPage({super.key});

  @override
  State<AlbaMapPage> createState() => _AlbaMapPageState();
}

class _AlbaMapPageState extends State<AlbaMapPage> {
  late WebViewController _controller;
  List<Map<String, dynamic>> positions = [];

  @override
  void initState() {
    super.initState();
    _loadPositions();
  }

  Future<void> _loadPositions() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('Villages').get();

    final List<Map<String, dynamic>> tempPositions = [];

    for (var doc in snapshot.docs) {
      final data = doc.data();

      double? lat;
      double? lng;

      if (data['location'] is GeoPoint) {
        final geo = data['location'] as GeoPoint;
        lat = geo.latitude;
        lng = geo.longitude;
      } else if (data['위도'] != null && data['경도'] != null) {
        lat = (data['위도'] as num).toDouble();
        lng = (data['경도'] as num).toDouble();
      } else {
        continue;
      }

      tempPositions.add({
        'title': data['체험마을명'] ?? doc.id,
        'lat': lat,
        'lng': lng,
      });
    }

    setState(() {
      positions = tempPositions;
      _loadWebView();
    });
  }

  void _loadWebView() {
    final positionsJson = positions
        .map(
          (pos) => '''
      {title: "${pos['title']}", latlng: new kakao.maps.LatLng(${pos['lat']}, ${pos['lng']})}
    ''',
        )
        .join(',');

    final htmlString = '''
    <!DOCTYPE html>
    <html>
    <head>
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <script type="text/javascript" src="https://dapi.kakao.com/v2/maps/sdk.js?appkey=a950dedd7f25a1df5390cdff6f17652b&autoload=false"></script>
      <style> html, body, #map { margin:0; padding:0; width:100%; height:100%; overflow:hidden; } </style>
    </head>
    <body>
      <div id="map" style="width:100%; height:100%;"></div>
      <script>
        kakao.maps.load(function() {
          var container = document.getElementById('map');
          var options = { 
            center: new kakao.maps.LatLng(37.5665, 126.9780),
            level: 3
          };
          var map = new kakao.maps.Map(container, options);

          var positions = [$positionsJson];

          for(var i=0; i<positions.length; i++) {
            var marker = new kakao.maps.Marker({
              map: map,
              position: positions[i].latlng
            });

            var infowindow = new kakao.maps.InfoWindow({
              content: '<div style="padding:5px;">' + positions[i].title + '</div>'
            });

            kakao.maps.event.addListener(marker, 'click', (function(marker, infowindow) {
              return function() {
                infowindow.open(map, marker);
              };
            })(marker, infowindow));
          }
        });
      </script>
    </body>
    </html>
    ''';

    _controller.loadHtmlString(htmlString);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('알바 지도 - 카카오 (Firestore)')),
      body: WebViewWidget(
        controller:
            (_controller =
                WebViewController()
                  ..setJavaScriptMode(JavaScriptMode.unrestricted)),
      ),
    );
  }
}
