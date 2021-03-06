#!/usr/bin/env perl

eval 'exec /usr/bin/env perl -S $0 ${1+"$@"}'
    if 0; # not running under some shell

use strict;
use warnings;
use 5.008_001;

use utf8;
use FindBin;
use File::Basename ();
use File::Spec;

use Getopt::Long qw(:config no_ignore_case bundling);
use Pod::Usage;

use Smart::Comments;

use lib File::Spec->catdir( $FindBin::Bin, File::Spec->updir, qw{ lib } );
use MyApp::Util::Common;
use MyApp::Phrase::Basis;
use MyApp::Phrase::More;
use MyApp::Phrase::DivideSentence;


my $options = _get_option();
my $configs = _get_config();


do {
    my $ds = MyApp::Phrase::DivideSentence->new;
    $ds->conf( +{
        ds  => +{
            rcfile  => MyApp::Util::Common::makepath(
                base    => $configs->{path}->{base},
                target  => $configs->{path}->{mecab}->{rcfile},
            ),
        },
    } );

    while ( <> ) {
        last if ( $options->{limit} and $options->{limit} < $. );

        my $line = $_;
        $line = MyApp::Phrase::More::norm_basis       ( $line ) or next;

        do {
            $line = MyApp::Phrase::More::parse_irc_log    ( $line ) or next;
        } if $options->{irc_log};

        $line = MyApp::Phrase::More::parse2pure_phrase( $line ) or next;

        $ds->parse( $line );
    }

    my ( $words_all, $words_start ) = do {
        my ( $_sw, $_ss );
        map {
            my $_t = [ split ' ', $_ ];
            push @{ $_sw }, @{ $_t };
            push @{ $_ss }, $_t->[ 0 ];
        } @{ $ds->words };

        ( $_sw, $_ss->[ int rand scalar @{ $_ss } ] );
    };
## $words_start

    $ds->seed( $words_all );
    my $res = $ds->chunk(
        length => int rand 11 + 1,
        strict_start => 1,
        stop_at_terminal    => 1,
        complete    => [ $words_start ],
    );

    print $ds->result( TYPE => qw{ YAML } );
};


sub _get_option {
#   my ( $info ) = @_;
    my $ret;

    GetOptions(
        \%{ $ret },

        'help|h|?',
        'man',

        'separator|sep:s',
        'limit|lmt|l:i',
        'irc_log|irclog|irc',

    ) or _show_usage( -2 );

    _show_usage( 1 )
        if $ret->{help};

    _show_usage(
        -exitstatus => 0,
        -verbose => 2
    ) if $ret->{man};


    $ret;
}


sub _show_usage {
#   my ( $info ) = @_;
    pod2usage( @_ );
}


sub _get_config {
    my $_basis = +{
        path_base   => File::Spec->catdir( $FindBin::Bin, File::Spec->updir, ),
        pg_name     => File::Basename::basename( $0 ),
        cname       => MyApp::Util::Common::cname,
        process     => $$,
        #:: version     => do {
        #::        $Id$
        #:: },

    };

    my $ret = +{
        _env_   => $_basis,
        _make_  => +{
        noop    => 1,
        },

        info    => +{
            noop    => 1,
        },

        path    => +{
            base    => $_basis->{path_base},
            mecab   => +{
                rcfile => [ qw{ conf bot_twitter_TW_USER_NAME mecabrc } ],
            },
        },
    };

    $ret;
}



0;


__END__

=head1 NAME

sample - xxxxx

=head1 SYNOPSIS

sample [options] [file ...]

 Options:
   -help            brief help message
   -man             full documentation

=head1 OPTIONS

=over 8

=item B<-help>

Print a brief help message and exits.

=back

=head1 DESCRIPTION

B<This program> will read the given input file(s) and do something
useful with the contents thereof.

=cut
