package MyApp::Phrase::DivideSentence;


use strict;
use warnings;
use 5.008_001;

use utf8;
use Text::MeCab;
use YAML;

use MyApp::Phrase::Basis;
use MyApp::Phrase::More;
use MyApp::Algorithm::MarkovChainX;

use base qw( Class::Accessor::Fast );
__PACKAGE__->mk_accessors( qw( ds mc conf stash resultset ) );

use Smart::Comments;


sub init_ds {
    my $self = shift;

    $self->ds( Text::MeCab->new( @_ or %{ $self->conf->{ds} or {} } ) );
}

sub init_mc {
    my $self = shift;

    $self->mc( MyApp::Algorithm::MarkovChainX->new( @_ or %{ $self->conf->{mc} or {} } ) );
}


sub parse {
    my ( $self, $info ) = @_;

    return unless $info;
    $self->init_ds unless $self->ds;

    foreach my $line ( split "\n", $info ) {
        my $node = $self->ds->parse( $line );

        my $rep = 0;
        do {
            push @{ $self->{stash} }, +{
                word    => $node->surface,
                surf    => [ split /,/, $node->feature ]->[ 0 ],
                cost    => $node->cost,
                posh    => ( $rep++ ) ? 0 : 1,
            };
        } while ( $node = $node->next );

        #// drop eod mark: word[ BOS/EOS ]
        #:: pop @{ $self->{stash} };
    }

    $self->stash;
}

sub words {
    my ( $self, $info ) = @_;
    return unless $self->stash;

    my $stack;
    my $_tmp;

    map {
        if ( $_->{surf} eq qw{ BOS/EOS } ) {
            push @{ $stack }, $_tmp;
            $_tmp = '';
        }
        elsif( $_->{word} ) {
            $_tmp .= ( $_->{posh} ? '' : ' ' ) . $_->{word};
        }
    } @{ $self->{stash} };

    $stack;
}

sub clean {
    my ( $self, $info ) = @_;
    delete $self->{stash};
}


sub seed {
    my ( $self, $info ) = @_;

    return unless $info;

    $self->init_mc unless $self->mc;

    $self->mc->seed(
        symbols => $info,
        longest => 4,
    );
}

sub chunk {
    my $self = shift;
    my $ret = [ $self->mc->spew( @_ ) ];

    $self->resultset( $ret );
}

sub result {
    my $self = shift;
#:: my $info = splice( @_ );
    my $info = +{ @_ };

    ( $info->{ TYPE } eq qw{ YAML } )
    ? do {
            YAML::Dump( {
                title => "",
                entry => [ {
                    title   => "",
                    body    => join '', @{ $self->resultset },
                } ],
            } );
      }
    : do {
            join ( '', @{ $self->resultset } ), "\n";
      }
    ;
}


1;

