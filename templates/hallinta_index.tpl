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
    	<h2>Hallitsemasi kutsujoukkoliikenne palvelussa</h2>
    	<table class="table table-bordered table-striped table-condensed table-hover">
    		<thead>
    			<tr>
    				<th width="50">Id</th>
    				<th>Nimi</th>
    				<th width="150">Luotu</th>
    				<th width="150">Viimeksi muokattu</th>
    				<th width="50">Muokkaaja</th>
    				<th width="50">&nbsp;</th>
    				<th width="200">Muokkaa kohteen</th>
    				<th width="10">&nbsp;</th>
    			</tr>
    		</thead>
    		<tbody>
    		{% for item in items if userAllowedTo('item',item.item_id,'read')%}
                <tr{%if item.deleted%} class="danger"{%endif%}>
    				<td>{{item.item_id}}</td>
    				<td><a href="{{reverse_url('view',item.item_id)}}">{{item.info.lang.fi.name}}</a></td>
    				<td>{{item.created.strftime('%d.%m.%Y %H:%M')}}</td>
    				<td>{{item.last_modified.strftime('%d.%m.%Y %H:%M') if item.last_modified else ''}}</td>
    				<td>{%if isAdmin %}<a href="{{ reverse_url('admin-avain',item.modified_by) }}">{{item.modified_by_name}}</a>{%else%}{{item.modified_by_name}}{%endif%}</td>
    				<td>{%if userAllowedTo('item',item.item_id,'edit') %}
						<a href="{{reverse_url('muokkaa-status',item.item_id)}}" class="btn btn-xs {%if not item.public%}btn-success">Julkaise{%else%}btn-warning">Piilota{%endif%}</a>
						{%else%}
						{{'Julkinen' if item.public else 'Piilotettu'}}
						{%endif%}
    				</td>
    				<td>
					{%if userAllowedTo('item',item.item_id,'edit') %}
    					<div class="btn-group">
    						<a href="{{reverse_url('muokkaa-info',item.item_id)}}" class="btn btn-info btn-xs">Tietoja</a>
    						<a href="{{reverse_url('muokkaa-kartta',item.item_id)}}" class="btn btn-info btn-xs">Alueita</a>
							{%if userAllowedTo('item',item.item_id,'admin') %}
    						<a href="{{reverse_url('muokkaa-valtuudet',item.item_id)}}" class="btn btn-info btn-xs">Valtuuksia</a>
							{%endif%}
						</div>
					{%endif%}
					</td>
    				<td>{%if userAllowedTo('item',item.item_id,'admin') and not item.deleted%}<a href="{{reverse_url('muokkaa-poista',item.item_id)}}" class="btn btn-danger btn-xs">Poista</a>{%else%}
                    {%if isAdmin%}<a href="{{reverse_url('muokkaa-poista',item.item_id)}}" class="btn btn-success btn-xs">Palauta</a>{%endif%}{%endif%}</td>
    			</tr>    		
    		{%endfor%}
    		</tbody>
    		<tfoot>
    			<tr>
    				<td colspan="5"><a href="{{reverse_url('muokkaa-uusi')}}" class="btn btn-primary btn-sm">Luo uusi kohde</a></td>
    			</tr>
    		</tfoot>
    	</table>
		<!--
    	<pre>
    	CREATE TABLE kutsuliikenne_items (
            item_id serial,
            created timestamp with time zone,
            last_modified timestamp with time zone DEFAULT current_timestamp,
            modified_by integer,
            public boolean,
            deleted timestamp with time zone,
            info jsonb,
            PRIMARY KEY (item_id)

    	);

        CREATE TABLE jlusers (
            user_id serial,
            username text,
            name text,
            passkey text,
            valid_from timestamp with time zone,
            valid_until timestamp with time zone,
            role text,
            PRIMARY KEY (user_id)
        );


        CREATE TABLE jluser_groups (
            user_id int,
            group_id int,
            valid_from timestamp with time zone,
            valid_to timestamp with time zone,
            role text,
            PRIMARY KEY (user_id,group_id)

        );

        CREATE TABLE jlgroups (
            group_id serial,
            name text,
            valid_from timestamp with time zone,
            valid_to timestamp with time zone,
            PRIMARY KEY (group_id)
        );

        CREATE TABLE jlauthorizations (
            authorization_id serial,
            authorized_type text,
            authorized_id int,
            target_service text,
            target_resource text,
            target_ident text,
            permission text,
            valid_from timestamp with time zone,
            valid_to timestamp with time zone,
            PRIMARY KEY (authorization_id)

        );
    	</pre>
		-->
    	


    </div>
{% endblock %}


{% block script %}
<script>
$(function() {

});
</script>
{% endblock %}
