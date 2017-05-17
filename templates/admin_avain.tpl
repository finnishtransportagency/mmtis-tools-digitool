{% extends "base.tpl" %}
{% block title %}Koulujen lomat{% endblock %}
{% block style %}

{% endblock %}
{% block content %}
<div class="container">
{%if user%}
<h2>Käyttäjän {{user.name}} ({{user.username}}) tiedot</h2>
{% else %}
<h3>Luo uusi käyttäjä</h3>
{% endif %}
{% if errors|length > 0 %}
<h3>Muokkauksessa tapahtui virhe tai virheitä:</h3>
<ul>
{% for e in errors %}
<li>{{e}}</li>
{%endfor%}
</ul>
{% endif %}
<form method="post" action="{{reverse_url('admin-avain',user.user_id)}}" class="form">
<fieldset>
<legend>Käyttäjä</legend>
<div class="form-group" class="form-inline">
      <div class="input-group">
            <label for="username">KäyttäjäID</label>
            <input type="text" class="form-control" name="userid" id="userid" {% if user.user_id %}value="{{user.user_id}}"{%endif%} disabled="disabled"/>           
      </div>
      <div class="input-group">
            <label for="username">Käyttäjänimi</label>
            <input type="text" class="form-control" name="username" id="username" {% if user.username %}value="{{user.username}}" disabled="disabled"{%endif%}/>           
      </div>
      <div class="input-group">
            <label for="name">Nimi</label>
            <input type="text" class="form-control" name="name" id="name" {% if user.name %}value="{{user.name}}"{%endif%} size="40"/>           
      </div>
</div>
<div class="form-group" class="form-inline">
      <div class="input-group">
            <label for="valid_from">Voimassaolo alkaa</label>
            <input type="text" class="form-control dateinp" name="valid_from" id="valid_from" {% if user.valid_from %}value="{{user.valid_from.strftime('%d.%m.%Y')}}"{%endif%}/>
      </div>
      <div class="input-group">            
            <label for="valid_to">Voimassaolo päättyy</label>         
            <input type="text" class="form-control dateinp" name="valid_to" id="valid_to" {% if user.valid_to %}value="{{user.valid_to.strftime('%d.%m.%Y')}}"{%endif%}/>
      </div>
      <div class="input-group">
            <label for="role">Rooli</label>
            <select class="form-control" name="role" id="role">
            <option value="user" {%if user.role == 'user'%}selected="selected"{%endif%}>Käyttäjä</option>
            <option value="admin" {%if user.role == 'admin'%}selected="selected"{%endif%}>Ylläpitäjä</option>
            </select>     
      </div>
      <div class="input-group">
            <label>Avain</label>
            <p>Nykyistä avainta ei voida näyttää. Avaimen unohtuessa/kadotessa tulee luoda uusi avain</p>
            <label for="genavain">Luo uusi avain</label>
            {%if user %}<input type="checkbox" id="genavain" name="genavain"/>{%else%}<input type="checkbox" id="genavain" name="genavain" checked="checked" disabled="disabled"/>{%endif%}
            <p><small>Uusi avain esitetään <strong>vain kerran</strong> tämän lomakkeen lähetyksen jälkeen.</small></p>
      </div>
</div>
</fieldset>
{{xsrf_form_html()}}

<hr/>
<fieldset>
<legend>Ryhmät</legend>
<table class="table table-bordered table-condensed table-striped">
<thead>
<tr>
      <th>Ryhmän nimi</th>
      <th>Rooli</th>
      <th>Voimassa alkaen</th>
      <th>Voimassa asti</th>
      <th>&nbsp;</th>
</tr>
</thead>
<tbody id="grpbody">
{% for g in groups %}
<tr>
<td><input type="hidden" name="groupid" value="{{g.group_id}}"/>{{g.name}}</td>
<td><input type="hidden" name="grouprole" value="{{g.role}}"/>{{g.role}}</td>
<td><input type="hidden" name="groupfrom" value="{{g.valid_from.strftime('%d.%m.%Y')}}"/>{{g.valid_from.strftime('%d.%m.%Y')}}</td>                        
<td><input type="hidden" name="groupto" value="{%if g.valid_to%}{{g.valid_to.strftime('%d.%m.%Y')}}{%endif%}"/>{%if g.valid_to%}{{g.valid_to.strftime('%d.%m.%Y')}}{%endif%}</td>                             
<td><button class="del_grp btn btn-warning">Poista jäsenyys</button></td>
</tr>
{%endfor%}
</tbody>
<tfoot>
<tr>
<th colspan="5">Lisää käyttäjä ryhmään</th>
</tr>
<tr>
<td>
<select class="form-control" id="ngid"><option value="-1" selected="selected"></option>{%for g in avail_groups%}<option value="{{g.group_id}}">{{g.name}}</option>{%endfor%}</select></td>
<td><select class="form-control" id="ngr"><option value=""></option><option value="admin">Ylläpitäjä</option><option value="edit">Muokkaaja</option><option value="view">Katselija</option></select></td>
<td><div class="input-group">   <input type="text" class="form-control dateinp" id="ngvf"/></div></td>
<td><div class="input-group">   <input type="text" class="form-control dateinp" id="ngvt"/></div></td>
<td><button id="addgroup" name="addgroup" class="btn btn-success">Lisää</button></td>

</table>
</fieldset>

<hr/>

<fieldset>
<legend>Valtuudet</legend>
<table class="table table-bordered table-condensed table-striped">
<thead>
<tr>
	<th>Kunta</th>
      <th>Vuosi</th>
	<th>Voimassa asti</th>
	<th>&nbsp;</th>
</tr>
</thead>
<tbody id="exbody">
{% for a in authorizations %}
{{a}}
{%endfor%}
</table>
</fieldset>

<input type="submit" class="btn btn-success" value="Tallenna muutokset" name="s"/>
</form>
</div>

{% endblock %}


{% block script %}
<script src="{{STATIC_URL}}js/moment-with-locales.js" type="text/javascript"></script>
<script src="{{STATIC_URL}}js/bootstrap-datetimepicker.min.js" type="text/javascript"></script>
<script>
            $(function () {
                  $('input.dateinp').each(function(k,elem) {                     
                        $(elem).datetimepicker({
                              format: 'DD.MM.YYYY',
                              locale: 'fi',
                              calendarWeeks: true
                        });
                        

                  });
                  $('#addgroup').click(function (e) {
                        var ngid = parseInt($('#ngid').val());
                        var ngname = $("#ngid option:selected").text();


                        var ngr = $('#ngr').val();
                        var ngvf = $('#ngvf').val();
                        var ngvt = $('#ngvt').val();

                        console.log(ngid,ngr,ngvf,ngvt);

                        if (ngid == -1) {
                              alert('Valitse ryhmä');
                              return false;
                        }

                        if (ngr == '') {
                              alert('Valitse rooli');
                              return false;
                        }


                       if (ngvf == '') {
                              alert('Valitse voimassaolon alku');
                              return false;
                        }


                        $('#grpbody').append('<tr>'+
                              '<td><input type="hidden" name="groupid" value="' + ngid + '"/>' + ngname + '</td>'+
                              '<td><input type="hidden" name="grouprole" value="' + ngr + '"/>' + ngr + '</td>'+
                              '<td ><input type="hidden" name="groupfrom" value="' + ngvf + '"/>' + ngvf + '</td>'+                             
                              '<td ><input type="hidden" name="groupto" value="' + ngvt + '"/>' + (ngvt===''?'Toistaiseksi':ngvt) + '</td>'+                             
                              '<td><button class="del_grp btn btn-warning">Poista jäsenyys</button></td>' +
                              '</tr>');
                        return false;
                  });

                  $('#grpbody').on('click', '.del_grp', function () {
                        $(this).parent().parent().remove();

                        return false;
                  });
            });
 </script>
           
{% endblock %}
