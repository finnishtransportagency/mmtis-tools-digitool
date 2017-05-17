<table class="table table-bordered table-condensed table-striped">
    <thead>
        <tr>
            <th>Kutsuliikenteen nimi</th>
            <th>Voimassaolo alkaa</th>
            <th>Voimassaolo päättyy</td>
            <th>Lähtöpaikka</th>
            <th>Määränpää</th>
            <th>Selite</th>
        </tr>
    </thead>
    <tbody>
    {% for i in items if i.maxend > now()%}
    <tr>
        <td><a href="{{reverse_url('view',i.item_id)}}">{{i.info.lang.fi.name}}</a></td>
        <td>{{fromtimestamp(i.minstart).strftime('%d.%m.%Y %H:%M')}}</td>
        <td>{{fromtimestamp(i.maxend).strftime('%d.%m.%Y %H:%M')}}</td>
        <td>{{i.info.lang.fi.startdesc|linkify}}</td>
        <td>{{i.info.lang.fi.enddesc|linkify}}</td>
        <td>{{i.info.lang.fi.desc|linkify}}</td>
    </tr>
    {% endfor %}
    </tbody>
</table>