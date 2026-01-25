#!/usr/bin/env perl
use Web::Microformats2;

if ($#ARGV != 0) {
    print "Usage: test-one.pl <inputfile>";
    exit 1;
}

my $file = $ARGV[0];
my $base = (index($file, "/microformats-v2-unit/") > -1) ? "http://example.test/" : "http://example.com";
my $input = do {
    local $/ = undef;
    open my $fh, "<", $file
        or die "could not open $file: $!";
    <$fh>;
};

my $parser = Web::Microformats2::Parser->new;
my %opts = ( url_context => $base );
my $json = $parser->parse( $input, %opts )->as_json;

print $json;

