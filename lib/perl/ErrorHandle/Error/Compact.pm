package ErrorHandle::Error::Compact;

use strict;

use Exporter qw(import);

our @ISA =   qw(Exporter);
our @EXPORT = qw(TRACE ASSERT ASSERT_PEER ASSER_USER);


sub TRACE($;$)
{
    my ($control, $msg) = @_;

    my $time = localtime;

    print STDERR "[$time] $control: $msg \n";
}

sub ASSERT($;$$)
{
    my($cond, $msg, $code) = @_;

    if(!$cond)
    {
        die bless {msg => $msg, code => $code}, "sysError";
    }
}

sub ASSERT_PEER($;$$)
{
    my($cond, $msg, $code) = @_;

    if(!$cond)
    {
        die bless {msg => $msg, code => $code}, "peerError";
    }
}

sub ASSERT_USER($;$$)
{
    my($cond, $msg, $code) = @_;

    if(!$cond)
    {
        die bless {msg => $msg, code => $code}, "userError";
    }
}

1;
