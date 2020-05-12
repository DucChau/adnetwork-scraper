package StatsSnap::Logger;

=head1 SYNOPSIS

  my $logger = new Rubicon::Core::Base::Logger({
    'verbose'   => $verbose,
    'logpath'   => "/tmp",
    'logfile'   => "fubar.log",
  });

  $logger->init();

  my $log = $logger->get_log(__PACKAGE__);

=head1 DESCRIPTION

Log4perl Wrapper

You should be able to statically call this logger from any package,
so the package will not need an instance of a logger.

=cut

use strict;
use warnings;
use Carp;
use Data::Dumper;
use File::Path;
use File::Basename;
use Log::Log4perl;
use Log::Log4perl::Appender;
use Log::Log4perl::Level;

sub new
{
    my $class = shift;
    my $self  = shift;

    $self->{'logpath'} ||= $ENV{'HOME'} . "/logs";
    $self->{'logfile'} ||= basename($0) . '.log';

    return bless $self, $class;
}

sub init
{
    my $self    = shift;
    my $logpath = $self->{'logpath'};

    unless ( -e $logpath ) {
        mkpath($logpath) or croak $!;
    }

    my $config = $self->create_config();
    Log::Log4perl->init_once( \$config ) or croak;
}

sub create_config
{
    my $self    = shift;
    my $logpath = $self->{'logpath'}
        or croak 'missing logpath: ' . Dumper($self);
    my $logfile = $self->{'logfile'}
        or croak 'missing logfile: ' . Dumper($self);
    my $warnlog = $self->{'warnlog'} || $logfile . '.warnings.log';
    my $info    = $self->{'info'};
    my $warn    = $self->{'warn'};
    my $verbose = $self->{'verbose'};
    my $debug   = $self->{'debug'};
    my $quiet   = $self->{'quiet'};

    my $abslogfile = "$logpath/$logfile";
    my $abswarnlog = "$logpath/$warnlog";

    my $log4perl_level = "INFO";
    $log4perl_level = "ERROR" if $quiet;
    $log4perl_level = "DEBUG" if $debug;

    ### Always log to logfile, add screen if verbose
    my $log4perl_root = "log4perl.rootLogger=$log4perl_level, LOGFILE";
    $log4perl_root .= ", WARNLOG" if $warn;
    $log4perl_root .= ", SCREEN"  if $verbose;

    my $pattern = '%d %5P %c %4L: %m%n';

    my $config = qq{
    $log4perl_root

    ### Filters (these aren't working for some reason)
    log4perl.filter.MatchError = Log::Log4perl::Filter::LevelRange
    log4perl.filter.MatchError.LevelMin = ERROR
    log4perl.filter.MatchError.AcceptOnMatch = true

    log4perl.filter.MatchWarn  = Log::Log4perl::Filter::LevelRange
    log4perl.filter.MatchWarn.LevelMin  = WARN
    log4perl.filter.MatchWarn.AcceptOnMatch = true
    
    log4perl.filter.MatchInfo  = Log::Log4perl::Filter::LevelRange
    log4perl.filter.MatchInfo.LevelToMatch  = INFO
    log4perl.filter.MatchInfo.AcceptOnMatch = true
    
    ### Appenders
    log4perl.appender.SCREEN         = Log::Log4perl::Appender::Screen
    log4perl.appender.SCREEN.mode    = append
    log4perl.appender.SCREEN.stderr  = 0
    log4perl.appender.SCREEN.recreate  = 1
    log4perl.appender.SCREEN.layout  = Log::Log4perl::Layout::PatternLayout
    log4perl.appender.SCREEN.layout.ConversionPattern  = $pattern
    
    log4perl.appender.LOGFILE        = Log::Log4perl::Appender::File
    log4perl.appender.LOGFILE.filename = $abslogfile
    log4perl.appender.LOGFILE.mode   = append
    log4perl.appender.LOGFILE.syswrite   = 1
    log4perl.appender.LOGFILE.recreate   = 1
    log4perl.appender.LOGFILE.layout=PatternLayout
    log4perl.appender.LOGFILE.layout.ConversionPattern = $pattern
    #log4perl.appender.LOGFILE.Filter = MatchInfo

    log4perl.appender.WARNLOG        = Log::Log4perl::Appender::File
    log4perl.appender.WARNLOG.filename = $abswarnlog
    log4perl.appender.WARNLOG.mode   = append
    log4perl.appender.WARNLOG.recreate   = 1
    log4perl.appender.WARNLOG.layout=PatternLayout
    log4perl.appender.WARNLOG.layout.ConversionPattern = $pattern
    #log4perl.appender.WARNLOG.Filter = MatchWarn
    };

    #    print $config if $debug;

    return $config;
}

sub get_log
{
    my $self     = shift;
    my $category = shift;
    my $log      = Log::Log4perl->get_logger($category) or croak;
    return $log;
}

1;

