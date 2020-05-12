package StatsSnap::Partners::AdSense;

use strict;

sub run {
    my $self = shift;
    my %args = @_;

    my $driver      = $args{driver};
    my $username    = $args{username};
    my $password    = $args{password};
    my $sleep       = $args{sleep} || 5;

    $driver->get( 'https://www.google.com/adsense' );
    sleep( $sleep );
    $driver->find_element( 'Email', 'id' )->send_keys( $username );
    $driver->find_element( 'Passwd', 'id' )->send_keys( $password );
    $driver->find_element( 'signIn', 'id' )->click();
    sleep( $sleep );
    $driver->get( 'https://www.google.com/adsense/v3/app#viewreports/d=last30days&ag=date%252Cchannel&dd=1YproductY1YAFMCYAdSense+for+Mobile+Content&ss=&oc=date&oo=descending&gm=earnings&co=d&sgs=&sgds=&drh=false&cc=&viewmode=1' );
    sleep( $sleep );
    
    return($driver);
}

1;

