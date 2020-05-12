#!/usr/bin/perl -w

use strict;
use lib "/apps/perl5/lib/perl5";
use Data::Dumper;
use DateTime;
use File::Path;
use Config::General;
use Getopt::Long;
use StatsSnap::Utils;
use StatsSnap::Logger;
use StatsSnap::DA::Accounts;
use StatsSnap::Parser;

my $conf_file   = "conf/stats_parser.conf";
my $c           = new Config::General( $conf_file );
my %config      = $c->getall();

my $opt_verbose     = 0;
my $opt_help        = 0;
my $opt_debug       = 0;
my $opt_infile      = undef;
my $opt_outfile     = undef;
my $opt_file        = undef;
my $opt_source_id   = undef;

GetOptions(
    'infile=s'      => \$opt_infile,
    'outfile=s'     => \$opt_outfile,
    'source_id=i'   => \$opt_source_id,
    'help'          => \$opt_help,
    'verbose'       => \$opt_verbose,
    'debug'         => \$opt_debug,
);

_usage() if ( $opt_help || ! $opt_infile || ! $opt_source_id );

my $log_obj = new StatsSnap::Logger({ verbose      => $opt_verbose,
                                      logpath      => $config{logger}{path},
                                      logfile      => $config{logger}{file}});
$log_obj->init();

my $logger = $log_obj->get_log(__PACKAGE__);

$logger->info( "**** Starting Stats Parser ****" );

my $infile                  = $opt_infile;
my $outfile                 = $opt_outfile;
my $source_id               = $opt_source_id;
my $iterations_before_start = $config{$opt_source_id}{iterations_before_start};
my $adunit_label            = $config{$opt_source_id}{adunit_label};
my $adunit_field            = $config{$opt_source_id}{adunit_field};
my $field_labels            = $config{$opt_source_id}{field_labels};
my $field_count             = $config{$opt_source_id}{field_count};
my $tag                     = $config{$opt_source_id}{tag};

$logger->info( "****  parsing $infile for source id $opt_source_id" );

my $parser = StatsSnap::Parser->new( { iterations_before_start => $iterations_before_start,
                                       file            => $infile,
                                       adunit_label    => $adunit_label,
                                       adunit_field    => $adunit_field,
                                       field_labels    => $field_labels,
                                       field_count     => $field_count,
                                       tag             => $tag } );

my ( $results ) = $parser->run();

my $template_args = {
    results     => $results,
    source      => {
        id          => $source_id,
        name        => $source_id,
        file        => $infile,
    },
    account     => {
        id          => '2000',
        login       => 'login',
        password    => 'password',
    },
    fetched_time    => scalar( localtime ),
    generated_time  => scalar( localtime ),
};

if ( $opt_debug ) {
    print Dumper( $template_args );
    exit;
}

my $output = StatsSnap::Utils->process_template(
    return   => 1,
    template => $config{templates}{raw2xml},
    data     => { args => $template_args }
);
       
if ( $outfile ) { 
    $logger->info( "****  writing out $outfile ****" );
    StatsSnap::Utils->write_file( file => $outfile, contents => $output );
}
else {
    print $output;
}

$logger->info( "**** Stopping Stats Parser ****" );
                                                     
sub _usage {
    my $usage = qq[
Usage:      $0
Examples:   $0 --infile "t/AdMob.html" --outfile "t/AdMob.xml" --source_id 1 --verbose

Required: 
            --infile        scraped html file
            --source_id     source id of file

Optional:   
            --help          displays this help menu
            --verbose       dump contents of logs to screen
            --outfile       output xml file
            --debug         dump of results
];  

    print "$usage\n";
    exit;
}


1;
