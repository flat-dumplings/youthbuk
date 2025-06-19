class MapView {
  // positionsJson: 마커 위치 및 정보 JSON 문자열
  // lat, lng: 현재 위치 위도, 경도 (시작 위치로 사용)
  static String buildHtml(String positionsJson, double lat, double lng) => '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <script src="https://dapi.kakao.com/v2/maps/sdk.js?appkey=a950dedd7f25a1df5390cdff6f17652b&autoload=false"></script>
  <style>
    html, body, #map {
      margin: 0; padding: 0; width: 100%; height: 100%; overflow: hidden;
    }
  </style>
</head>
<body>
  <div id="map"></div>
  <script>
    kakao.maps.load(function() {
      var container = document.getElementById('map');
      var options = {
        center: new kakao.maps.LatLng($lat, $lng), // Flutter에서 전달받은 현재 위치 사용
        level: 3
      };
      var map = new kakao.maps.Map(container, options);

      var zoomControl = new kakao.maps.ZoomControl();
      map.addControl(zoomControl, kakao.maps.ControlPosition.RIGHT);

      var positions = $positionsJson;

      for(var i=0; i<positions.length; i++) {
        var marker = new kakao.maps.Marker({
          map: map,
          position: new kakao.maps.LatLng(positions[i].lat, positions[i].lng)
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
}
