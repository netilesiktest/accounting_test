package render;

use strict;
use warnings;

sub process_template {
    my ($template, $data) = @_;
    open(T, '<:utf8', 'templates/' . $template) || return ( 404, "No such template / can not open template. $!" );
    local $/ = undef;
    my $d = <T>;
    close T;

    #our template processing
    $d =~ s/\{\{CODE\:\:(.*?)\}\}/eval($1)/egs;

    return ( 200, $d );
};


sub formatdatetime {
	my $format = shift @_ || "YYYY-MM-DD hh:mm:ss";	
	my $datetime = shift @_ || time;
	
	my %strings=(
		'400' => "January", '401' => "February", '402' => "March", '403' => "April", '404' => "May", '405' => "June", '406' => "July", '407' => "August", '408' => "September", '409' => "October", '410' => "November", '411' => "December",
		'300' => "Jan", '301' => "Feb", '302' => "Mar", '303' => "Apr", '304' => "May", '305' => "Jun", '306' => "Jul", '307' => "Aug", '308' => "Sep", '309' => "Oct", '310' => "Nov", '311' => "Dec",
		'200' => "Sunday", '201' => "Monday", '202' => "Tuesday", '203' => "Wednesday", '204' => "Thursday", '205' => "Friday", '206' => "Saturday",
		'100' => "Sun", '101' => "Mon", '102' => "Tue", '103' => "Wed", '104' => "Thu", '105' => "Fri", '106' => "Sat"
	);
	
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($datetime);
	$year+=1900;
	if ($format=~m/AM/) {
		$format=~s/hh/sprintf("%02u",$hour % 12)/eg;
		$format=~s/h/$hour % 12/eg;
		$format=~s/AM/($hour>12?"PM":"AM")/eg;
	} else {
		$format=~s/hh/sprintf("%02u",$hour)/eg;
		$format=~s/h/$hour/eg;
	};
	$format=~s/mm/sprintf("%02u",$min)/eg;
	$format=~s/m/$min/eg;
	$format=~s/ss/sprintf("%02u",$sec)/eg;
	$format=~s/s/$sec/eg;

	$format=~s/YYYY/$year/eg;
	$format=~s/YY/sprintf("%02u",$year % 100)/eg;
	$format=~s/MMMM/sprintf("^4%02u",$mon)/eg;
	$format=~s/MMM/sprintf("^3%02u",$mon)/eg;
	$format=~s/MM/sprintf("%02u",$mon+1)/eg;
	$format=~s/([^AP])M/"$1".($mon+1)/eg;
	$format=~s/DDDD/sprintf("^2%02u",$wday)/eg;
	$format=~s/DDD/sprintf("^1%02u",$wday)/eg;
	$format=~s/DD/sprintf("%02u",$mday)/eg;
	$format=~s/D/$mday/eg;
	$format=~s/\^(\d\d\d)/$strings{$1}/g;
	return $format;
};


1;