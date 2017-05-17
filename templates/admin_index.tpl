{% extends "base.tpl" %}
{% block title %}Koulujen lomat{% endblock %}
{% block style %}

{% endblock %}
{% block content %}
<div class="container">
<h2>Käyttäjien ja valtuuksien ylläpito</h2>
{% if isAdmin %}
<h3>Käyttäjät</h3>
<table class="table table-striped table-bordered table-condensed">
<thead>
	<tr>
		<th>Käyttäjänimi</th>
		<th>Nimi</th>
		<th>Rooli</th>
		<th>Voimassa lähtien</th>
		<th>Voimassa asti</th>
		<th>Ryhmiä</th>
		<th>Valtuuksia</th>
		<th colspan="2">&nbsp;</th>
	</tr>
</thead>
<tbody>

{%for user in users %}
<tr>
	<td>{{user.username}}</td>
	<td>{{user.name}}</td>
	<td>{{user.role}}</td>
	<td>{%if user.valid_from%}{{user.valid_from.strftime('%d.%m.%Y')}}{%else%}Ei voimassa{%endif%}</td>
	<td>{%if user.valid_to%}{{user.valid_to.strftime('%d.%m.%Y')}}{%else%}Toistaiseksi{%endif%}</td>
	<td>{{user.ngroups}} kpl</td>
	<td>{{user.nauthorizations}} kpl</td>
	<td><a href="{{ reverse_url('admin-avain',user.user_id) }}" class="btn btn-info btn-sm">Hallitse tietoja</a></td>
	<td><a href="{{ reverse_url('admin-avain-poisto',user.user_id) }}" class="btn btn-danger btn-sm">Päätä voimassaolo</a></td>
</tr>
{%endfor%}
</tbody>
</table>

<h4><a href="{{reverse_url('admin-avain-uusi')}}">Luo uusi käyttäjä</a></h4>
{% endif %}
<h3>Ryhmät</h3>
<table class="table table-striped table-bordered table-condensed">
<thead>
	<tr>
		<th>ID</th>
		<th>Nimi</th>
		<th>Voimassa lähtien</th>
		<th>Voimassa asti</th>
		<th>Jäseniä</th>
		<th>Valtuuksia</th>
		<th colspan="2">&nbsp;</th>
	</tr>
</thead>
<tbody>

{%for group in groups if userAllowedTo('group',group.group_id,'admin','admin')%}
<tr>
	<td>{{group.group_id}}</td>
	<td>{{group.name}}</td>
	<td>{%if group.valid_from%}{{group.valid_from.strftime('%d.%m.%Y')}}{%else%}Ei voimassa{%endif%}</td>
	<td>{%if group.valid_to%}{{group.valid_to.strftime('%d.%m.%Y')}}{%else%}Toistaiseksi{%endif%}</td>
	<td>{{group.nusers}} kpl</td>
	<td>{{group.nauthorizations}} kpl</td>
	<td><a href="{{ reverse_url('admin-ryhma',group.group_id) }}" class="btn btn-info btn-sm">Hallitse tietoja</a></td>
	<td>{% if isAdmin %}<a href="{{ reverse_url('admin-ryhma-poisto',group.group_id) }}" class="btn btn-danger btn-sm">Päätä voimassaolo</a>{%endif%}</td>
</tr>
{%endfor%}
</tbody>
</table>
{% if isAdmin %}<h4><a href="{{reverse_url('admin-ryhma-uusi')}}">Luo uusi ryhmä</a></h4>{% endif %}
</div>
{% endblock %}


{% block script %}
<script>
</script>
{% endblock %}

