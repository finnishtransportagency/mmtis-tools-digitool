{% extends "base.tpl" %}
{% block title %}Koulujen lomat{% endblock %}
{% block style %}

{% endblock %}
{% block content %}
<div class="content">
<h2>Käyttäjän tiedot muokattu onnistuneest!</h2>
{% if key%}
<h3>Käyttäjän uusi avain on: {{key}}</h3>
<p>
Avain on tallennettu yksisuuntaisella salauksella tietokantaan eikä sitä pystytä palauttamaan tai esittämään tämän sivun jälkeen. Mikäli avain unohtuu tai katoaa, luo käyttäjälle uusi avain.
</p>
{%endif%}
<a href="{{reverse_url('admin')}}">Takaisin käyttäjänhallintaan</a>
</div>
{% endblock %}
