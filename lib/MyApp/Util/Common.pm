package MyApp::Util::Common;


use strict;
use warnings;
#:: use 5.008_001;
#:: use utf8;

use File::Basename ();
use File::Spec ();
use YAML::Syck ();
use Digest::MD5 (); #// md5 md5_hex md5_base64
use List::Util ();
use IO::File;


use Smart::Comments;


sub cname {
    my $info = File::Basename::basename( @_
        || called_from( {
            depth   => 2,
            order   => 1,
        } )
    );

    return unless $info;
    my @list = split '\.', $info;

    pop @list if scalar @list > 1;
    join '.', @list;
}

sub called_from {
    my ( $info ) = @_;

    my $depth = $info->{depth} || 2;
    my $order = 1;

    my @lists = caller( $depth );
    my $ret = $lists[ $order ];

    $ret;
}

sub makepath {
    my $info = +{ @_ };

    File::Spec->catdir( $info->{base}, @{ $info->{target} } );
}


sub read_yaml {
    my ( $info ) = @_;

    return unless $info;
    return unless -r $info;
### $info

    $YAML::Syck::ImplicitTyping = 1;

    local $@;
    YAML::Syck::LoadFile( $info );
}

sub make_yaml {
    my ( $info ) = @_;

    return unless $info;
    YAML::Syck::Dump( $info );
}

sub save_yaml {
    YAML::Syck::DumpFile( @_ );
}

sub hash {
    my ( $type, $info ) = @_;
    return unless $type;

    my $ret;
    if ( lc $type eq qw{ file } and $info and -r $info ) {
        local $@;

        #:: open $fh, ">", $out_file or die "$out_file:$!";
        my $io = IO::File->new( $info, 'r' );
        $io->binmode( 'utf8' );
        $ret = Digest::MD5->new->addfile( $io )->hexdigest;
        $io->close;
    }
    elsif( lc $type eq qw{ data } and $info ) {
        $ret = Digest::MD5::md5_hex( $info );
    }

    $ret;
}


sub randomize {
    my ( $info ) = @_;
    return unless $info;
    return unless ref $info eq qw{ ARRAY };

    map {
        utf8::decode( $_ );
    } @{ $info };
    List::Util::shuffle( @{ $info } );
}


1;
