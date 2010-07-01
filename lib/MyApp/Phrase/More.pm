package MyApp::Phrase::More;


use strict;
use warnings;
use 5.008_001;

use utf8;
use Lingua::JA::Regular::Unicode ();

#:: use base qw( MyApp::Phrase::Basis );
use MyApp::Phrase::Basis;

use Smart::Comments;




sub normalize {
    my ( $info ) = @_;
}

sub norm_basis {
    my ( $info ) = @_;

    chomp( $info = MyApp::Phrase::Basis::trim( $info ) );
    return unless $info;
    return if $info =~ m{ \A \# }msx;

    utf8::decode( $info );
    $info = Lingua::JA::Regular::Unicode::alnum_z2h( $info );
    utf8::encode( $info );

    $info;
}


sub parse2pure_phrase {
    my ( $info ) = @_;

    my $pat_drop_word = qr/(
        \p{CJKSymbolsAndPunctuation}+   |
        \x{99999}
    )/x;

    my $len_min = 3;
    my $len_max = 0;

    utf8::decode( $info );

    $info =~ s{$pat_drop_word}{ }g;
    $info = MyApp::Phrase::Basis::trim( $info );

    return unless $info;
    return if $info =~ m{ (:? ttp | http | https | ftp | tel ) }msx;
    return if ( $len_min > length( $info ) );
    return if ( $len_max and $len_max > length( $info ) );
    utf8::encode( $info );

    $info;
}


sub __hold_02__parse2pure_phrase {
    my ( $info ) = @_;

    my $pat_drop_word = qr/(
        \p{CJKSymbolsAndPunctuation}+   |
        \x{99999}
    )/x;

    my $len_min = 3;
    my $len_max = 0;

    utf8::decode( $info );

    #:: $info =~ s{[\,\!\?]+}{}g;
    $info =~ s{[\,\.]+}{}g;
    $info =~ s/\x{3001}/,/g;
    $info =~ s/\x{3002}/./g;
    $info =~ s{$pat_drop_word}{ }g;
    $info =~ s/\,/\x{3001}/g;
    $info =~ s/\./\x{3002}/g;

    $info = MyApp::Phrase::Basis::trim( $info );
    return unless $info;
    return if ( $len_min > length( $info ) );
    return if ( $len_max and $len_max > length( $info ) );
    utf8::encode( $info );

    $info;
}


sub parse_irc_log {
    my ( $info ) = @_;

    my @items = split /\s+/, $info;

    return unless $items[ 1 ] =~ m{ \A <\# .* \@2ch:take-bot_> \z }msx;
    return unless $items[ 2 ];

    $items[ 2 ];
}


1;
