package MyApp::Summarize;


use strict;
use warnings;
use 5.008_001;

use utf8;
use Lingua::JA::Summarize::Extract;
#:: use Encode;
#:: use Smart::Comments;


sub do {
    my ( $self, $info, $meta ) = @_;

    $meta->{length} ||= 80;
    $meta->{words_max} ||= 5;

    my $extracter = Lingua::JA::Summarize::Extract->new( {
        mecab_charset => 'utf8',
    } );
    my $summary = $extracter->extract( $info );
    $summary->length( $meta->{length} );
    my $result = $summary->as_string;
    $result;
}


sub top_words {
    my ( $self, $info, $meta ) = @_;

    $meta->{length} ||= 80;
    $meta->{words_max} ||= 5;

    my $extracter = Lingua::JA::Summarize::Extract->new( {
        mecab_charset => 'utf8',
    } );
    my $summary = $extracter->extract( $info );
    my $words;
    do {
        my $rep = 0;
        foreach my $item ( @{ $extracter->summarize } ) {
            last if ++$rep > $meta->{words_max};

            my $rip = 0;
            my $stk = '';
            foreach my $phrase ( @{ [ split ' ', $item->{term} ] } ) {
                $stk .= ( $rip++ ) ? substr( $phrase, 1, 1 ) : $phrase;
            }

            push @{ $words }, $stk;
        }
    };

    $words;
}

1;
