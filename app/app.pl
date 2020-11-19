
use Mojolicious::Lite -signatures;
use JSON;

use lib '.';
require "./api.pm";
require "./render.pm";
require "./mydb.pm";
require "./value_checker.pm";
require "./model_account.pm";

get '/' => sub {
    my $c = shift;
    my ($status, $text) = render::process_template('account.htmlt', {});
    $c->render(text => $text, status => $status);
};

get '/api/' => sub {
    my $c = shift;
    my ($status, $text) = api::process_request($c, 'GET');
    if ($status == 200) {
        $text = encode_json($text) if ref $text;
    };
    $c->render(text => $text, status => $status);
};

post '/api/' => sub {
    my $c = shift;
    my ($status, $text) = api::process_request($c, 'POST');
    if ($status == 200) {
        $text = encode_json($text) if ref $text;
    };
    $c->render(text => $text, status => $status);
};


app->start('daemon', '-l', 'http://*:8080');
