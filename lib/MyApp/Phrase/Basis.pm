package MyApp::Phrase::Basis;


use strict;
use warnings;
use 5.008_001;

use utf8;


sub trim {
    my ( $info ) = @_;

    return unless $info;
    $info =~ s{ (:? \A \s+ | \s+ \Z ) }{}msxg;
    $info;
}


sub monospace {
    my ( $info ) = @_;

    $info =~ s/ \x{3000} / /msxg;
    $info =~ s{ (:? \s+ ) }{ }msxg;
    $info;
}


1;
