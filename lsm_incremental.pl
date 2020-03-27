#!/usr/bin/env perl

use strict;
use lib '.';
use POSIX;
use warnings;
use Getopt::Long;
use LSM::Power;
use LSM::Linear;
use LSM::Logarithmic;
use LSM::Exponential;

my ($pow, $lin, $log, $exp, $all);
my $input_filename;
my $output_filename;
my $start_point = 1;
my $final_point = 5;
my $display_function;
my $display_r_square;

GetOptions(
    "all"         => \$all,
    "power"       => \$pow,
    "linear"      => \$lin,
    "logarithmic" => \$log,
    "exponential" => \$exp,
    "help"        => \&help,
    "start=i"     => \$start_point,
    "final=i"     => \$final_point,
    "output=s"    => \$output_filename,
    "display"     => \$display_function,
    "r_square"    => \$display_r_square
);

sub help
{
    print "
Regression using the Least Square Method.

Usage: $0 [options] <input_file>

Options:

-h, --help              Show this help message and exit
-s, --start <point>     Display results starting at this point (default = 1)
-f, --final <point>     Display results until this point (default = 5)
-o, --output <file>     Save the results into file
-d, --display           Display the function obtained for each regression
-r, --r_square          Display the R² adjust metrics for each regression
-a, --all               Perform all avaiable regressions
-p, --power             Perform power regression
-li, --linear           Perform linear regression
-lo, --logarithmic      Perform logarithmic regression
-e, --exponential       Perform exponential regression

Examples:

$0 -s 1 -f 10 -pe data.txt
$0 -s 2 -f 15 -li -lo -o output.txt input.txt

Author:

Lucas V. Araujo <lucas.vieira.ar\@disroot.org>
GitHub: https://github.com/LvMalware

";
exit (0);
}

$input_filename = shift @ARGV || help() ;
if (defined($output_filename))
{
    open(STDOUT, ">", $output_filename)
    || die "$0: Can't write on file $output_filename: $!";
}

if ($all)
{
    $pow = $lin = $log = $exp = 1;
}

my %regressions;

my $power = LSM::Power->new(in => $input_filename);
my $expon = LSM::Exponential->new(in => $input_filename);

$power->load_file();
$power->perform();
$expon->load_file();
$expon->perform();
print STDOUT "Ind\tNR\tRE\tRP\tMed\tErrA\tErrR\n";
$start_point = 28;
$final_point = 31;
for my $x ($start_point .. $final_point)
{
    my $file = $x - 27;
    $power->load_file("data/$file.txt");
    $power->perform();
    $expon->load_file("data/$file.txt");
    $expon->perform();
    my ($e, $p) = (ceil($expon->evaluate($x)), ceil($power->evaluate($x)));
    my $m = ceil(($e + $p)/2);
    my $t = $expon->{data}->{$x};
    $t = $t ? ceil(exp($t)) : "-";
    $t = 1 if $x < 5;
    $t = 1891 if $x == 28;
    $t = 2201 if $x == 29;
    $t = 2433 if $x == 30;
    $t = 2915 if $x == 31;
    my $a = ($t ne "-") ? abs($m - $t) : "-";
    my $r = ($a ne "-") ? $a / $t * 100 : "-";
    print STDOUT "$x\t$t\t$e\t$p\t$m\t$a\t$r\n";
}
#print $expon->get_func() . "\n";
#print $power->get_func() . "\n";
