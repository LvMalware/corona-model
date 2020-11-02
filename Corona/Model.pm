package Corona::Model;

use strict;
use warnings;
use String::Scanf;
use base 'Exporter';
use List::Util qw(sum);

our $VERSION = 0.3.2;

sub new
{
    my ($self, %args) = @_;
    my $data = { file => $args{file}, data => $args{data} || {} };
    bless $data, $self;
}

sub load_file
{
    my ($self, $filename) = @_;
    $filename = $self->{file} unless defined($filename);
    die "No input file" unless $filename;
    open(my $file, "< :encoding(UTF-8)", $filename)
        || die "Can't open $filename for reading: $!";
    $self->{data} = {};
    my $last = 0;
    while (my $entry = <$file>)
    {
        next if ($entry =~ /^\#/);
        my ($x, $y) = sscanf("%f %f", $entry);
        $self->{data}->{$x} = $y;
        $last = $x if $x > $last;
    }
    $self->{last} = $last;
    close($file);
}

sub __pow_perform
{
    my ($self, $max) = @_;
    my ($sum_x, $sum_y, $sum_x2, $sum_xy) = (0, 0, 0, 0);
    $max = scalar %{$self->{data}} unless defined($max);
    
    for my $x (1 .. $max)
    {
        $sum_x  += log($x);
        $sum_y  += log($self->{data}->{$x});
        $sum_x2 += log($x) ** 2;
        $sum_xy += log($x) * log($self->{data}->{$x});
    }

    my $a = ($max * $sum_xy - $sum_x * $sum_y) / ($max * $sum_x2 - $sum_x * $sum_x);
    my $b = ($sum_x * $sum_xy - $sum_y * $sum_x2) / ($sum_x * $sum_x  - $max * $sum_x2);
    ($a, $b)
}

sub perform
{
    my ($self, $max)    = @_;
    my ($pow_a, $pow_b) = $self->__pow_perform($max);
    $self->{pow_a} = $pow_a;
    $self->{pow_b} = $pow_b;
}

sub pow_eval
{
    my ($self, $x) = @_;
    die "Can't eval without performing regression first." unless $self->{pow_a};
    exp($self->{pow_b}) * ($x ** $self->{pow_a})
}

sub eval
{
    my ($self, $x) = @_;
    $self->pow_eval($x);
}

1;
