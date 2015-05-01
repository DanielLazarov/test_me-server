#!/usr/bin/perl -w

#binmode (STDIN, ":utf8");
#binmode (STDOUT, ":utf8");
#binmode (STDERR, ":utf8");

use lib qw(/home/daniel/test_system_project/test_me-server/lib/perl);

use TestMe::WebHandle::WebHandle;

if(shift)
{
    TestMe::WebHandle::WebHandle->handle();
}

1;
