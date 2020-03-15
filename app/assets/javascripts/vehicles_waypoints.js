function initMap() {
  map = new google.maps.Map(document.getElementById('map'), {
    center: {lat: -33.45112270754665, lng: -70.69075584411621},
    zoom: 10
  });
  $.getJSON('/api/v1/latest_waypoints', function(data){
    data.forEach(function(waypoint){
      var marker = new google.maps.Marker({
        position: {lat: parseFloat(waypoint.latitude), lng: parseFloat(waypoint.longitude)},
        map: map,
        title: waypoint.vehicle_identifier
      });
    })
  })

}
