#!perl

use strict;
use warnings;

cleanup();
mkdir("t/testfiles") || die("Can't mkdir t/testfiles\n");
foreach my $mode (map { sprintf("%04o", $_) } 0 .. 0777) {
    open(FILE, ">t/testfiles/$mode") || die("Can't create t/testfiles/$mode\n");
    print FILE $mode;
    close(FILE);
}

sub cleanup {
    foreach my $mode (map { sprintf("%04o", $_) } 0 .. 0777) {
        unlink "t/testfiles/$mode";
    }
    rmdir("t/testfiles");
}

END { cleanup() }

1;
