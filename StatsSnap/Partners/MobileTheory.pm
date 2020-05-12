package StatsSnap::Partners::MobileTheory;

use strict;

sub run {
    my $self = shift;
    my %args = @_;

    my $driver      = $args{driver};
    my $username    = $args{username};
    my $password    = $args{password};
    my $sleep       = $args{sleep} || 5;

    $driver->get( 'http://impel-mt.mobiletheory.com/login?returnto=' );
    $driver->find_element( 'msisdn', 'id' )->send_keys( $username );
    $driver->find_element( 'UsersPassword', 'id' )->send_keys( $password );
    $driver->find_element( 'submit', 'name' )->click();
    sleep( $sleep );
    $driver->find_element( 'date_options', 'id' )->send_keys( "last_30_days" );
    $driver->find_element( 'date_options', 'id' )->send_keys( "last_30_days" );
    $driver->find_element( 'date_options', 'id' )->send_keys( "last_30_days" );
    $driver->find_element( 'date_options', 'id' )->send_keys( "last_30_days" );
    sleep( $sleep );
    $driver->find_element( 'group_by_date_report1_href', 'id' )->click();
    sleep( $sleep );
 
    return($driver);
}

1;

