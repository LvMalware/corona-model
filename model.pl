#!/usr/bin/env perl

use POSIX;
use strict;
use lib '.';
use warnings;
use Corona::Model;

my $m = Corona::Model->new(file => "dados.txt");
$m->load_file();
my ($p, $e) = (1, 1);
print "DAY\tCASES\tESTIM\tERROR\tERROR (%)\n";
for my $x (1 .. 44)
{
    $m->perform(($x > 27) ? $x - 1 : 27);
    my $y = ceil($m->eval($x, $e, $p));
    my $rv = $m->{data}->{$x} || '-';
    my $ea = ($rv ne '-') ? abs($y - $rv) : '-';
    my $er = ($ea eq '-') ? $ea : 100 * $ea / $rv;
    if ($x > 31)
    {
        $p ++ if (($er ne '-') && (int($er) <= 1));
    }
    printf("%d\t%s\t%d\t%s\t%s\n", $x, $rv, $y, $ea, $er);
}

