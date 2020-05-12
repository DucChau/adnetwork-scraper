package StatsSnap::Utils;

use MIME::Base64;
use Template;
use REST::Client;

use constant ENCODING_BASE64    => 'base64';
use constant MODE_APPEND        => '>>';
use constant MODE_OVERWRITE     => '>';

sub write_file {
    my $self = shift;
    my %args = @_;

    my $file        = $args{file};
    my $contents    = $args{contents};
    my $encoding    = $args{encoding} || '';
    my $mode        = $args{mode} || MODE_OVERWRITE;

    if ( $encoding eq ENCODING_BASE64 ) {
        open( FH, $mode, $file );
            binmode FH;
            print FH MIME::Base64::decode_base64( $contents );
        close FH;
    }
    else {
        open( FH, $mode, $file );
            binmode( FH, ":utf8" );
            print FH $contents;
        close FH;
    }

}

sub process_template {
    my $self = shift;
    my %args = @_;

    my $output;
   
    my $config = $args{'config'} || { RELATIVE => 1 }; 
    
    my $template = Template->new( $config );
    
    $args{'data'}->{'args'}->{'current_template'} = $args{'template'};

    my $rc = $template->process( $args{'template'}, $args{'data'}, \$output ) || die( $@ );

    return ( $output ) if ( $args{'return'} );   

    print $output;

    exit;
}

sub run {
    my $self = shift;
    my %args = @_;

    my @return_value;

    print $args{'command'} . "\n" if ( $args{'verbose'} );

    my $null = '';

    if ( $args{'supress_errors'} ) {
        $null = '2>/dev/null';
    } 

    if ( $args{'logger'} ) {
        $args{'logger'}->info( "  $args{'command'}" );
    }
    
    if ( $args{'background'} ) {
        $args{'command'} = $args{'command'} . ' &';
    }

    if ( $args{'return'} ) {
        @return_value = `$args{'command'} $null`;
    }
    else {
        `$args{'command'} $null`;
    }

    return ( @return_value );
}

sub get_rest {
    my $self = shift;
    my %args = @_;

    my $client = REST::Client->new();
    my $endpoint = $args{endpoint};

    eval {
        $client->GET( $endpoint );
    };

    if ( $@ || $client->responseCode() != 200 ) {
        $self->rthrow( message => "Failed to make request to: $endpoint ($@)" );
    }

    my $results = $client->responseContent();

    return ( $results ); 
}

sub rthrow {
    my $self = shift;
    my %args = @_;

    my $message = $args{message};

    die( $message );
}

1;
