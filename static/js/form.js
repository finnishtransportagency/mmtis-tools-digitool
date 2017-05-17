$(function() {
    $('input[type=date]').each(function(k, elem) {
        $(elem).datetimepicker({
            format: 'DD.MM.YYYY',
            locale: 'fi',
            calendarWeeks: true
        });
    });

    $('input[type=time]').each(function(k, elem) {
        $(elem).datetimepicker({
            format: 'HH:mm',
            locale: 'fi',
            calendarWeeks: true
        });
    });

    $('#newTimeRow').click(function(e) {
        var startd = $('#startd').val();
        var endd = $('#endd').val();
        var startt = $('#startt').val();
        var endt = $('#endt').val();
        
        //console.log(startd,endd,startt,endt);
        if (!startd || !endd || !startt || !endt) {
          return;
        }

        $('#tdBody').append('<tr>' +
            '<td><input type="hidden" name="valid_startd" value="' + startd + '"/>' + startd + '</td>' +
            '<td><input type="hidden" name="valid_endd" value="' + endd + '"/>' + endd + '</td>' +
            '<td><input type="hidden" name="valid_startt" value="' + startt + '"/>' + startt + '</td>' +
            '<td><input type="hidden" name="valid_endt" value="' + endt + '"/>' + endt + '</td>' +
            '<td><button class="del_ex btn btn-warning btn-xs">Poista ajoaika</button></td>' +
            '</tr>');
        return false;
    });

    $('#tdBody').on('click', '.del_ex', function() {
        $(this).parent().parent().remove();
        return false;
    });


    $('#infoForm').validator().on('submit', function(e) {
        if (e.isDefaultPrevented()) {
            console.log('invalid!');
            // handle the invalid form...
        } else {
            console.log('Valid!');
            // everything looks good!
        }
    })
});