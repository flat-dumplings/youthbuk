class MapView {
  static String buildHtml(String positionsJson) => '''
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
        center: new kakao.maps.LatLng(36.3504, 127.3845),
        level: 3
      };
      var map = new kakao.maps.Map(container, options);

      var zoomControl = new kakao.maps.ZoomControl();
      map.addControl(zoomControl, kakao.maps.ControlPosition.RIGHT);

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
}
