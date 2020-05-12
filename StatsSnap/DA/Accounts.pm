package StatsSnap::DA::Accounts;

use strict;
use StatsSnap::Utils;
use DBI;
use JSON;

sub new {
    my $class = shift;
    $class = ref($class) || $class;

    my $args = shift;

    my $self = ref $args eq "HASH" ? {%$args} : {};

    return bless $self, $class;
}

sub load_accounts {
    my $self = shift;
    my %args = @_;

    my $json = JSON->new->allow_nonref;
    my $endpoint = $self->{rest_server} . '/account/?' . 'username=' . $self->{rest_username} . '&api_key=' . $self->{rest_key};
    my $accounts = StatsSnap::Utils->get_rest( endpoint => $endpoint );

    my $results;

    eval {
        foreach my $account ( @{$json->decode( $accounts )->{objects}} ) {
            $results->{$account->{account_id}} = $account;
        }
    };

    if ( $@ ) {
        StatsSnap::Utils->rthrow( message => "Failed to decode: $accounts ($@)" );
    }

    return ( $results );
}

sub load_account_sources {
    my $self = shift;
    my %args = @_;

    my $json = JSON->new->allow_nonref;
    my $account_id = $args{account_id};
    my $endpoint = $self->{rest_server} . '/account_source/?' . 'username=' . $self->{rest_username} . '&api_key=' . $self->{rest_key} . '&account_id=' . $account_id;
    my $sources = StatsSnap::Utils->get_rest( endpoint => $endpoint );

    my $results;

    eval {
        foreach my $source ( @{$json->decode( $sources )->{objects}} ) {
            $results->{$source->{source_id}} = $source;
        }
    };

    if ( $@ ) {
        StatsSnap::Utils->rthrow( message => "Failed to decode: $sources ($@)" );
    }

    return ( $results );
}

1;
