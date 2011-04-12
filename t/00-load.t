#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'MonIt' ) || print "Bail out!\n";
}

diag( "Testing MonIt $MonIt::VERSION, Perl $], $^X" );
