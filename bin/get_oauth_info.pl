#!/usr/bin/env perl

eval 'exec /usr/bin/env perl -S $0 ${1+"$@"}'
    if 0; # not running under some shell

use strict;
use warnings;
use utf8;
use Net::Twitter;

my $consumer_key = '';
my $consumer_key_secret = '';

my $nt = Net::Twitter->new(
  traits          => ['API::REST', 'OAuth'],
  consumer_key    => $consumer_key,
  consumer_secret => $consumer_key_secret,
);
print 'access this url by bot account : '.$nt->get_authorization_url."\n";
print 'input verifier PIN : ';
my $verifier = <STDIN>;
chomp $verifier;

my $token = $nt->request_token;
my $token_secret = $nt->request_token_secret;

$nt->request_token($token);
$nt->request_token_secret($token_secret);

my($at, $ats) = $nt->request_access_token(verifier => $verifier);

print "consumer key        : ", $consumer_key, "\n";
print "consumer key secret : ", $consumer_key_secret, "\n";

print "verifier pin : ", $verifier, "\n";

print "Access token        : ".$at."\n";
print "Access token secret : ".$ats."\n";

0;
