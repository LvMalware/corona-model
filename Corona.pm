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
    my $max_day  = $args{final}  || die "No final day specified. Try passing 'final => day'";
    my $adj_day  = $args{errday} || 124;
    my $err      = $args{error}  || 3;
    my $inc      = $args{inc}    || 28;
    die "Invalid file: '$filename'" unless (-f $filename);
    my $predictor = Corona::Model->new(file => $filename);
    my %estimatives;
    $predictor->load_file();
    my $limit = $predictor->{last};
    if ($inc > $limit)
    {
        die "Can't perform iterative prediction with IDAY ($inc) > LIMIT ($limit)"
    }
    
    my $adj_err = 0;

    for my $day (1 .. $max_day)
    {
        if ($day < $inc)
        {
            $predictor->perform($inc - 1);
        }
        elsif ($day <= $limit)
        {
            $predictor->perform($day - 1);
        }
        else
        {
            $predictor->perform($limit);
        }
        my $true_value = $predictor->{data}->{$day} || undef;
        my $estimated  = ceil($predictor->eval($day));
        $estimated    -= ceil($estimated * $adj_err / 100);
        my $abs_error  = defined($true_value) ? abs($true_value - $estimated) : undef;
        my $rel_error  = defined($abs_error) ? 100 * $abs_error / $true_value : undef;

        $estimatives{$day} = {
            real      => $true_value,
            estimated => $estimated,
            abs_error => $abs_error,
            rel_error => $rel_error,
            adj_error => $adj_err,
        };

        if ($day > $adj_day)
        {
            if (defined($true_value) && $true_value < $estimated)
            {
                $adj_err += $err / 2 if ($rel_error > $err);
            }
        }
    }
    \%estimatives
}

1;
