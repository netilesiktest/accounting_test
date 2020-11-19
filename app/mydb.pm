package mydb;

use strict;
use warnings;
use Fcntl qw(:flock);

sub new {
    my ($class, %params) = @_;

    return bless {
        'DB_file' => $params{'db'},
        'DB' => [],
        'model' => $params{'model'},        
        'F' => '',
    }, $class;
};

sub add {
    my ($self, $model) = @_;

    #checks here ... skipped  
    push( @{$self->{'DB'}}, $model );
};


sub get_by_id {
    my ($self, $id) = @_;
    return $self->{'DB'}->[$id] if scalar(@{$self->{'DB'}}) >= $id;
    return undef;
};

sub last {
    my ($self, $id) = @_;
    return $self->{'DB'}->[-1] if scalar(@{$self->{'DB'}});
    return undef;
};

sub as_array {
    my ($self) = @_;
    my $arr = [];

    my $i = 0;
    foreach my $obj (@{$self->{'DB'}}) {
        push(@{$arr}, {
            id => $i++,
            %{ $obj->as_hash() },
        });
    };

    return $arr;
};

sub load {
    my ($self) = @_;

    $self->{'DB'} = [];
    open(my $F, '<', $self->{'DB_file'}) || return 0;
    flock($F, LOCK_EX);

    while ( my $line = <$F> ) {
        chomp($line);
        my $model_obj = $self->{'model'}->new($line);
        push( @{$self->{'DB'}}, $model_obj );
    };
    
    $self->{'F'} = $F;

    return 1; 
};

sub commit {
    my ($self) = @_;

    flock($self->{'F'}, LOCK_UN);
    close $self->{'F'};

    #my here!
    open(my $F, '>:utf8', $self->{'DB_file'}) || return 0;
    flock($F, LOCK_EX);

    my $i = 0;
    foreach my $model_object ( @{$self->{'DB'}} ) {
        print $F $model_object->raw() . "\n";
    };

    flock($F, LOCK_UN);
    close $F;
    return 1; 
};


1;