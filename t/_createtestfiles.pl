#!perl

use strict;
use warnings;

cleanup();
sub makefiles {
    my($user, $group) = @_;
    mkdir("t/testfiles") || die("Can't mkdir t/testfiles\n");
    foreach my $mode (0 .. 0777) {
        my $filename = sprintf("%04o", $mode);
        open(FILE, ">t/testfiles/$filename") ||
            die("Can't create t/testfiles/$filename\n");
        print FILE $filename;
        close(FILE);
        if(defined($user) && $> == 0) { # if running as root ...
            chmod($mode, "t/testfiles/$filename");
            chown($user, $group, "t/testfiles/$filename");
        }
    }
}

sub cleanup {
    foreach my $filename (map { sprintf("%04o", $_) } 0 .. 0777) {
        unlink "t/testfiles/$filename";
    }
    rmdir("t/testfiles");
}

END { cleanup() }

1;
