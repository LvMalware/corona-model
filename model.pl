#!/usr/bin/env perl

use strict;
use lib '.';
use warnings;
use Getopt::Long;
use Corona;
use Data::Dump;

sub help
{
    print <<HELP;

A numerical approach to model the growth of Corona Virus cases in Brazil

Usage: $0 [options] <days>

Options:

    -h, --help              Display this help message and exit
    -v, --version           Display the version and exit
    -s, --start-day  SDAY   Display an interval of days starting with SDAY
    -f, --final-day  FDAY   Display until FDAY
    -l, --load-file FILE    Load data from FILE (defaults to 'data.txt')
    -e, --error-stats       Display extra info about error on the model
    -i, --iter-start IDAY   Start the iterative prediction from IDAY

Examples:

    $0 -s 34 -f 38 -e
    $0 -i updated_data.txt 50 51

Notes:
        Iterative prediction means that the result from the day i+1 is done by
    using the data until day i.
        As with any numerical model, it finds only an approximation for future
    values based on data from past events, without taking into account changes
    in growth rates and/or the decrease in the number of cases. The results
    obtained from this model cannot be taken as completely certain or immutable,
    but only as estimates for the growth of the infection.
        In addition, as the prevention measures adopted by the population come
    into effect, reducing the growth in the number of cases, this model will
    tend to become less accurate over time.

Author:

    Lucas V. Araujo <lucas.vieira.ar\@disroot.org>
    GitHub: https://github.com/LvMalware

HELP

    exit(0)
}

sub version
{
    print "v0.3.2\n";
    exit(0)
}

my $start_day  = 1;
my $final_day  = undef;
my $error_rep  = 0;
my $input_file = 'data.txt';
my $iter_start = 28;

GetOptions(
    "help"         => \&help,
    "version"      => \&version,
    "start-day=i"  => \$start_day,
    "final-day=i"  => \$final_day,
    "load-file=s"  => \$input_file,
    "error-stats"  => \$error_rep,
    "iter-start=i" => \$iter_start,
);

my @days = defined($final_day) ? $start_day .. $final_day : @ARGV;

unless (@days > 0)
{
    print "Usage: $0 [options] <days>\n";
    print "Try --help for more information.\n";
    exit(0)
}
my @sorted = sort { $a <=> $b } @days;
my $estimatives = estimate_days(filename => $input_file, final => $sorted[-1], inc => $iter_start);

print "DAY\tCASES\tESTIM" . (($error_rep) ? "\tERROR\tERROR (%)\n" : "\n");

for my $day (@days)
{
    printf("%d\t%s\t%d",  $day, $estimatives->{$day}->{real} || '-', $estimatives->{$day}->{estimated});
    if ($error_rep)
    {
        my $abs_err = $estimatives->{$day}->{abs_error};
        my $rel_err = $estimatives->{$day}->{rel_error};
        printf("\t%s\t%.3s",  defined($abs_err) ? $abs_err : '-',  defined($rel_err) ? $rel_err : '-');
    }
    print "\n";
}
