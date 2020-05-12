package StatsSnap::Partners::Matomy;

use strict;

sub run {
    my $self = shift;
    my %args = @_;

    my $driver      = $args{driver};
    my $username    = $args{username};
    my $password    = $args{password};
    my $sleep       = $args{sleep} || 8;
    my $start_date  = $args{start_date};
    my $end_date    = $args{end_date};

    $driver->get( 'http://publishers.matomymobile.com/join.mat' );
    $driver->find_element( 'username', 'id' )->send_keys( $username );
    $driver->find_element( 'password_placeholder', 'id' )->send_keys( $password );
    $driver->find_element( 'password', 'id' )->send_keys( $password );
    $driver->find_element( 'signin_button', 'id' )->click();
    $driver->find_element( 'timeFrame', 'id' )->send_keys('2'); # yesterday
    sleep( $sleep );

    return( $driver );
}

1;

