{% extends "base.tpl" %}
{% block title %}Kutsujoukkoliikenne - Alueiden piirto{% endblock %}

{% block style %}
	#map {
		margin-left:auto;
		margin-right:auto;
		width:100%;
		height:80%;
		min-width:800px;
		min-height:700px;
		margin-bottom:1em;
	}
{% endblock %}
{% block content %}
    <div class="container">
    	<h1>Piirrä kartalle alueet, joilla kutsujoukkoliikennepalvelu toimii</h1>
    	<div id="map"></div>
    	<form method="post">
    	<input type="hidden" id="geom" name="geom" value=""/>
    	{{xsrf_form_html()}}
    	<button id="sbmt" type="submit" class="btn btn-success btn-lg">Tallenna aluerajaus</button>
    	<!--<button id="cncl" type="submit" class="btn btn-danger btn-lg">Tyhjennä aluerajaukset</button>-->
    	</form>

    </div>
{% endblock %}


{% block script %}
<script src="{{STATIC_URL}}js/proj4.js" type="text/javascript"></script>
<script src="{{STATIC_URL}}js/leaflet.js" type="text/javascript"></script>
<script src="{{STATIC_URL}}js/proj4leaflet.js" type="text/javascript"></script>
<script src="{{STATIC_URL}}js/leaflet.draw.js" type="text/javascript"></script>
<script src="{{STATIC_URL}}js/mmlLayers.js" type="text/javascript"></script>
<script>
var item_geom = {{item_geom}};
</script>
<script src="{{STATIC_URL}}js/map.js" type="text/javascript"></script>
{% endblock %}
