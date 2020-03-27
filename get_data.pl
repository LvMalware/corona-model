#!/usr/bin/env perl

use strict;
use warnings;
use File::Fetch;
use Getopt::Long;
use Text::CSV qw(csv); #installation: cpan install Text::CSV

use constant DATABASE => "https://covid.ourworldindata.org/data/ecdc/total_cases.csv";
#"https://covid.ourworldindata.org/data/who/total_cases.csv"; #outdated


my $output;
my $quiet;

GetOptions(
    "h|help"     => \&help,
    "q|quiet"    => \$quiet,
    "o|output=s" => \$output
);

my $country = shift @ARGV || "Brazil";
$output     = lc("$country.txt") unless $output;
print "[+] Fetching database from " . DATABASE . "\n" unless $quiet;
my $fetcher = File::Fetch->new(uri => DATABASE);
$fetcher->fetch(to => ".tmp_dataset");
print "[+] Loading CSV file...\n" unless $quiet;
my $csv     = csv(in => ".tmp_dataset/total_cases.csv");
my $j = 0;
print "[+] Searching for country: $country\n" unless $quiet;
$j++ until $csv->[0][$j] =~ /$country/;
shift @$csv;
open my $out, ">", $output;
my $i = 1;
for my $day (@$csv)
{
    print $out "#$day->[0]\n";
    unless (length "$day->[$j]")
    {
        print $out "#$i    No data\n";
        $i ++;
        next;
    }
    if ($day->[$j] > 0)
    {
        print $out "$i    $day->[$j]\n";
        $i ++;
    }
}

system('rm -rf .tmp_dataset/') if -d ".tmp_dataset";
print "[+] Data saved to $output\n" unless $quiet;
close $out;
exit(0);

sub help
{
    print "
Fetch data about corona virus cases by country (for lsm_test.pl)

Usage: $0 [options] <country>

Options:

    -h, --help                  Display this help message and exit
    -q, --quiet                 Don't display status output
    -o, --output <file>         Save output to <file> (default to <country>.txt)
Author:
    Lucas V. Araujo <lucas.vieira.ar\@disroot.org>
    GitHub: https://github.com/LvMalware/
";
exit(0);
}
