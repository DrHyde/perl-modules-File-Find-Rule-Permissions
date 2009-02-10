#!/usr/bin/perl -w

my $loaded;

use strict;

BEGIN { $| = 1; print "1..2\n"; }
END { print "not ok 1\n" unless $loaded; }

use File::Find::Rule::Permissions;

$loaded=1;
print "ok 1\n";

# more tests needed, but there are "issues" with running them.  See
# the docs for some comments on this ...

print "not ok 2 handle 'other' perm bits\n";
