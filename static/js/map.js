$(function() {
var map = new L.map('map', {
    crs: L.TileLayer.MML.get3067Proj()
}).setView([61, 25], 3);

L.tileLayer.mml_wmts({ layer: "taustakartta" }).addTo(map);

	map.fitBounds([[59.764881, 20.548571],[70.092308, 31.586201]]);


// Initialise the FeatureGroup to store editable layers
var areaItems = new L.geoJson(item_geom);
map.addLayer(areaItems);

// Initialise the draw control and pass it the FeatureGroup of editable layers
var drawControl = new L.Control.Draw({
    edit: {
        featureGroup: areaItems,
        poly: {
        	allowIntersection: false
        }
    },
    draw: {
    	polyline:false,
    	marker:false,
    	circle:false,
    	polygon: {
    		allowIntersection: false,
            drawError: {
                color: '#e1e100',
                message: 'Virheellinen aluerajaus' // Message that will show when intersect
            },
            shapeOptions: {
                color: '#FF00DD'
            }    		
    	}
    }
});
map.addControl(drawControl);


map.on('draw:created', function (e) {
    var type = e.layerType,
        layer = e.layer;


    areaItems.addLayer(layer);
});


$('#sbmt').click(function(e) {
	var areas = areaItems.getLayers();
	if (areas.length === 0) {
		return "Ei aluerajauksia";
	}

    document.getElementById('geom').value = JSON.stringify(areaItems.toGeoJSON());
});

$('#cncl').click(function (e) {
	e.preventDefault();
	areaItems.clearLayers();
});
});