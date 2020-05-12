package StatsSnap::Partners::AdSide;

use strict;

sub run {
    my $self = shift;
    my %args = @_;

    my $driver      = $args{driver};
    my $username    = $args{username};
    my $password    = $args{password};
    my $sleep       = $args{sleep} || 5;

    $driver->get( 'http://publisher.doclix.com/adserver/publisher/exit.jsp#' );
    $driver->execute_script( qq{showBlock('signline_opt');placeFocus(document.login);} );
    $driver->find_element( 'username', 'id' )->send_keys( $username );
    $driver->find_element( 'password', 'id' )->send_keys( $password );
    $driver->find_element( 'signInButton', 'id' )->click();
    $driver->get( 'http://publisher.doclix.com/adserver/publisher/report_pbd.jsp' );
    $driver->find_element( 'daterangedrop', 'id' )->send_keys( "L30" );
 
    sleep( $sleep );
    
    return($driver);
}

1;

