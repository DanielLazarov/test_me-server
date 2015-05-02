#!/usr/bin/perl -w

binmode (STDIN, ":utf8");
binmode (STDOUT, ":utf8");
binmode (STDERR, ":utf8");

use TestMe::WebHandle::WebHandle;
TestMe::WebHandle::WebHandle->handle();


1;
