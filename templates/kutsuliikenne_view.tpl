{% extends "base.tpl" %}
{% block title %}Kutsujoukkoliikenne{% endblock %}
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
<h1>Kutsujoukkoliikennepalvelun tiedot</h1>
<table class="table table-bordered table-condensed table-striped">
    {%- for k in item.info if k != 'lang' -%}
    <tr>
        <th width="150">{{fieldtrans['fi'][k]}}</th>
        <td>{%-if k == 'valid'-%}
            <table class="table table-bordered table-condensed table-striped">
                <thead>
                <tr>
                    <th colspan="2">Voimassaolo</th>
                    <th colspan="2">Liikennöintiaika</th>
                </tr>
                <tr>
                    <th>Alkaa</th>
                    <th>Päättyy</th>
                    <th>Lähtien klo</th>
                    <th>Asti klo</th>
                </tr>
            </thead>
            <tbody>                        
            {%-for v in item.info[k]-%}
            <tr>
                <td>{{v.start_date}}</td>
                <td>{{v.end_date}}</td>
                <td>{{v.start_time}}</td>
                <td>{{v.end_time}}</td>
            </tr>
            {%-endfor-%}
            </tbody>
            </table>
            {%-elif k == 'weekdays'-%}
            {%-for wkd in ('ma','ti','ke','to','pe','la','su')-%}
            {{wkd if item.info[k][loop.index0] else ''}}{{', ' if item.info[k][loop.index0] and not loop.last}}
            {%-endfor-%}
            {%-else-%}
            {{item.info[k]}}
            {%-endif-%}</td>
    </tr>
    {%endfor%}
</table>

{%for lang in ('fi','sv','en')%}
<table class="table table-bordered table-condensed table-striped">
    <tr>
        <th colspan="2">{{fieldtrans[lang]['lang']}} <button class="btn togglecollapse">{%if lang=='fi'%}-{%else%}+{%endif%}</button></th>
    </tr>
    {% for k in item.info.lang[lang] %}
    <tr class="inforow{%if lang=='fi'%}{%else%} hidden{%endif%}">
        <th width="150">{{fieldtrans[lang][k]}}</th>
        <td>{{item.info.lang[lang][k]|linkify}}</td>
    </tr>
    {%endfor%}
</table>
{%endfor%}
<table class="table table-bordered table-condensed table-striped">
    <tr>
        <th colspan="2">Kartta palvelualueesta</th>
    </tr>
    <tr>
    <td>
<div id="map"></div>
</td>
</tr>
</table>
<table class="table table-bordered table-condensed table-striped">
    <tr>
        <th colspan="2">Vie tiedot</th>
    </tr>
    <tr><td><a href="{{reverse_url('export-item','geojson',item.item_id)}}">GeoJSON</a></td></tr>
    <tr><td><a href="{{reverse_url('export-item','navici',item.item_id)}}">csv+kml</a></td></tr>
</table>
</div>
{% endblock %}


{% block script %}
<script src="{{STATIC_URL}}js/proj4.js" type="text/javascript"></script>
<script src="{{STATIC_URL}}js/leaflet.js" type="text/javascript"></script>
<script src="{{STATIC_URL}}js/proj4leaflet.js" type="text/javascript"></script>
<script src="{{STATIC_URL}}js/mmlLayers.js" type="text/javascript"></script>
<script>
    var area_geoms = {{item.jsongeom}};
$(function() {
var map = new L.map('map', {
    crs: L.TileLayer.MML.get3067Proj()
}).setView([61, 25], 3);

L.tileLayer.mml_wmts({ layer: "taustakartta" }).addTo(map);


var areaItems = new L.geoJson(area_geoms);
map.addLayer(areaItems);
map.fitBounds(areaItems.getBounds());
});
var a;
$('.togglecollapse').click(function () {
    var inforows = $(this).closest('tbody').children('.inforow');
    if (inforows.hasClass('hidden')) {
        inforows.removeClass('hidden');
        $(this).text('-');
    } else {
        inforows.addClass('hidden');
        $(this).text('+');
    }
});
</script>
{% endblock %}

