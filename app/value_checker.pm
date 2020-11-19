package value_checker;

use warnings;
use strict;
use experimental 'smartmatch';


#
# [
#   ['_value_', 'type', 'condition1,cond2,...', 'return msg if error'],
#
#		Examples:
#   [1, 'int', '>=0,<=10', 'value must be [0-10]']
#   ['12.33', 'float', '>=0', 'invalid value']
#   [11, 'in_table', 'TABLE_NAME,KEY_FIELD', 'invalid value']
# ]
#
#	SUPPORTED 'type' and 'condition(s)' for this type
#	int|bigint:	>x, <x, >=x, <=x, <>x, !=x =x ==x
# float|bigfloat: >x, <x, >=x, <=x, <>x, !=x =x ==x
# date: >x, <x, >=x, <=x, <>x, !=x =x ==x
# datetime: >x, <x, >=x, <=x, <>x, !=x =x ==x
# time: >x, <x, >=x, <=x, <>x, !=x =x ==x
# string: >x, <x, >=x, <=x, <>x, !=x =x ==x		## !!!! LENGTH() will be checked !!!!
# inlist: aa,b,cc,x,123 or ARRAYREF
# bool:		# can be '0' or '1'
# rx: regular expression to match (example: '^\d+$' - must be digit(s) )
# rxi: same as rx BUT IGNORE CASE is ON!
# in_table: SHOULD define 'RecordExists' functions
# record_exist(s)?: SHOULD define RecordExists


sub	CheckValues ($;$) {
	my ($arr, $db) = @_;
	
	
	foreach my $check_arr (@{$arr}) {
		my ($val, $type, $cond, $msg) = @{$check_arr};
		
		##### $val //= '';   #NOT GLOBAL
		$msg = 'Error in val: ' . (defined $val ? $val : 'undef') unless $msg;
		
		if (($type eq 'int') || ($type eq 'bigint')) {
			$val //= '';
			return $msg if $val !~ /^[\+\-]?\d+$/o;
			$val = Math::BigInt->new($val) if ($type eq 'bigint');
			return $msg if ! &CheckConditions($val, $cond);
			next;
		};
		
		if ($type eq 'bool') {
			$val //= '';
			return $msg if $val !~ /^[01]$/o;
			next;
		};
		
		if (($type eq 'float') || ($type eq 'bigfloat')) {
			$val //= '';
			return $msg if $val !~ /^[\+\-]?\d+(\.\d*)?(e[\-\+]\d+)?$/o;
			$val = Math::BigFloat->new($val) if ($type eq 'bigfloat');
			return $msg if ! &CheckConditions($val, $cond);
			next;
		};
		
		if ($type eq 'date') {
			$val //= '';
			return $msg if $val !~ /^\d\d\d\d\-\d\d?\-\d\d?$/o;
			return $msg if ! &CheckConditions($val, $cond);
			next;
		};
		
		if ($type eq 'time') {
			$val //= '';
			return $msg if $val !~ /^\d\d?\:\d\d?\:\d\d?$/o;
			return $msg if ! &CheckConditions($val, $cond);
			next;
		};
		
		if ($type eq 'datetime') {
			$val //= '';
			return $msg if $val !~ /^\d\d\d\d\-\d\d?\-\d\d? \d\d?\:\d\d?\:\d\d?$/o;
			return $msg if ! &CheckConditions($val, $cond);
			next;
		};
		
		if ($type eq 'string') {
			$val //= '';
			return $msg if ! &CheckConditions(length($val), $cond);
			next;
		};
		
		if ($type eq 'inlist') {
			$val //= '';
			my $found = 0;
			
			if (ref($cond) eq 'ARRAY') {
				$found = 1 if $val ~~ $cond;
			} else {
				foreach my $item ( split(/\,/, $cond) ) {
					if ($val eq $item) {
						$found = 1;
						last;
					};				
				};
			};
			
			return $msg if ! $found;
			next;
		};
		
		if ($type eq 'rx') {
			$val //= '';
			return $msg if $val !~ /$cond/;
			next;
		};
		
		if ($type eq '!rx') {
			$val //= '';
			return $msg if $val =~ /$cond/;
			next;
		};
		
		if ($type eq 'rxi') {
			$val //= '';
			return $msg if $val !~ /$cond/i;
			next;
		};
		
		if ($type eq '!rxi') {
			$val //= '';
			return $msg if $val =~ /$cond/i;
			next;
		};
		
		if ($type =~ m/^\!?in_?table/o) {		# intable, !intable, in_table, !in_table
			my ($table, $field, $where) = ($cond =~ m!^(.*?)\,(.*?)(?:\s*|\,(.*))?$!o);
			my $reverse_result = 1 if $type =~ m/^\!/;
			
			return $msg unless ($table && $field);
			return $msg unless ($field && defined $val) || $where;			# val can be 0
			
			$db //= &GetDBConnection();
			my $sql = "SELECT `$field` FROM `$table` WHERE ";
			
			if (defined $val) {
				my $val_safe = $db->PrepareSqlString($val);
				$sql .= " (`$field` = '$val_safe') " . ($where ? " AND $where " : '');
			} else {
				$sql .= $where;
			};
			
			
			$db->ExecSQL("$sql LIMIT 1");
			my $rec_exists = $db->Next ? 1 : 0;
			
			if ($reverse_result) {
				return $msg if $rec_exists;
			} else {
				return $msg unless $rec_exists;
			};
			
			next;
		};
		
		if ($type =~ m!^\!?record_exists?$!o) {
			my $reverse_result = 1 if $type =~ m/^\!/o;
			
			$db //= &GetDBConnection();
			$db->ExecSQL($cond);
			my $rec_exists = $db->Next ? 1 : 0;
			
			if ($reverse_result) {
				return $msg if $rec_exists;
			} else {
				return $msg unless $rec_exists;
			};
			
			next;
		};
		
		return 'INVALID type: ' . $type;		
	};
	
	
	#all ok
	return '';
};


sub	CheckConditions {
	my ($val, $conditions) = @_;
	
	foreach my $cond ( split(/\,/, $conditions) ) {
		chomp($cond);
		
		#'>=' should be BEFORE just '>'
		
		if ( ( $cond =~ /^\!\=(.*)$/o ) || ( $cond =~ /^\<\>(.*)$/o ) ) {
			return 0 unless ( ! ($val == $1) );
			next;
		};
		
		if ( $cond =~ /^\>\=(.*)$/o ) {
			return 0 unless ( $val >= $1 );
			next;
		};
		
		
		if ( $cond =~ /^\<\=(.*)$/o ) {
			return 0 unless ( $val <= $1 );
			next;
		};
		
		
		if ( $cond =~ /^\=\=?(.*)$/o ) {
			return 0 unless ($val == $1);
			next;
		};
		
		
		if ( $cond =~ /^\>(.*)$/o ) {
			return 0 unless ( $val > $1 );
			next;
		};
		

		if ( $cond =~ /^\<(.*)$/o ) {
			return 0 unless ( $val < $1 );
			next;
		};
		
	};
	
	return 1;
};

1;