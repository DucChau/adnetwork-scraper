#!/usr/bin/perl -w

use strict;
use lib "/apps/perl5/lib/perl5";
use Data::Dumper;
use DateTime;
use File::Path;
use Config::General;
use Getopt::Long;
use Selenium::Remote::Driver;
use StatsSnap::Utils;
use StatsSnap::Logger;
use StatsSnap::DA::Accounts;

my $conf_file           = "conf/stats_collector.conf";
my $c                   = new Config::General( $conf_file );
my %config              = $c->getall();

my $opt_account_id = undef;
my $opt_source_id = undef;
my $opt_verbose = 0;
my $opt_help = 0;

GetOptions(
    'help'         => \$opt_help,
    'verbose'      => \$opt_verbose,
    'account_id=i' => \$opt_account_id,
    'source_id=i'  => \$opt_source_id,
);

_usage() if ( $opt_help );

my $output_directory    = join( '/', $config{default}{output_directory}, time() );   

mkdir( $output_directory ) if ( ! -e $output_directory );

my $retries = $config{default}{collection_retry};

my $log_obj = new StatsSnap::Logger({ verbose      => $opt_verbose,
                                      logpath      => $config{logger}{path},
                                      logfile      => $config{logger}{file}});
$log_obj->init();

my $logger = $log_obj->get_log(__PACKAGE__);

$logger->info( "**** Starting Stats Collector ****" );

my $a = StatsSnap::DA::Accounts->new({
    rest_server     => $config{default}{rest_server},
    rest_username   => $config{default}{rest_username},
    rest_key        => $config{default}{rest_key},
});

my $accounts = $a->load_accounts();

foreach my $account_id ( keys %{$accounts} ) {
    
    if ( $opt_account_id ) {
        next unless ( $account_id == $opt_account_id );
    }

    my $sources = $a->load_account_sources( account_id => $account_id );

    next unless $sources;

    foreach my $source_id ( keys %{$sources} ) {

        if ( $opt_source_id ) {
            next unless ( $source_id == $opt_source_id );
        }
    
        my $username = $sources->{$source_id}->{login};
        my $password = $sources->{$source_id}->{password};
        my $partner = $config{sources}{$source_id};
        
        if ( $partner ) {
            $logger->info( " collecting data on $partner for $username" );
        }
        else {
            $logger->info( " cannot find partner mapping for source id: $source_id" );
            next;
        }
            
        my $driver = Selenium::Remote::Driver->new( remote_server_addr => $config{selenium}{server}, platform => $config{selenium}{platform} );
    

        eval( "use StatsSnap::Partners::" . $partner );

        my $retry = $retries;

        do {
            eval {   
                $logger->info( " try# $retry" );
                $driver = "StatsSnap::Partners::$partner"->run( driver => $driver, username => $username, password => $password );
            };
            $retry--;
        }
        until( ! $@ || $retry == 0 );

        my $screenshot_contents = $driver->screenshot();
        my $screenshot_file = join( "/", $output_directory, $account_id . '-' . $source_id . '-' . $partner . ".png" );

        $logger->info( " writing screenshot: $screenshot_file" );
        StatsSnap::Utils->write_file( file => $screenshot_file, contents => $screenshot_contents, encoding => StatsSnap::Utils::ENCODING_BASE64 );

        my $page_contents = $driver->get_page_source();
        my $page_file = join( "/", $output_directory, $account_id . '-' . $source_id . '-' . $partner . ".html" );

        $logger->info( " writing html: $page_file"  );
        StatsSnap::Utils->write_file( file => $page_file, contents => $page_contents );

        my $xml_file = join( "/", $output_directory, $account_id . '-' . $source_id . '-' . $partner . ".xml" );
        $logger->info( " writing xml: $xml_file"  );
        StatsSnap::Utils->run( command => "./parser.pl --infile $page_file --outfile $xml_file --source_id $source_id" );

        $driver->quit();
    }

}

$logger->info( "**** Stopping Stats Collector ****" );

sub _usage {
    my $usage = qq[
Usage:      $0
Examples:   $0 --account_id "2000"
            $0 --account_id "2000" --source_id "8"

Optional:   
            --help          Displays this help menu
            --verbose       Dump contents of logs to screen
            --account_id    Only collect data from sources associated with this account_id
            --source_id     Only collect data from this source_id
];  

    print "$usage\n";
    exit;
}


1;
