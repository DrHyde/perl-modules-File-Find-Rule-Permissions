#!/usr/bin/perl -w

my $loaded;

use strict;
use diagnostics;

BEGIN { $| = 1; print "1..1\n"; }
END { print "not ok 1\n" unless $loaded; }

use File::Find::Rule::Permissions;

$loaded=1;
print "ok 1\n";

# more tests needed, but there are "issues" with running them.  See
# the docs for some comments on this ...
