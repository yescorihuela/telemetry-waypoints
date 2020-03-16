function getRandomTruck() {
  var truck = ['/camion-contenedor.png', '/camion-de-reparto.png', 'camion.png', 'entrega-gratis.png']
  return truck[Math.round(Math.random() * (3 - 0) + 0)];
}

function initMap() {
  map = new google.maps.Map(document.getElementById('map'), {
    center: {lat: -33.45112270754665, lng: -70.69075584411621},
    zoom: 13
  });

  $.getJSON('/api/v1/latest_waypoints', function(data){

    data.forEach(function(waypoint){
      var marker = new google.maps.Marker({
        position: {lat: parseFloat(waypoint.latitude), lng: parseFloat(waypoint.longitude)},
        map: map,
        title: waypoint.vehicle_identifier,
        icon: { url: getRandomTruck() }
      });
      content = '<div> <h3 style="font-weight: bold; color: #404040">Vehicle: ' + waypoint.vehicle_identifier + '</h3>'
      content +=  '<p style="font-weight: bold; color: #404040"> Latitude: ' + waypoint.latitude + ', Longitude: ' +waypoint.longitude + '</p></div>'
      content +=  '<p style="font-weight: bold; color: #404040"> GPS measurement sent at: ' + waypoint.sent_at + '</p></div>'


      var infowindow = new google.maps.InfoWindow({
        content: content
      });

        google.maps.event.addListener(marker, 'click', function() {
          infowindow.open(map, marker);
        });      
    })
  })
  google.maps.event.addDomListener(window, 'load', initialize);
}
