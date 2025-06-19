class MapView {
  // positionsJson: 마커 위치 및 정보 JSON 문자열
  // lat, lng: 현재 위치 위도, 경도 (시작 위치로 사용)
  static String buildHtml(String positionsJson, double lat, double lng) => '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>네이버 지도</title>
  <script type="text/javascript" src="https://oapi.map.naver.com/openapi/v3/maps.js?ncpKeyId=oytgb4kt0a"></script>
  <style>
    html, body, #map {
      margin: 0; padding: 0; width: 100%; height: 100%; overflow: hidden;
    }
  </style>
</head>
<body>
  <div id="map"></div>
  <script>
    (function() {
      var map = new naver.maps.Map('map', {
        center: new naver.maps.LatLng($lat, $lng),
        level: 10
      });

      var zoomControl = new naver.maps.ZoomControl();
      map.addControl(zoomControl, naver.maps.Position.TOP_RIGHT);

      var positions = JSON.parse('$positionsJson');
      var infowindow = null;

      positions.forEach(function(pos) {
        var marker = new naver.maps.Marker({
          position: new naver.maps.LatLng(pos.lat, pos.lng),
          map: map,
          title: pos.title
        });

        marker.addListener('click', function() {
          if (infowindow) {
            infowindow.close();
          }
          infowindow = new naver.maps.InfoWindow({
            content: '<div style="padding:5px;">' + pos.title + '</div>'
          });
          infowindow.open(map, marker);
        });
      });
    })();
  </script>
</body>
</html>
''';
}
