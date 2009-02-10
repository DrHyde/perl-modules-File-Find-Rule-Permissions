#!/usr/bin/perl -w

package # split, so as not to confuse stuff
    File::Find::Rule::Permissions::Tests;

use strict;
use File::Find::Rule::Permissions;

use vars qw($userid $groupid);

eval 'require "t/mock.pl"'; # must come after 'use FFRP'
eval 'require "t/testfiles.pl"';
if($@) { eval qq{
    use Test::More;
    plan skip_all => "$@";
    exit(0);
}} else { eval q{
    use Test::More tests => 25;
}}

# define some regexen for filtering the list of files
my $RSET = '[4567]'; my $RUNSET = '[0123]';
my $WSET = '[2367]'; my $WUNSET = '[0145]';
my $XSET = '[1357]'; my $XUNSET = '[0246]';

$userid  = 1;
$groupid = 0;
File::Find::Rule::Permissions::getusergroupdetails(
    users => { root => 0 },
    groups => { wheel => 0 },
    UIDinGID => { 0 => [0] }
);

my @allfiles = sort { $a cmp $b } File::Find::Rule::Permissions->file()->permissions(
    isReadable => 1,
    user => 'root'
)->in("t/testfiles");
ok(@allfiles == 512, "root can read all files");
@allfiles = sort { $a cmp $b } File::Find::Rule::Permissions->file()->permissions(
    isWriteable => 1,
    user => 'root'
)->in("t/testfiles");
ok(@allfiles == 512, "root can write all files");
is_deeply(
    [sort { $a cmp $b } File::Find::Rule::Permissions->file()->permissions(
        isReadable => 0,
        user       => 'root'
    )->in("t/testfiles")],
    [],
    "root can't *not* read anything (mmm, double negatives)"
);
is_deeply(
    [sort { $a cmp $b } File::Find::Rule::Permissions->file()->permissions(
        isWriteable => 0,
        user        => 'root'
    )->in("t/testfiles")],
    [],
    "root can't *not* write anything"
);
is_deeply(
    [sort { $a cmp $b } File::Find::Rule::Permissions->file()->permissions(
        isExecutable => 1,
        user         => 'root'
    )->in("t/testfiles")],
    [grep { /$XSET/ } @allfiles],
    "root can execute files that have an x bit set"
);
is_deeply(
    [sort { $a cmp $b } File::Find::Rule::Permissions->file()->permissions(
        isExecutable => 0,
        user         => 'root'
    )->in("t/testfiles")],
    [grep { $_ !~ /$XSET/ } @allfiles],
    "root can not execute files that don't have an x bit set"
);

# for this run, all files are owned by user1, group wheel
# user1's perms come from the U bits
# user2's perms come from the O bits
$userid  = 1;
$groupid = 2;
File::Find::Rule::Permissions::getusergroupdetails(
    users => { root => 0, user1 => 1, user2 => 2, user3 => 3 },
    groups => { wheel => 0, group1 => 1, group2 => 2 },
    UIDinGID => { 0 => [0], 1 => [1, 2], 2 => [3] }
    # user1 and user2 are in group1, user3 is in group2
);
is_deeply(
    [sort { $a cmp $b } File::Find::Rule::Permissions->file()->permissions(
        isReadable => 1,
        user       => 'user1'
    )->in("t/testfiles")],
    [grep { $_ =~ m!^t/testfiles/0${RSET}..$! } @allfiles],
    "'user'  bits say if file is readable for owner"
);
is_deeply(
    [sort { $a cmp $b } File::Find::Rule::Permissions->file()->permissions(
        isReadable => 0,
        user       => 'user1'
    )->in("t/testfiles")],
    [grep { $_ =~ m!^t/testfiles/0${RUNSET}..$! } @allfiles],
    "'user'  bits say if file is NOT readable for owner"
);
is_deeply(
    [sort { $a cmp $b } File::Find::Rule::Permissions->file()->permissions(
        isReadable => 1,
        user       => 'user3'
    )->in("t/testfiles")],
    [grep { $_ =~ m!^t/testfiles/0.${RSET}.$! } @allfiles],
    "'group' bits say if file is readable for group members"
);
is_deeply(
    [sort { $a cmp $b } File::Find::Rule::Permissions->file()->permissions(
        isReadable => 0,
        user       => 'user3'
    )->in("t/testfiles")],
    [grep { $_ =~ m!^t/testfiles/0.${RUNSET}.$! } @allfiles],
    "'group' bits say if file is NOT readable for group members"
);
is_deeply(
    [sort { $a cmp $b } File::Find::Rule::Permissions->file()->permissions(
        isReadable => 1,
        user       => 'user2'
    )->in("t/testfiles")],
    [grep { $_ =~ m!^t/testfiles/0..${RSET}$! } @allfiles],
    "'other' bits say if file is readable for randoms"
);
is_deeply(
    [sort { $a cmp $b } File::Find::Rule::Permissions->file()->permissions(
        isReadable => 0,
        user       => 'user2'
    )->in("t/testfiles")],
    [grep { $_ =~ m!^t/testfiles/0..${RUNSET}$! } @allfiles],
    "'other' bits say if file is NOT readable for randoms"
);

is_deeply(
    [sort { $a cmp $b } File::Find::Rule::Permissions->file()->permissions(
        isWriteable => 1,
        user        => 'user1'
    )->in("t/testfiles")],
    [grep { $_ =~ m!^t/testfiles/0${WSET}..$! } @allfiles],
    "'user'  bits say if file is writeable for owner"
);
is_deeply(
    [sort { $a cmp $b } File::Find::Rule::Permissions->file()->permissions(
        isWriteable => 0,
        user        => 'user1'
    )->in("t/testfiles")],
    [grep { $_ =~ m!^t/testfiles/0${WUNSET}..$! } @allfiles],
    "'user'  bits say if file is NOT writeable for owner"
);
is_deeply(
    [sort { $a cmp $b } File::Find::Rule::Permissions->file()->permissions(
        isWriteable => 1,
        user        => 'user3'
    )->in("t/testfiles")],
    [grep { $_ =~ m!^t/testfiles/0.${WSET}.$! } @allfiles],
    "'group' bits say if file is writeable for group members"
);
is_deeply(
    [sort { $a cmp $b } File::Find::Rule::Permissions->file()->permissions(
        isWriteable => 0,
        user        => 'user3'
    )->in("t/testfiles")],
    [grep { $_ =~ m!^t/testfiles/0.${WUNSET}.$! } @allfiles],
    "'group' bits say if file is NOT writeable for group members"
);
is_deeply(
    [sort { $a cmp $b } File::Find::Rule::Permissions->file()->permissions(
        isWriteable => 1,
        user        => 'user2'
    )->in("t/testfiles")],
    [grep { $_ =~ m!^t/testfiles/0..${WSET}$! } @allfiles],
    "'other' bits say if file is writeable for randoms"
);
is_deeply(
    [sort { $a cmp $b } File::Find::Rule::Permissions->file()->permissions(
        isWriteable => 0,
        user        => 'user2'
    )->in("t/testfiles")],
    [grep { $_ =~ m!^t/testfiles/0..${WUNSET}$! } @allfiles],
    "'other' bits say if file is NOT writeable for randoms"
);

is_deeply(
    [sort { $a cmp $b } File::Find::Rule::Permissions->file()->permissions(
        isExecutable => 1,
        user         => 'user1'
    )->in("t/testfiles")],
    [grep { $_ =~ m!^t/testfiles/0${XSET}..$! } @allfiles],
    "'user'  bits say if file is executable for owner"
);
is_deeply(
    [sort { $a cmp $b } File::Find::Rule::Permissions->file()->permissions(
        isExecutable => 0,
        user         => 'user1'
    )->in("t/testfiles")],
    [grep { $_ =~ m!^t/testfiles/0${XUNSET}..$! } @allfiles],
    "'user'  bits say if file is NOT executable for owner"
);
is_deeply(
    [sort { $a cmp $b } File::Find::Rule::Permissions->file()->permissions(
        isExecutable => 1,
        user         => 'user3'
    )->in("t/testfiles")],
    [grep { $_ =~ m!^t/testfiles/0.${XSET}.$! } @allfiles],
    "'group' bits say if file is executable for group members"
);
is_deeply(
    [sort { $a cmp $b } File::Find::Rule::Permissions->file()->permissions(
        isExecutable => 0,
        user         => 'user3'
    )->in("t/testfiles")],
    [grep { $_ =~ m!^t/testfiles/0.${XUNSET}.$! } @allfiles],
    "'group' bits say if file is NOT executable for group members"
);
is_deeply(
    [sort { $a cmp $b } File::Find::Rule::Permissions->file()->permissions(
        isExecutable => 1,
        user         => 'user2'
    )->in("t/testfiles")],
    [grep { $_ =~ m!^t/testfiles/0..${XSET}$! } @allfiles],
    "'other' bits say if file is executable for randoms"
);
is_deeply(
    [sort { $a cmp $b } File::Find::Rule::Permissions->file()->permissions(
        isExecutable => 0,
        user         => 'user2'
    )->in("t/testfiles")],
    [grep { $_ =~ m!^t/testfiles/0..${XUNSET}$! } @allfiles],
    "'other' bits say if file is NOT executable for randoms"
);

is_deeply(
    [sort { $a cmp $b } File::Find::Rule::Permissions->file()->permissions(
        isReadable  => 1,
        isWriteable => 1,
        user        => 'user1'
    )->in("t/testfiles")],
    [grep { $_ =~ m!^t/testfiles/0${WSET}..$! }
     grep { $_ =~ m!^t/testfiles/0${RSET}..$! } @allfiles],
    "'user'  bits say if file is read/writeable for owner"
);
is_deeply(
    [sort { $a cmp $b } File::Find::Rule::Permissions->file()->permissions(
        isReadable  => 1,
        isWriteable => 0,
        user        => 'user2'
    )->in("t/testfiles")],
    [grep { $_ =~ m!^t/testfiles/0..${WUNSET}$! }
     grep { $_ =~ m!^t/testfiles/0..${RSET}$! } @allfiles],
    "'user'  bits say if file is readable, not writeable by randoms"
);
