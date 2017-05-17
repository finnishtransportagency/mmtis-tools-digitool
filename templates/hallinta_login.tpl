{% extends "base.tpl" %}
{% block title %}Koulujen lomat{% endblock %}
{% block style %}

{% endblock %}
{% block content %}
<div class="container">
<h2>Kirjautuminen kutsujoukkoliikenteen hallintaan</h2>
<form method="post" action="{{ reverse_url('login') }}">
Käyttäjä: <input type="text" name="user" size="20"/><br/>
Avain: <input type="text" name="token" size="50"/>
<input type="submit" name="s" value="Kirjaudu sisään"/>
{{xsrf_form_html()}}
</form>
</div>
{% endblock %}

<script>
{% block script %}
{% endblock %}
</script>
