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
use Data::Dumper ();    #// need this! not 4 debug

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
    #// alyz data set

    #// file check
    my $file_base = do {
        my $_path = MyApp::Util::Common::makepath(
            base    => $configs->{path}->{base},
            target  => $configs->{path}->{seed}->{base_file},
        );

        +{
            path    => $_path,
            hash    => MyApp::Util::Common::hash( file => $_path ) || '',
            isok    => ( -r $_path ) ? 1 : 0,
            data    => MyApp::Util::Common::read_yaml( $_path ),
        };
    };
## $file_base

    my $file_work = do {
        my $_path = MyApp::Util::Common::makepath(
            base    => $configs->{path}->{base},
            target  => $configs->{path}->{seed}->{work_file},
        );

        my $_data = MyApp::Util::Common::read_yaml( $_path );
        +{
            path    => $_path,
            hash    => ( $_data ) ? $_data->{hash} : '',
            isok    => ( $_data ) ? 1 : 0,
            data    => ( $_data ) ? $_data : '',
        };
    };
## $file_work

    #:: my $need_remake = ( $file_base->{hash} ne $file_work->{hash} ) ? 1 : 0;
    my $need_remake = (
        0
        or ( $file_base->{hash} ne $file_work->{hash} )
        or ( scalar @{ $file_base->{data}->{elements} } < $file_work->{data}->{next} )
    ) ? 1 : 0;

## $need_remake
    if ( $need_remake ) {
        MyApp::Util::Common::save_yaml(
            $file_work->{path}  => +{
                next    => 0,
                hash    => $file_base->{hash},
                data    => +{
                    elements    => [ MyApp::Util::Common::randomize(
                        $file_base->{data}->{elements}
                    ) ]
                },
            },
        );

        $file_work = do {
            my $_data = MyApp::Util::Common::read_yaml( $file_work->{path} );
            +{
                path    => $file_work->{path} ,
                hash    => ( $_data ) ? $_data->{hash} : '',
                isok    => ( $_data ) ? 1 : 0,
                data    => ( $_data ) ? $_data : '',
            };
        };
    }

    my $data = $file_work->{data}
        or die "something wrong...";
## $data


    #// set
    my $target = $data->{data}->{elements}->[ $data->{next}++ ];
## $target

    #// update 4 stat
    MyApp::Util::Common::save_yaml( $file_work->{path}  => $data );


    #// return
    #:: print MyApp::Util::Common::make_yaml( +{
    #:: } );
    utf8::decode( $target );
    print MyApp::Util::Common::make_yaml( +{
        title => undef,
        entry => [ {
            title => undef,
            body => $target,
        } ],
    } );
};

exit 0;


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
            seed    => +{
                base_file => [ qw{ conf bot_twitter_TW_USER_NAME simple_random_seed.yaml } ],
                work_file => [ qw{ data cache work simple_random_seed.yaml } ],
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
