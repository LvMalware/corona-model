package Corona;

use POSIX;
use strict;
use lib '.';
use warnings;
use Corona::Model;
use base 'Exporter';

our $VERSION = 0.3.2;
our @EXPORT  = qw(estimate_days);

sub estimate_days
{
    my %args = @_;
    my $filename = $args{filename};
    my $max_day  = $args{final} || die "No final day specified. Try passing 'final => day'";
    my $w_p      = $args{wp} || 1;
    my $w_e      = $args{we} || 1;
    die "Invalid file: '$filename'" unless (-f $filename);
    my $predictor = Corona::Model->new(file => $filename);
    my %estimatives;
    $predictor->load_file();
    for my $day (1 .. $max_day)
    {
        $predictor->perform(($day < 28) ? 27 : $day - 1);
        my $true_value = $predictor->{data}->{$day} || undef;
        my $estimated  = ceil($predictor->eval($day, $w_e, $w_p));
        my $abs_error  = defined($true_value) ? abs($true_value - $estimated) : undef;
        my $rel_error  = defined($abs_error) ? 100 * $abs_error / $true_value : undef;
        $estimatives{$day} = {
            real      => $true_value,
            estimated => $estimated,
            abs_error => $abs_error,
            rel_error => $rel_error,
            po_weight => $w_p,
            ex_weight => $w_e
        };
        $w_p ++ if (($day > 27) && defined($rel_error) && (int($rel_error) <= 1));

    }
    \%estimatives
}

1;
