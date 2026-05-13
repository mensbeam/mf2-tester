#!/usr/bin/env perl
use Web::Microformats2;

if ($#ARGV != 1) {
    print "Usage: test-one.pl <input_file> <base_url>";
    exit 1;
}

my $file = $ARGV[0];
my $base = $ARGV[1];
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
