package MyApp::Phrase::LinguaJAX;


#// From Dan:[ http://blog.livedoor.jp/dankogai/archives/51220946.html ]

use strict;
use warnings;
use 5.008_001;

use utf8;
use charnames ':full';
use Unicode::Normalize;
{

    my $hankaku = "\x{FF9E}\x{FF9F}";
    my $zenkaku = "\x{3099}\x{309A}";

    for my $o ( 0xFF61 .. 0xFF9D ) {
        $hankaku .= chr $o;
        my $n = charnames::viacode($o);
        $n =~ s/HALFWIDTH\s+//;
        $zenkaku .= chr charnames::vianame($n);
    }

    *tr_h2z = eval "sub { local \$_ = shift; tr/$hankaku/$zenkaku/; \$_ }";
    *tr_z2h = eval "sub { local \$_ = shift; tr/$zenkaku/$hankaku/; \$_ }";

    sub han2zen { NFC( tr_h2z(shift) ) }
    sub zen2han { NFC( tr_z2h( NFD(shift) ) ) }

    sub hira2kata {
        local $_ = shift;
        tr/\x{3041}-\x{3096}/\x{30A1}-\x{30F6}/;
        $_;
    }
}

1;
