package StatsSnap::Partners::AdMob;

use strict;

sub run {
    my $self = shift;
    my %args = @_;

    my $driver      = $args{driver};
    my $username    = $args{username};
    my $password    = $args{password};
    my $sleep       = $args{sleep} || 5;

    $driver->get( 'https://www.google.com/accounts/ServiceLogin?service=admob&hl=en_US&continue=https%3A%2F%2Fwww.admob.com%2Fhome%2Flogin%2Fgoogle%3F&followup=https%3A%2F%2Fwww.admob.com%2Fhome%2Flogin%2Fgoogle%3F' );
    sleep( $sleep );
    $driver->find_element( 'Email', 'id' )->send_keys( $username );
    $driver->find_element( 'Passwd', 'id' )->send_keys( $password );
    $driver->find_element( 'signIn', 'id' )->click();
    sleep( $sleep );
    $driver->get( 'http://www.admob.com/reporting/sites' );
    
    return($driver);
}

1;

