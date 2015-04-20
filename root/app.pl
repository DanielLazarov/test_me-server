#!/usr/bin/perl -w
use lib qw(/home/daniel/test_system_project/test_me-server/lib/perl);

use TestMe::WebHandle::WebHandle;

#binmode (STDIN, ":utf8");
#binmode (STDOUT, ":utf8");
#binmode (STDERR, ":utf8");

if(shift)
{
    TestMe::WebHandle::WebHandle->handle();
}

1;
