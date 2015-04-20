package TestMe::Tests::Tests;

use strict;

use DBI;
use Data::Dumper;

use ErrorHandle::Error::Compact;

sub getTests($)
{
    my ($app) = @_;

    my $params = $$app{cgi};

    my $all_difficulties = 1;
    my $all_topics = 1;

    if($$params{difficulty})
    {
        $all_difficulties = 0;
    }

    if($$params{topic})
    {
        $all_topics = 0;
    }

    my $sth = $$app{dbh}->prepare(
        q{
            SELECT *
            FROM tests_vw
            WHERE (difficulty_id = ? OR ?)
            AND (topic_id = ? OR ?)
        }
    );
    $sth->execute($$params{difficulty}, $all_difficulties, $$params{topic}, $all_topics);

    my $result = {};
    
    my @arr;
    while(my $row = $sth->fetchrow_hashref)
    {
        push @arr, $row;
    }
    $$result{tests} = \@arr;
    TRACE("RESULT", Dumper $result);
    return $result;
}

1;
