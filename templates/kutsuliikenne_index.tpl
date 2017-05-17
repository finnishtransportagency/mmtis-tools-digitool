{% extends "base.tpl" %}
{% block title %}Kutsujoukkoliikenne{% endblock %}
{% block style %}

{% endblock %}
{% block content %}

<div class="container">
<h1>Liikenneviraston koontikannan kutsujoukkoliikenne</h1>
<p></p>
<h2>Aktiiviset kutsujoukkoliikennepalvelut</h2>
{{active_table_html}}

<h3>Aineistorajapinta</h3>
Rajapinnan kautta on haettavissa kaikki aktiivinen ja tulevaisuudessa aktiiviseksi tulossa oleva liikenne.
<ul>
    <li><a href="{{reverse_url('export','geojson')}}">Lataa tiedot GeoJSON muodossa</a></li>
    <li><a href="{{reverse_url('export','navici')}}">Lataa tiedot csv+kml muodossa</a></li>
</ul>
</div>
{% endblock %}

<script>
{% block script %}
{% endblock %}
</script>
