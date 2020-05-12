package StatsSnap::Partners::Farlex;

use strict;

sub run {
    my $self = shift;
    my %args = @_;

    my $driver      = $args{driver};
    my $username    = $args{username};
    my $password    = $args{password};
    my $sleep       = $args{sleep} || 5;

    $driver->get( 'https://ns10.farlex.com/limited/partners.asp' );
    sleep( $sleep );
    $driver->find_element( 'pid', 'name' )->send_keys( $username );
    $driver->find_element( 'pwd', 'name' )->send_keys( $password );
    $driver->find_element( 'submit1', 'name' )->click();
    sleep( $sleep );
    
    return( $driver );
}

1;

