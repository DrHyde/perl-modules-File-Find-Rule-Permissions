#!perl

use strict;
use warnings;
mkdir("t/testfiles") || die("Can't mkdir t/testfiles\n");
foreach (0 .. 0777) {
    open(FILE, ">t/testfiles/$_") || die("Can't create t/testfiles/$_\n");
    close(FILE);
}

END {
    foreach (0 .. 0777) {
        unlink "t/testfiles/$_";
    }
    rmdir("t/testfiles");
}

1;
