package StatsSnap::Partners::Mojiva;

use strict;

sub run {
    my $self = shift;
    my %args = @_;

    my $driver      = $args{driver};
    my $username    = $args{username};
    my $password    = $args{password};
    my $sleep       = $args{sleep} || 5;

    $driver->get( 'http://www.mojiva.com/login' );
    $driver->find_element( 'email', 'name' )->send_keys( $username );
    $driver->find_element( 'password', 'name' )->send_keys( $password );
    $driver->find_element( 'Submit', 'name' )->click();
    sleep( $sleep );
    $driver->get( 'http://www.mojiva.com/member/publisher' );
    sleep( $sleep );
    $driver->get( 'http://www.mojiva.com/publisher/reports/settype/type/D' );
    $driver->find_element( 'pagesize', 'class' )->click();
    $driver->find_element( 'pagesize', 'class' )->send_keys( "40" ); 
    
    return($driver);
}

1;

