{% extends "base.tpl" %}
{% block title %}Kutsujoukkoliikenne - Valtuuksien hallinta{% endblock %}

<style>
{% block style %}
.selhead {
    font-weight:bold;
}
{% endblock %}
</style>


{% block content %}
    <div class="container">
    	<h1>Hallinnoi liikenteen valtuuksia</h1>
    	<h2>Voimassa olevat valtuudet</h2>
        <form method="post" action="{{reverse_url('muokkaa-valtuudet',item_id)}}">
            {{xsrf_form_html()}}
        <table class="table table-condensed table-striped table-bordered">
            <thead>
                <tr>
                    <th colspan="2">Valtuutettu</th>
                    <th>&nbsp;</th>
                    <th colspan="2">Voimassaolo</th>
                    <th rowspan="2">&nbsp;</th>
                </tr>
                <tr>
                    <th>Tyyppi</th>
                    <th>Nimi</th>
                    <th>Rooli</th>
                    <th>Alkaa</th>
                    <th>Päättyy</th>
                </tr>
            </thead>
            <tbody id="authlist">
                {% for a in authorizations %}
                <tr>
                    <td><input type="hidden" name="atype" value="{{a.authorized_type}}"/>{{a.authorized_type}}</td> 
                    <td><input type="hidden" name="aid" value="{{a.authorized_id}}"/>{{a.authorized_name}}</td>
                    <td><input type="hidden" name="arole" value="{{a.permission}}"/>{{a.permission}}</td>
                    <td><input type="hidden" name="avalidfrom" value="{{a.valid_from}}"/>{{a.valid_from}}</td> 
                    <td><input type="hidden" name="avalidto" value="{{a.valid_to}}"/>{{a.valid_to}}</td>
                    <td><button class="delauth btn btn-warning">Poista valtuutus</button></td>                 
                </tr>
                {% endfor %}
            </tbody>
            <tfoot>
                <tr>
                    <th colspan="6">&nbsp;</th>
                </tr>                
                <tr>
                    <th colspan="6">Lisää uusi valtuutus</th>
                </tr>
                <tr>
                    <td>
                        <div class="input-group"><select class="form-control" id="authtype">
                            <option class="selhead" selected="selected" value="-1">Valitse tyyppi</option>
                            <option value="group">Ryhmä</option>
                            <option value="user">Käyttäjä</option>
                        </select></div>
                    </td>
                    <td>
                        <div class="finput-group"><select class="form-control" id="authid">
                            <option class="selhead" selected="selected" value="-1">Valitse valtuutettu</option>
                        </select></div>
                    </td>
                    <td>
                        <div class="input-group"><select class="form-control" id="authrole">
                            <option class="selhead" selected="selected" value="-1">Valitse rooli</option>
                            <option value="admin">Ylläpitäjä</option>
                            <option value="edit">Muokkaaja</option>
                            <option value="read">Katselija</option>
                        </select></div>
                    </td>
                    <td>
                        <div class="input-group"><input type="text" class="form-control dateinp" id="authvalidfrom"/></div>
                    </td>
                    <td>
                        <div class="input-group"><input type="text" class="form-control dateinp" id="authvalidto"/></div>
                    </td>
                    <td>
                        <button class="btn btn-success" id="addauth">Lisää valtuus</button>
                    </td>                    
                </tr>
                <tr>
                    <td colspan="6"><input type="submit" value="Tallenna muutokset" class="btn btn-success btn-lg"/></td>
                </tr>
            </tfoot>
        </table>
                
        </form>


                    
                    
        

    </div>
{% endblock %}


{% block script %}
    <script src="{{STATIC_URL}}js/moment-with-locales.js" type="text/javascript"></script>
    <script src="{{STATIC_URL}}js/bootstrap-datetimepicker.min.js" type="text/javascript"></script>
<script>
    var targets = {user:{{users|jsond}},group:{{groups|jsond}}};
    $(function() {
        $('input.dateinp').each(function(k, elem) {
            $(elem).datetimepicker({
                format: 'DD.MM.YYYY',
                locale: 'fi',
                calendarWeeks: true
            });


        });

        $('#authtype').change(function (e) {
            var t = $(this).val();
            if (targets[t] === undefined) return;

            $('#authid').children('option:not(.selhead)').remove();
            targets[t].forEach(function (v,k) {
                $('#authid').append('<option value="' + v.id + '">' + v.name + '</option>');
            });
        });

        $('#addauth').click(function (e) {
            e.preventDefault();
            var authtype = $('#authtype').val();
            var authid = parseInt($('#authid').val());
            var authrole = $('#authrole').val();
            var authvalidfrom = $('#authvalidfrom').val();
            var authvalidto = $('#authvalidto').val();
            console.log(authtype,authid,authrole,authvalidfrom,authvalidto);
            console.log($('#authlist'));

            $('#authlist').append('<tr>'+
            '<td><input type="hidden" name="atype" value="' + authtype + '"/>' + authtype + '</td>' + 
            '<td><input type="hidden" name="aid" value="' + authid + '"/>' + authid + '</td>' + 
            '<td><input type="hidden" name="arole" value="' + authrole + '"/>' + authrole + '</td>' + 
            '<td><input type="hidden" name="avalidfrom" value="' + authvalidfrom + '"/>' + authvalidfrom + '</td>' + 
            '<td><input type="hidden" name="avalidto" value="' + authvalidto + '"/>' + authvalidto + '</td>' + 
            '<td><button class="delauth btn btn-warning">Poista valtuutus</button></td>' + 
            '</tr>');
            return false;
        });

        $('#authlist').on('click', '.delauth', function () {
            e.preventDefault();
            $(this).parent().parent().remove();

            return false;
        });

    });
</script>
{% endblock %}
