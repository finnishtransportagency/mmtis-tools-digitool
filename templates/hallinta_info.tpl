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

{% macro localized_info_inputs(lang_name,lang_prefix) -%}
<div class="panel panel-default">
    <div class="panel-heading">Kielistetyt tiedot - {{lang_name}}</div>
    <div class="panel-body">
        <div class="form-group">
            <label class="col-xs-2 control-label" for="{{lang_prefix}}name">Nimi</label>
            <div class="col-xs-10">
                <input type="text" class="form-control" name="{{lang_prefix}}name" id="{{lang_prefix}}name"  value="{{item.info.lang[lang_prefix].name}}" required/>
            </div>
        </div>
        <div class="form-group">
            <label class="col-xs-2 control-label" for="{{lang_prefix}}startdesc">Lähtöpaikan selite</label>
            <div class="col-xs-4">
                <input type="text" class="form-control" name="{{lang_prefix}}startdesc" id="{{lang_prefix}}startdesc" value="{{item.info.lang[lang_prefix].startdesc}}" required/>
            </div>
            <span class="help-block">Käytetään, kun reittihaun lähtöpaikka osuu tämän kutsuliikennealueen kohdalle</span>
            <label class="col-xs-2 control-label" for="enddesc">Määränpään selite</label>
            <div class="col-xs-4">
                <input type="text" class="form-control" name="{{lang_prefix}}enddesc" id="{{lang_prefix}}startdesc" value="{{item.info.lang[lang_prefix].enddesc}}" required/>
            </div>
            <span class="help-block">Käytetään, kun reittihaun määränpää osuu tämän kutsuliikennealueen kohdalle</span>
        </div>
        <div class="form-group">
            <label class="col-xs-2 control-label" for="{{lang_prefix}}desc">Selite</label>
            <div class="col-xs-10">
                <input type="text" class="form-control" name="{{lang_prefix}}desc" id="{{lang_prefix}}desc" value="{{item.info.lang[lang_prefix].desc}}"/>
            </div>
            <span class="help-block col-xs-10 col-xs-offset-2">Käytetään, kun sekä lähtöpaikka että määränpää on tämän alueen sisällä</span>
        </div>

        <div class="form-group">
            <label class="col-xs-2 control-label" for="{{lang_prefix}}adds">Lisäpalvelut</label>
            <div class="col-xs-10">
                <input type="text" class="form-control" name="{{lang_prefix}}adds" id="{{lang_prefix}}adds" value="{{item.info.lang[lang_prefix].adds}}"/>
            </div>
        </div>
        <div class="form-group">
            <label class="col-xs-2 control-label" for="{{lang_prefix}}price">Hinta</label>
            <div class="col-xs-10">
                <input type="text" class="form-control" name="{{lang_prefix}}price" id="{{lang_prefix}}price" value="{{item.info.lang[lang_prefix].price}}"/>
            </div>
        </div>
        <div class="form-group">
            <label class="col-xs-2 control-label" for="{{lang_prefix}}orddesc">Tilausohje</label>
            <div class="col-xs-10">
                <input type="text" class="form-control" name="{{lang_prefix}}orddesc" id="{{lang_prefix}}orddesc" value="{{item.info.lang[lang_prefix].orddesc}}"/>
            </div>
        </div>
    </div>
</div>
{%- endmacro %}


{% block content %}
<div class="container">
    <h1>Syötä kutsujoukkoliikennettä kuvaavat tiedot</h1>
    <fieldset>
        <div>

            <!-- Nav tabs -->
            <ul class="nav nav-tabs" role="tablist">
                <li role="presentation" class="active"><a href="#fi" aria-controls="fi" role="tab" data-toggle="tab">Suomi / yleistiedot</a></li>
                <li role="presentation"><a href="#sv" aria-controls="sv" role="tab" data-toggle="tab">Ruotsi</a></li>
                <li role="presentation"><a href="#en" aria-controls="en" role="tab" data-toggle="tab">Englanti</a></li>
            </ul>
            <form id="infoForm" class="form-horizontal" data-toggle="validator" method="post">
                <!-- Tab panes -->
                <div class="tab-content">

                    <div role="tabpanel" class="tab-pane active" id="fi">
                        {{localized_info_inputs('suomi','fi')}}
                        <div class="panel panel-default">
                            <div class="panel-heading">Kohteen yleiset tiedot</div>
                            <div class="panel-body">
                                <div class="form-group">
                                    <label class="col-xs-2 control-label">Ajopäivät</label>
                                    <div class="col-xs-1"><label class="col-xs-1 control-label" for="wkdmon">ma</label><input type="checkbox" class="form-control" name="wkdmon" id="wkdmon" {%if item.info.weekdays[0]%}checked="checked"{%endif%}/></div>
                                    <div class="col-xs-1"><label class="col-xs-1 control-label" for="wkdtue">ti</label><input type="checkbox" class="form-control" name="wkdtue" id="wkdtue" {%if item.info.weekdays[1]%}checked="checked"{%endif%}/></div>
                                    <div class="col-xs-1"><label class="col-xs-1 control-label" for="wkdwed">ke</label><input type="checkbox" class="form-control" name="wkdwed" id="wkdwed" {%if item.info.weekdays[2]%}checked="checked"{%endif%}/></div>
                                    <div class="col-xs-1"><label class="col-xs-1 control-label" for="wkdthu">to</label><input type="checkbox" class="form-control" name="wkdthu" id="wkdthu" {%if item.info.weekdays[3]%}checked="checked"{%endif%}/></div>
                                    <div class="col-xs-1"><label class="col-xs-1 control-label" for="wkdfri">pe</label><input type="checkbox" class="form-control" name="wkdfri" id="wkdfri" {%if item.info.weekdays[4]%}checked="checked"{%endif%}/></div>
                                    <div class="col-xs-1"><label class="col-xs-1 control-label" for="wkdsat">la</label><input type="checkbox" class="form-control" name="wkdsat" id="wkdsat" {%if item.info.weekdays[5]%}checked="checked"{%endif%}/></div>
                                    <div class="col-xs-1"><label class="col-xs-1 control-label" for="wkdsun">su</label><input type="checkbox" class="form-control" name="wkdsun" id="wkdsun" {%if item.info.weekdays[6]%}checked="checked"{%endif%}/></div>
                                </div>
                                <div class="form-group">
                                    <label class="col-xs-2 control-label">Ajoajat</label>
                                    <div class="col-xs-10 form-group">
                                        <table class="table table-condensed table-bordered table-striped">
                                            <thead>
                                                <tr>
                                                    <th colspan="2">Voimassaolopäivämäärät</th>
                                                    <th colspan="2">Päivittäiset ajoajat</th>
                                                    <th>&nbsp;</th>
                                                </tr>
                                                <tr>
                                                    <th>Alkaa</th>
                                                    <th>Päättyy</th>
                                                    <th>Aloitus klo</th>
                                                    <th>Lopetus klo</th>
                                                    <th>&nbsp;</th>
                                                </tr>
                                            </thead>
                                            <tbody id="tdBody">
                                            {% for v in item.info.valid %}
                                            <tr>
                                                <td><input type="hidden" name="valid_startd" value="{{v.start_date}}"/>{{v.start_date}}</td>
                                                <td><input type="hidden" name="valid_endd" value="{{v.end_date}}"/>{{v.end_date}}</td>
                                                <td><input type="hidden" name="valid_startt" value="{{v.start_time}}"/>{{v.start_time}}</td>
                                                <td><input type="hidden" name="valid_endt" value="{{v.end_time}}"/>{{v.end_time}}</td>
                                                <td><button class="del_ex btn btn-warning btn-xs">Poista ajoaika</button></td>
                                            </tr>
                                            {% endfor %}
                                            </tbody>
                                            <tfoot>
                                                <tr>
                                                    <td><input class="form-control" type="date" id="startd" placeholder="Alkupäivämäärä"/></td>
                                                    <td><input class="form-control" type="date" id="endd" placeholder="Loppupäivämäärä"/></td>
                                                    <td><input class="form-control" type="time" id="startt" placeholder="Aloitusaika"/></td>
                                                    <td><input class="form-control" type="time" id="endt" placeholder="Lopetusaika"/></td>
                                                </tr>                                       
                                                <tr>
                                                    <td colspan="5"><button id="newTimeRow" class="btn btn-success">Lisää ajoajat</button></td>
                                                </tr>
                                            </tfoot>
                                        </table>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label class="col-xs-2 control-label" for="orderdl">Tilaus viimeistään</label>
                                    <div class="col-xs-2">
                                        <input type="number" class="form-control" name="orderdl" id="orderdl" value="{{item.info.orderdl}}"/>
                                    </div>
                                    <span class="help-block">tuntia ennen matkaa</span>
                                </div>
                                <div class="form-group">
                                    <label class="col-xs-2 control-label" for="access">Esteettömyys</label>
                                    <div class="col-xs-1"><label class="col-xs-1 control-label">Kyllä</label><input type="radio" name="accessible" id="accessyes" class="form-control" value="y" {%if item.info.accessible %}checked="checked" {%endif%}required/></div>
                                    <div class="col-xs-1"><label class="col-xs-1 control-label">Ei</label><input type="radio" name="accessible" id="accessno" class="form-control" value="n" {%if not item.info.accessible %}checked="checked" {%endif%}required/></div>
                                </div>
                                <div class="form-group">
                                    <label class="col-xs-2 control-label" for="agency">Liikennöitsijä</label>
                                    <div class="col-xs-10">
                                        <input type="text" class="form-control" name="agency" id="agency" value="{{item.info.agency}}"/>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label class="col-xs-2 control-label" for="phone">Puhelinnumero</label>
                                    <div class="col-xs-10">
                                        <input type="text" class="form-control" name="phone" id="phone" value="{{item.info.phone}}"/>
                                    </div>
                                </div>
                            </div>
                        </div>

                    </div>
                    <div role="tabpanel" class="tab-pane" id="sv">{{localized_info_inputs('ruotsi','sv')}}</div>
                    <div role="tabpanel" class="tab-pane" id="en">{{localized_info_inputs('englanti','en')}}</div>
                </div>

        </div>
    </fieldset>
    {{xsrf_form_html()}}
    <button id="sbmt" type="submit" class="btn btn-success btn-lg">Tallenna tiedot</button>
    </form>
</div>
{% endblock %}


{% block script %}
    <script src="{{STATIC_URL}}js/moment-with-locales.js" type="text/javascript"></script>
    <script src="{{STATIC_URL}}js/bootstrap-datetimepicker.min.js" type="text/javascript"></script>
    <script src="{{STATIC_URL}}js/validator.min.js" type="text/javascript"></script>
    <script src="{{STATIC_URL}}js/form.js" type="text/javascript"></script>


{% endblock %}
