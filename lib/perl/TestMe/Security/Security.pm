package TestMe::Security::Security;
use strict;

use DBI;
use Data::Dumper;
use Digest::SHA qw(sha256_hex);

use ErrorHandle::Error::Compact;



sub logIn($)
{
    my ($app) = @_;

    my $params = $$app{cgi};
    
    ASSERT_PEER(defined $$params{username}, "Missing Param");
    ASSERT_PEER(defined $$params{password}, "Missing Param");

    my $sth = $$app{dbh}->prepare(
        q{
            SELECT *
            FROM accounts_vw 
            WHERE username = ?
    });
    $sth->execute($$params{username});
    ASSERT($sth->rows <= 1);

    ASSERT_USER($sth->rows == 1, "Incorrect Username or Password", "TMU001");
    my $account_row = $sth->fetchrow_hashref;

    ASSERT_USER(sha256_hex($$params{password}) eq $$account_row{password}, "Incorrect Username or Password", "TMU001");

    my $sth = $$app{dbh}->prepare(
        q{
            INSERT INTO account_sessions
            VALUES(default,default,?) RETURNING *
    });
    $sth->execute($$account_row{account_id});
    my $session_row = $sth->fetchrow_hashref;

    my $result = {
        account_id  => $$account_row{account_id},
        username    => $$account_row{username},
        email       => $$account_row{email},
        first_name  => $$account_row{first_name},
        last_name   => $$account_row{last_name},
        rank_id     => $$account_row{rank_id},
        rank__name  => $$account_row{rank__name},
        session_token => $$session_row{session_token}
    };

    return $result;
}

sub verifySession($$$)
{
    my ($app, $account_id, $session_token) = @_;
    
    my $sth = $$app{dbh}->prepare(
        q{
            SELECT *
            FROM account_sessions 
            WHERE account_id = ?
                AND session_token = ?
    });
    $sth->execute($account_id, $session_token);
    
    if($sth->rows > 0)
    {
        return 1;
    }
    else
    {
        return 0;
    }
}

1;

