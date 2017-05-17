{% extends "base.tpl" %}
{% block title %}Koulujen lomat{% endblock %}
{% block style %}

{% endblock %}
{% block content %}
<div class="container">
{%if group%}
<h2>Ryhmän {{group.name}} tietojen muokkaus</h2>
{% else %}
<h3>Luo uusi ryhmä</h3>
{% endif %}
{% if errors|length > 0 %}
<h3>Muokkauksessa tapahtui virhe tai virheitä:</h3>
<ul>
{% for e in errors %}
<li>{{e}}</li>
{%endfor%}
</ul>
{% endif %}
<form method="post" action="{{reverse_url('admin-ryhma',group.group_id)}}" class="form">
<fieldset>
<legend>Käyttäjä</legend>
<div class="form-group form-inline">
      <div class="input-group">
            <label for="groupname">Ryhmän nimi</label>
            <input type="text" class="form-control" name="groupname" id="groupname" {% if group.name %}value="{{group.name}}"{%endif%}/>           
      </div>
</div>
<div class="form-group form-inline">
      <div class="input-group">
            <label for="valid_from">Voimassaolo alkaa</label>
            <input type="text" class="form-control dateinp" name="valid_from" id="valid_from" {% if group.valid_from %}value="{{group.valid_from.strftime('%d.%m.%Y')}}"{%endif%}/>
      </div>
      <div class="input-group">            
            <label for="valid_to">Voimassaolo päättyy</label>         
            <input type="text" class="form-control dateinp" name="valid_to" id="valid_to" {% if group.valid_to %}value="{{group.valid_to.strftime('%d.%m.%Y')}}"{%endif%}/>
      </div>
</div>
</fieldset>
{{xsrf_form_html()}}
<input type="submit" class="btn btn-success" value="Tallenna muutokset" name="s"/>
</form>

{%if members|length > 0%}
<h3>Ryhmän jäsenet</h3>
<form method="post" action="{{reverse_url('admin-ryhma-lisaajasen',group.group_id)}}">
      {{xsrf_form_html()}}
<table class="table table-striped table-condensed">
      <thead>
            <tr>
                  <th>Nimi</th>
                  <th>Rooli</th>
                  <th>Voimassa lähtien</th>
                  <th>Voimassa asti</th>
            </tr>
      </thead>
      <tbody>
            {%for m in members %}
            <tr>
                  <td>{{m.name}}</td>
                  <td>{{m.role}}</td>
                  <td>{{m.valid_from.strftime('%d.%m.%Y %H:%M')}}</td>
                  <td>{{m.valid_to.strftime('%d.%m.%Y %H:%M') if m.valid_to else 'Toistaiseksi'}}</td>
                  <td><a href="{{reverse_url('admin-ryhma-poistajasen',group.group_id,m.user_id)}}" class="btn btn-danger">Poista jäsen</button></td>
            </tr>
            {% endfor %}
      </tbody>
      
      <tfoot>
            <tr>
                  <th colspan="5">Lisää uusi jäsen ryhmään</th>
            </tr>
            <tr>
                  <td><div class="input-group"><select name="nuserid" class="form-control"><option value="-1">Valitse käyttäjä</option>{% for pu in potential_members%}<option value="{{pu.user_id}}">{{pu.name}}</option>{%endfor%}</select></div></td>
                  <td><div class="input-group"><select name="nrole" class="form-control"><option value="-1">Valitse rooli</option><option value="admin">Ylläpitäjä</option><option value="user">Jäsen</option></select></div></td>
                  <td><div class="input-group"><input type="text" class="form-control dateinp" name="nvalid_from" placeholder="Voimassa alkaen"/></div></td>
                  <td><div class="input-group"><input type="text" class="form-control dateinp" name="nvalid_to" placeholder="Voimassa asti"/></div></td>
                  <td><div class="input-group"><input name="s" type="submit" value="Lisää jäsen" class="btn btn-success"/></div></td>
            </tr>
      </tfoot>

</table>
</form>
{%endif%}
</div>
{% endblock %}


{% block script %}
<script src="{{STATIC_URL}}js/moment-with-locales.js" type="text/javascript"></script>
<script src="{{STATIC_URL}}js/bootstrap-datetimepicker.min.js" type="text/javascript"></script>
<script>
      var pusers = {{potential_members|jsond}};
$(function () {
      $('input.dateinp').each(function(k,elem) {                     
            $(elem).datetimepicker({
                  format: 'DD.MM.YYYY',
                  locale: 'fi',
                  calendarWeeks: true
            });
            

      });
});
</script>
           
{% endblock %}
