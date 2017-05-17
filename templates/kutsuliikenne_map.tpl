{% extends "base.tpl" %}
{% block head %}    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Kutsujoukkoliikenne</title>
    <link rel="stylesheet" href="{{STATIC_URL}}css/bootstrap.min.css"/>
    <link rel="stylesheet" href="{{STATIC_URL}}css/bootstrap-theme.min.css"/>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.0.1/leaflet.css"/>
    {% endblock %}
{% block style %}
html, body {
    height: 100%;
}

#map {
    height:100%;
}

.fill {
    height:100%;
}
{% endblock %}
{% block content %}

<div class="container-fluid fill">
<div id="map" class="row"></div>
</div>
{% endblock %}

<script>
{% block script %}
<script src="https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.0.1/leaflet.js"></script>
<script src="https://unpkg.com/leaflet-pip@latest/leaflet-pip.js"></script>
<script src="{{STATIC_URL}}js/turf_pointOnSurface.js"></script>
<script>
var servicesLayer,serviceMarkerLayer;
$(function() {
      var map = L.map('map').setView([62,25], 8);
      L.tileLayer('http://api.digitransit.fi/map/v1/{id}/{z}/{x}/{y}.png', {
        maxZoom: 18,
        attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, ' +
          '<a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, ',
        id: 'hsl-map'}).addTo(map);
    //map.fitBounds([[59.764881, 20.548571],[70.092308, 31.586201]]);

    $.getJSON('http://beta.liikennevirasto.fi/joukkoliikenne/kutsujoukkoliikenne/vie/geojson',function (servicedata) {
         
        servicesLayer = new L.geoJson(servicedata,{
            onEachFeature: function (feat,lyr) {
                lyr.bindTooltip(feat.properties.lang.fi.name,{sticky:true});
                //lyr.bindPopup('<a href="/joukkoliikenne/kutsujoukkoliikenne/katselu/' + feat.properties.item_id + '">Lisätietoja</a>');
                
            }
        });

        
        

        var serviceMarkers = [];
        servicesLayer.eachLayer(function (lyr) {
            var feat = lyr.feature;
            var pos = turf.pointOnSurface(feat);
            
            var marker = L.marker([pos.geometry.coordinates[1],pos.geometry.coordinates[0]]).bindPopup('<strong>' + feat.properties.lang.fi.name + '</strong><br/><a href="/joukkoliikenne/kutsujoukkoliikenne/katselu/' + feat.properties.item_id + '">Lisätietoja</a>');
            serviceMarkers.push(marker);
        });
        serviceMarkerLayer = L.featureGroup(serviceMarkers);
        map.addLayer(serviceMarkerLayer);

        map.fitBounds(servicesLayer.getBounds());

        if (map.getZoom() > 10) {
            map.addLayer(servicesLayer);
        }

        map.on('click',function (e) {
            var hits = leafletPip.pointInLayer(e.latlng,servicesLayer);
            if (hits.length === 0) {
                return true;
            }

            var cont = hits.map(function (lyr) {
                var feat = lyr.feature;
                return '<li><strong>' + feat.properties.lang.fi.name + '</strong><br/><a href="/joukkoliikenne/kutsujoukkoliikenne/katselu/' + feat.properties.item_id + '">Lisätietoja</a></li>';
            });

            var popup = L.popup()
                .setLatLng(e.latlng)
                .setContent('<ul>' + cont.join('') + '</ul>')
                .openOn(map);
        });
    });

    map.on('zoomend',function (e) {
        if (!map.hasLayer(servicesLayer) && map.getZoom() > 10) {
            map.addLayer(servicesLayer);
        } else if (map.hasLayer(servicesLayer) && map.getZoom() <= 10) {
            map.removeLayer(servicesLayer);
        }
    });

});
</script>
{% endblock %}
</script>
