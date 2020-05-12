package StatsSnap::Partners::AdapTV;

use strict;

sub run {
    my $self = shift;
    my %args = @_;

    my $driver      = $args{driver};
    my $username    = $args{username};
    my $password    = $args{password};
    my $sleep       = $args{sleep} || 10;

    $driver->get( 'https://my.adap.tv/osclient/' );
    my $main = $driver->find_element( 'main', 'id' );
    $driver->mouse_move_to_location( element => $main, xoffset => 300, yoffset => 400 );
    sleep( $sleep );
    
    return($driver);
}

1;

