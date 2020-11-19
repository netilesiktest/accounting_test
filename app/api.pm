package api;

use strict;
use warnings;

require "./mydb.pm";
require "./value_checker.pm";
require "./model_account.pm";

sub process_request {
    my ($c, $type) = @_;

    my $db = mydb->new( db => 'DB.txt', model => 'model_account' );
    $db->load();


    if ( $type eq 'GET' ) {
        if ( defined $c->param('id') ) {
            my $model_obj = $db->get_by_id($c->param('id'));

            $model_obj and return (200, {
                status => 1,
                data => $model_obj->as_hash(),
            });

            return (404, {
                status => 0,
                data => 'Id not found',
            });
        } else {
            my $balance = 0;
            my $last_rec = $db->last();
            $balance = $last_rec->balance() if $last_rec;

            return (200, {
                status => 1,
                balance => $balance,
                data => $db->as_array(),
            });
        };       
        
        return (404, "Bad requst");
    }; 

    if ( $type eq 'POST' ) {
        my $values = [
            [$c->param('type'), 'inlist', 'credit,debit', 'Invalid input: type'],
            [$c->param('amount'), 'rx', '^\d+(\.\d+)?$', 'Invalid input: amount'],
            [$c->param('amount'), 'float', '>0', 'Invalid input: amount, Should be > 0'],
            [$c->param('effectiveDate'), 'rx', '^\d\d\d\d\-\d\d?\-\d\d?(T| )\d\d?\:\d\d?\:\d\d?(\.\d*Z?)?$', 'Invalid input: effectiveDate'],
        ];

        my $err = value_checker::CheckValues($values);
        return (400, $err) if $err;

        my $balance = 0;
        my $last_rec = $db->last();
        $balance = $last_rec->balance() if $last_rec;

        if ( ($c->param('type') eq 'credit') && ($balance - $c->param('amount') < 0) ) {
            return( 400, "Invalid input: Too big amount. Balance is less than amount." );
        };

        my $model = model_account->new({
            type => $c->param('type'),
            amount => $c->param('amount'),
            balance => ( $balance + ( $c->param('type') eq 'credit' ? -1 * $c->param('amount') : $c->param('amount') ) ),
            effectiveDate => $c->param('effectiveDate'),
            description => $c->param('description'),
        });

        $db->add($model);
        $db->commit();
        return (200, "transaction stored");
    };
};

1;