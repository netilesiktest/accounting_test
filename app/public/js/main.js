
$('#refresh').click(function () {
    RefreshData();
});

$('#cancel').click(function () {
    $('#ADD_WND_MODAL').hide();
});

$('#debit').click(function () {
    AddOperation('debit');
});

$('#credit').click(function () {
    AddOperation('credit');
});

$('#addrec').click(function () {
    let post_data = 'type=' + $('#op_type').val();
    post_data += '&amount=' + $('#amount').val();
    post_data += '&effectiveDate=' + $('#date').val();
    post_data += '&description=' + $('#descr').val();
    

    $('#ADD_WND_MODAL').hide();
    $('#LOADING_WND_MODAL').show();

    $.ajax({
        type: 'POST',
        url: '/api/',
        dataType: 'text',
        global: false,
        data: post_data,
        timeout: 10000,
        async: true,
        cache: false
    })
    .done(
        function (in_data) {
            RefreshData();
        })
    .fail(
        function (req, text_status, text_err) {
            alert('request failed : ' + req.responseText);
            AddOperation('');
        })
    .always(
        function () {
            $('#LOADING_WND_MODAL').hide();
        }
    );
});

function AddOperation (type) {
    if (type) $('#op_type').val(type);
    $('#ADD_WND_MODAL').show();
};


function LoadDetails (id) {
    $('#LOADING_WND_MODAL').show();
    
    $.ajax({
        type: 'GET',
        url: '/api/?id=' + id,
        dataType: 'text',
        global: false,
        timeout: 10000,
        async: true,
        cache: false
    })
    .done(
        function (in_data) {
            let r = JSON.parse(in_data);
            let html = "";
            if (r.status == 1) {
                html = "Transaction details: \nID: " + id + "\n";
                html += "Amount: " + r.data.amount + "\n";
                html += "Date: " + r.data.effectiveDate + "\n";
                html += "Description: " + ( r.data.description ? r.data.description : '' ) + "\n";
            } else {
                html = r.data;
            };

           alert(html);
        })
    .fail(
        function (req, text_status, text_err) {
            alert('request failed : ' + req.responseText);
        })
    .always(
        function () {
            $('#LOADING_WND_MODAL').hide();
        }
    );
};


function RefreshData () {
    $('#LOADING_WND_MODAL').show();
    let tdata = $('#data');
    tdata.html('');

    $.ajax({
        type: 'GET',
        url: '/api/',
        dataType: 'text',
        global: false,
        timeout: 10000,
        async: true,
        cache: false
    })
    .done(
        function (in_data) {
            let r = JSON.parse(in_data);
            $('#bal').html('$' + r.balance);

            for (let i=0; i < r.data.length; i++) {
                let tr = '<tr onclick="LoadDetails(' + r.data[i].id + ')" class="' + r.data[i].type + '">';
                tr += '<td>' + r.data[i].effectiveDate + '</td>';
                tr += '<td>' + r.data[i].type + '</td>';
                tr += '<td>' + r.data[i].description + '</td>';
                tr += '<td>$' + r.data[i].amount + '</td>';
                tr += '</tr>';
                tdata.append(tr);
            };

        })
    .fail(
        function (req, text_status, text_err) {
            alert('request failed : ' + req.responseText);
        })
    .always(
        function () {
            $('#LOADING_WND_MODAL').hide();
        }
    );
};




$('#dt').DataTable({
    "paging": false,
    "searching": false,
    "autoWidth" : true,
    "info": false,
    "ordering": true,
    "order": [[ 0, "asc" ]],
    "data": [],
    
    "language": {
        "emptyTable": "No active records"
    }
});

RefreshData();