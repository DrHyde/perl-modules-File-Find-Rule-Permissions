#!/usr/bin/perl -w

package # split, so as not to confuse stuff
    File::Find::Rule::Permissions::Tests;

use strict;
use File::Find::Rule::Permissions;

eval 'require "t/mock.pl"'; # must come after 'use FFRP'
eval 'require "t/testfiles.pl"';
if($@) { eval qq{
    use Test::More;
    plan skip_all => "$@";
}} else { eval q{
    # 12 == r, w, x for user, group, root, other
    use Test::More tests => (01000 * 12);
}}

my $userid  = 1;
my $groupid = 1;
File::Find::Rule::getusergroupdetails(
    users => { root => 0, user1 => 1, user2 => 2 },
    groups => { wheel => 0, group1 => 1 },
    UIDinGID => { 0 => [0], 1 => [1, 2] }  # user1 and user2 are in group1
);

# more tests needed, but there are "issues" with running them.  See
# the docs for some comments on this ...
