<!DOCTYPE html>
<html lang="en">
  <head>
    {% block head %}
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Kutsujoukkoliikenne - {% block title %}{% endblock %}</title>
    <link rel="stylesheet" href="{{STATIC_URL}}css/bootstrap.min.css"/>
    <link rel="stylesheet" href="{{STATIC_URL}}css/bootstrap-theme.min.css"/>
    <link rel="stylesheet" href="{{STATIC_URL}}css/leaflet.css"/>
    <link rel="stylesheet" href="{{STATIC_URL}}css/leaflet.draw.css"/>
    <link rel="stylesheet" href="{{STATIC_URL}}css/bootstrap-datetimepicker.css" />
    {% endblock %}    
    <style>
    body {
      padding-top:50px;
    }
    {% block style %}{% endblock %}</style>
    
</head>
  <body>
    <nav class="navbar navbar-inverse navbar-fixed-top">
      <div class="container">
        <div class="navbar-header">
          <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar" aria-expanded="false" aria-controls="navbar">
            <span class="sr-only">Toggle navigation</span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </button>
          <a class="navbar-brand" href="{{ reverse_url('index') }}">Kutsujoukkoliikenne</a>
        </div>
        <div id="navbar" class="collapse navbar-collapse">
          <ul class="nav navbar-nav">
            <li><a href="{{ reverse_url('index') }}">Lista</a></li>
            <li><a href="{{ reverse_url('map') }}">Kartta</a></li>
            {% if isAdmin or userAllowedTo('item','any','edit') %}<li><a href="{{ reverse_url('muokkaa') }}">Hallitse liikennettä</a></li>{%endif%}
          </ul>
          <ul class="nav navbar-nav navbar-right">
          {%if current_user %}
            <li><p class="navbar-text">{{current_user.name}}</p></li>
            <li><a href="{{ reverse_url('logout') }}">Kirjaudu ulos</a></li>
            {% if isAdmin or userAllowedTo('group','any','admin','admin') %}
            <li><a href="{{ reverse_url('admin') }}">Hallinta</a></li>
            {% endif %}
          {% else %}
            <li><a href="{{ reverse_url('login') }}">Kirjaudu sisään</a></li>
          {% endif %}
          </ul>

        </div><!--/.nav-collapse -->


      </div>
    </nav>
      {% block content %}{% endblock %}
    <script src="{{STATIC_URL}}js/jquery-2.2.4.min.js" type="text/javascript"></script>
    <script src="{{STATIC_URL}}js/bootstrap.min.js" type="text/javascript"></script> 

    <script type="text/javascript">function getCookie(name) {
        var r = document.cookie.match("\\b" + name + "=([^;]*)\\b");
        return r ? r[1] : undefined;
    }
    </script>
{% block script %}{% endblock %}     
  </body>
</html>
