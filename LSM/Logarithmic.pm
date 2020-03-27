package LSM::Logarithmic;
use strict;
use warnings;
use String::Scanf;
use List::Util qw(sum);
use parent 'LSM::Linear';

sub load_file
{
    my $self     = shift;
    my $filename = $self->{in} || ($self->{in} = shift);
    die "$0: No input file" unless $filename;
    open(my $file, "< :encoding(UTF-8)", $filename)
        || die "$0: Can't open $filename: $!";
    $self->{data} = {};
    while (my $entry = <$file>)
    {
        next if ($entry =~ /^\#/);
        my ($x, $y) = sscanf("%f%f", $entry);
        $self->{data}->{log($x)} = $y;
    }
    close $file;
}

sub evaluate
{
    my $self = shift;
    perform() unless $self->{coef_a};
    $self->{coef_a} * log($_[0]) + $self->{coef_b}
}

sub get_func
{
    my $self = shift;
    "f(x) = $self->{coef_a}*log(x) + $self->{coef_b}"
}

sub r_square
{
    my $self = shift;
    my $av_y = sum(values %{$self->{data}}) / scalar %{$self->{data}};
    my $re_s = sum(map { ($self->evaluate(exp($_)) - $av_y) ** 2 } keys %{$self->{data}});
    my $to_s = sum(map { ($_ - $av_y) ** 2 } values %{$self->{data}});
    my $r_sq = $re_s / $to_s;
    "R² = $r_sq"
}

1;