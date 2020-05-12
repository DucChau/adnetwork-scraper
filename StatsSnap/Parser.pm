package StatsSnap::Parser;

use strict;
use HTML::Entities;
use HTML::TokeParser;
use Data::Dumper;

sub new {
    my $class = shift;
    $class = ref($class) || $class;

    my $args = shift;

    my $self = ref $args eq "HASH" ? {%$args} : {};

    return bless $self, $class;
}

sub run {
    my $self = shift;
    my %args = @_;
   
    my $file = $self->{file} || $args{file};
    my $adunit_label = $self->{adunit_label} || $args{adunit_label};
    my $adunit_field = $self->{adunit_field} || $args{adunit_field};
    my $iterations_before_data_starts = $self->{iterations_before_start} || $args{iterations_before_start};
    my $field_labels = $self->{field_labels} || $args{field_labels};
    my $field_count = $self->{field_count} || $args{field_count};
    my $tag = $self->{tag} || $args{tag};

    my $p = HTML::TokeParser->new( $file );

    # support for multiple tags
    my @tags;

    foreach my $t ( split( ',', $tag ) ) {
        $t =~ s/^\s+//g;
        $t =~ s/\s+$//g;
        push( @tags, $t );
    }

    my $record;
    my ( $data_set_hash, @data_set_list );
    my $field = 0;

    while ( my $token = $p->get_tag( @tags ) ) {

        if ( $iterations_before_data_starts != 0 ) {
            $iterations_before_data_starts--;
            next;
        }

        my $value = $p->get_trimmed_text();

        $field++;

        if ( $field_labels->{$field} ) {
            $record->{$field_labels->{$field}} = $value;
        }
        
        if ( $field == $field_count ) {
            my $adunit = $adunit_field ? encode_entities( $record->{$adunit_field} ) : encode_entities( $adunit_label );
            $record->{adunit} = $adunit;
            push( @data_set_list, $record )
                unless ( $record->{date} =~ /total/i || ! $record->{date} );
            $record = {};
            $field = 0;
        }

    }

    return ( \@data_set_list );

}

1;
