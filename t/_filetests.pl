#!/usr/bin/perl -w
    
use Test::More;
    
# define some regexen for filtering the list of files
my $RSET = '[4567]'; my $RUNSET = '[0123]';
my $WSET = '[2367]'; my $WUNSET = '[0145]';
my $XSET = '[1357]'; my $XUNSET = '[0246]';
    
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
    
sub user {
    my $user  = shift;
    is_deeply(
        [sort { $a cmp $b } File::Find::Rule::Permissions->file()->permissions(
            isReadable => 1,
            user       => $user
        )->in("t/testfiles")],
        [grep { $_ =~ m!^t/testfiles/0${RSET}..$! } @allfiles],
        "'user'  bits say if file is readable for owner"
    );
    is_deeply(
        [sort { $a cmp $b } File::Find::Rule::Permissions->file()->permissions(
            isReadable => 0,
            user       => $user
        )->in("t/testfiles")],
        [grep { $_ =~ m!^t/testfiles/0${RUNSET}..$! } @allfiles],
        "'user'  bits say if file is NOT readable for owner"
    );
    is_deeply(
        [sort { $a cmp $b } File::Find::Rule::Permissions->file()->permissions(
            isWriteable => 1,
            user        => $user
        )->in("t/testfiles")],
        [grep { $_ =~ m!^t/testfiles/0${WSET}..$! } @allfiles],
        "'user'  bits say if file is writeable for owner"
    );
    is_deeply(
        [sort { $a cmp $b } File::Find::Rule::Permissions->file()->permissions(
            isWriteable => 0,
            user        => $user
        )->in("t/testfiles")],
        [grep { $_ =~ m!^t/testfiles/0${WUNSET}..$! } @allfiles],
        "'user'  bits say if file is NOT writeable for owner"
    );
    is_deeply(
        [sort { $a cmp $b } File::Find::Rule::Permissions->file()->permissions(
            isExecutable => 1,
            user         => $user
        )->in("t/testfiles")],
        [grep { $_ =~ m!^t/testfiles/0${XSET}..$! } @allfiles],
        "'user'  bits say if file is executable for owner"
    );
    is_deeply(
        [sort { $a cmp $b } File::Find::Rule::Permissions->file()->permissions(
            isExecutable => 0,
            user         => $user
        )->in("t/testfiles")],
        [grep { $_ =~ m!^t/testfiles/0${XUNSET}..$! } @allfiles],
        "'user'  bits say if file is NOT executable for owner"
    );
    is_deeply(
        [sort { $a cmp $b } File::Find::Rule::Permissions->file()->permissions(
            isReadable  => 1,
            isWriteable => 1,
            user        => $user
        )->in("t/testfiles")],
        [grep { $_ =~ m!^t/testfiles/0${WSET}..$! }
         grep { $_ =~ m!^t/testfiles/0${RSET}..$! } @allfiles],
        "'user'  bits say if file is read/writeable for owner"
    );
}

sub group {
    my $user  = shift;
    is_deeply(
        [sort { $a cmp $b } File::Find::Rule::Permissions->file()->permissions(
            isReadable => 1,
            user       => $user
        )->in("t/testfiles")],
        [grep { $_ =~ m!^t/testfiles/0.${RSET}.$! } @allfiles],
        "'group' bits say if file is readable for group members"
    );
    is_deeply(
        [sort { $a cmp $b } File::Find::Rule::Permissions->file()->permissions(
            isReadable => 0,
            user       => $user
        )->in("t/testfiles")],
        [grep { $_ =~ m!^t/testfiles/0.${RUNSET}.$! } @allfiles],
        "'group' bits say if file is NOT readable for group members"
    );
    is_deeply(
        [sort { $a cmp $b } File::Find::Rule::Permissions->file()->permissions(
            isWriteable => 1,
            user        => $user
        )->in("t/testfiles")],
        [grep { $_ =~ m!^t/testfiles/0.${WSET}.$! } @allfiles],
        "'group' bits say if file is writeable for group members"
    );
    is_deeply(
        [sort { $a cmp $b } File::Find::Rule::Permissions->file()->permissions(
            isWriteable => 0,
            user        => $user
        )->in("t/testfiles")],
        [grep { $_ =~ m!^t/testfiles/0.${WUNSET}.$! } @allfiles],
        "'group' bits say if file is NOT writeable for group members"
    );
    is_deeply(
        [sort { $a cmp $b } File::Find::Rule::Permissions->file()->permissions(
            isExecutable => 1,
            user         => $user
        )->in("t/testfiles")],
        [grep { $_ =~ m!^t/testfiles/0.${XSET}.$! } @allfiles],
        "'group' bits say if file is executable for group members"
    );
    is_deeply(
        [sort { $a cmp $b } File::Find::Rule::Permissions->file()->permissions(
            isExecutable => 0,
            user         => $user
        )->in("t/testfiles")],
        [grep { $_ =~ m!^t/testfiles/0.${XUNSET}.$! } @allfiles],
        "'group' bits say if file is NOT executable for group members"
    );
}

sub other {
    my $user  = shift;
    is_deeply(
        [sort { $a cmp $b } File::Find::Rule::Permissions->file()->permissions(
            isReadable => 1,
            user       => $user
        )->in("t/testfiles")],
        [grep { $_ =~ m!^t/testfiles/0..${RSET}$! } @allfiles],
        "'other' bits say if file is readable for randoms"
    );
    is_deeply(
        [sort { $a cmp $b } File::Find::Rule::Permissions->file()->permissions(
            isReadable => 0,
            user       => $user
        )->in("t/testfiles")],
        [grep { $_ =~ m!^t/testfiles/0..${RUNSET}$! } @allfiles],
        "'other' bits say if file is NOT readable for randoms"
    );
    is_deeply(
        [sort { $a cmp $b } File::Find::Rule::Permissions->file()->permissions(
            isWriteable => 1,
            user        => $user
        )->in("t/testfiles")],
        [grep { $_ =~ m!^t/testfiles/0..${WSET}$! } @allfiles],
        "'other' bits say if file is writeable for randoms"
    );
    is_deeply(
        [sort { $a cmp $b } File::Find::Rule::Permissions->file()->permissions(
            isWriteable => 0,
            user        => $user
        )->in("t/testfiles")],
        [grep { $_ =~ m!^t/testfiles/0..${WUNSET}$! } @allfiles],
        "'other' bits say if file is NOT writeable for randoms"
    );
    is_deeply(
        [sort { $a cmp $b } File::Find::Rule::Permissions->file()->permissions(
            isExecutable => 1,
            user         => $user
        )->in("t/testfiles")],
        [grep { $_ =~ m!^t/testfiles/0..${XSET}$! } @allfiles],
        "'other' bits say if file is executable for randoms"
    );
    is_deeply(
        [sort { $a cmp $b } File::Find::Rule::Permissions->file()->permissions(
            isExecutable => 0,
            user         => $user
        )->in("t/testfiles")],
        [grep { $_ =~ m!^t/testfiles/0..${XUNSET}$! } @allfiles],
        "'other' bits say if file is NOT executable for randoms"
    );
    
    is_deeply(
        [sort { $a cmp $b } File::Find::Rule::Permissions->file()->permissions(
            isReadable  => 1,
            isWriteable => 0,
            user        => $user
        )->in("t/testfiles")],
        [grep { $_ =~ m!^t/testfiles/0..${WUNSET}$! }
         grep { $_ =~ m!^t/testfiles/0..${RSET}$! } @allfiles],
        "'other'  bits say if file is readable, not writeable by randoms"
    );
}
