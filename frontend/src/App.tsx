import React, { useEffect, useState, ChangeEvent } from 'react';
import { Loader } from '@googlemaps/js-api-loader';

interface Vehicle {
  latitude: number;
  longitude: number;
  vehicle_identifier: string;
  sent_at: string;
  id: number;
}

const randomTruck = (): string => {
  const truck = ['/container-truck.png', '/delivery-truck.png', '/free-delivery-truck.png', '/standard-truck.png']
  return truck[Math.round(Math.random() * (3 - 0) + 0)];
}

const App: React.FC = () => {
  const [vehicles, setVehicles] = useState<Vehicle[]>([]);
  const [selectedVehicles, setSelectedVehicles] = useState<Vehicle[]>([]);
  const [loading, setLoading] = useState(false);
  const [map, setMap] = useState<google.maps.Map | null>(null);
  const [markers, setMarkers] = useState<google.maps.Marker[]>([]);

  const loadVehicles = () => {
    if (loading) return; // Evita peticiones si ya hay una en curso
    setLoading(true);
    fetch(`${process.env.BACKEND_BASE_URL}/api/v1/latest_waypoints`)
      .then((response) => response.json())
      .then((data) => {
        setVehicles(data);
      })
      .finally(() => setLoading(false)); // Restablece el estado al final
  };

  useEffect(() => {
    const loader = new Loader({
      apiKey: process.env.GOOGLE_MAPS_API_KEY || "",
      version: "weekly",
    });

    loader.load().then(() => {
      const mapInstance = new google.maps.Map(document.getElementById("map") as HTMLElement, {
        center: { lat: -33.45112270754665, lng: -70.69075584411621 },
        zoom: 13,
      });
      setMap(mapInstance); // Guarda la instancia del mapa en el estado
    });

    loadVehicles(); // Cargar los vehículos cuando el mapa está listo
  }, []);

  useEffect(() => {
    if (map) {
      selectedVehicles.forEach(vehicle => {
        const marker = new google.maps.Marker({
          position: { lat: vehicle.latitude, lng: vehicle.longitude },
          title: vehicle.vehicle_identifier,
          icon: {url: `${randomTruck()}` }
        });
        
        let content = '<div> <h3 style="font-weight: bold; color: #404040">Vehicle: ' + vehicle.vehicle_identifier + '</h3>'
        content +=  '<p style="font-weight: bold; color: #404040"> Latitude: ' + vehicle.latitude + ', Longitude: ' +vehicle.longitude + '</p></div>'
        content +=  '<p style="font-weight: bold; color: #404040"> GPS measurement sent at: ' + vehicle.sent_at + '</p></div>'
  
        
        const infowindow = new google.maps.InfoWindow({
          content: content
        });
  
        google.maps.event.addListener(marker, 'click', function() {
          infowindow.open(map, marker);
        });

      }); 

    }
  }, [selectedVehicles, map]); 


  const handleMenuOnChange = (e: ChangeEvent<HTMLSelectElement>) => { // <----- here we assign event to ChangeEvent
    
    if (map) {
      if(markers.length > 0) {
        markers.forEach(marker => {
          marker.setMap(null);
        })
      }
      
      const currSelectedVehicles = vehicles.filter(v => v.vehicle_identifier === e.target.value)
      const arrMarkers = new Array<google.maps.Marker>()
      currSelectedVehicles.forEach(vehicle => {
        const marker = new google.maps.Marker({
          position: { lat: vehicle.latitude, lng: vehicle.longitude },
          title: vehicle.vehicle_identifier,
          map,
          icon: {url: `${randomTruck()}` }
        });
        
        let content = '<div> <h3 style="font-weight: bold; color: #404040">Vehicle: ' + vehicle.vehicle_identifier + '</h3>'
        content +=  '<p style="font-weight: bold; color: #404040"> Latitude: ' + vehicle.latitude + ', Longitude: ' +vehicle.longitude + '</p></div>'
        content +=  '<p style="font-weight: bold; color: #404040"> GPS measurement sent at: ' + vehicle.sent_at + '</p></div>'
  
        
        const infowindow = new google.maps.InfoWindow({
          content: content
        });
  
        google.maps.event.addListener(marker, 'click', function() {
          infowindow.open(map, marker);
        });
        arrMarkers.push(marker);
      });
      setSelectedVehicles(currSelectedVehicles);
      arrMarkers.forEach(m => m.setMap(map))
      setMarkers(arrMarkers);
    }
  };

  return (
    <div style={{ width: "100%"}}>
      <label htmlFor="vehicles">Vehicles: </label>
      <select id="vehicles" onChange={handleMenuOnChange} defaultValue="0">
        {
          [{id: 0, vehicle_identifier: "Not selected"},...vehicles].map((item) => {
            return(
              <option key={item.id}>{item.vehicle_identifier}</option>
            )
          })

        }
      </select>
      <button onClick={loadVehicles} disabled={loading}>
        {loading ? "Loading..." : "Refresh"}
      </button>
      <div id="map" style={{height: "100%", width: "1024px", minHeight:"700px"}}></div>
    </div>
  );
};

export default App;
