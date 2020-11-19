package model_account;

use strict;
use warnings;

sub new {
    my ($class, $record) = @_;

    my $h = {};

    if ( ref $record ) {

        $record->{description} //= '';
        $record->{description} =~ s/(\||\n|)//gios;

        $h = {
            type => $record->{type},
            amount => $record->{amount},
            balance => $record->{balance},
            effectiveDate => $record->{effectiveDate},
            description => $record->{description},        
        };

    } else {
        my @r = split(/\|/, $record);

        $h = {
            type => $r[0],
            amount => $r[1],
            balance => $r[2],
            effectiveDate => $r[3],
            description => ($r[4] // ""),
        };
    };

    return bless $h, $class;
};

sub balance {
    my ($self) = @_;
    return $self->{'balance'};
};

sub as_hash {
    my ($self) = @_;
    return {
        type => $self->{type},
        amount => $self->{amount},
        balance => $self->{balance},
        effectiveDate => $self->{effectiveDate},
        description => $self->{description},        
    };
};

sub raw {
    my ($self) = @_;
    return "$self->{type}|$self->{amount}|$self->{balance}|$self->{effectiveDate}|$self->{description}";
};

1;