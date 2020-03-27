package LSM::Linear;
use strict;
use warnings;
#String::Scanf to parse the input data. Installation: cpan install String::Scanf
use String::Scanf;
use List::Util qw(sum);
use base 'Exporter';
#use Data::Dumper;

our $VERSION = 0.1;
our @EXPORT  = qw();

sub new
{
    my $self = shift;
    my %args = @_;
    my $data = {
        in   => $args{in},
        out  => $args{out},
        data => $args{data}
    };
    bless $data, $self;
}

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
        $self->{data}->{$x} = $y;
    }
    close $file;
    #print Dumper($self) . "\n";
}

sub perform
{
    my $self = shift;
    die "No data loaded" unless ($self->{data});
    my $sum_x  = sum keys %{$self->{data}};
    my $sum_y  = sum values %{$self->{data}};
    my $sum_x2 = sum map {$_ ** 2} keys %{$self->{data}};
    my $sum_xy = sum map {$_ * $self->{data}->{$_}} keys %{$self->{data}};
    my $count  = scalar %{$self->{data}};
    $self->{coef_a} = ($count * $sum_xy - $sum_x * $sum_y) /
                      ($count * $sum_x2 - $sum_x * $sum_x);
    $self->{coef_b} = ($sum_x * $sum_xy - $sum_y * $sum_x2) /
                      ($sum_x * $sum_x  - $count * $sum_x2);
}

sub evaluate
{
    my $self = shift;
    perform() unless $self->{coef_a};
    $self->{coef_a} * $_[0] + $self->{coef_b}
}

sub get_func
{
    my $self = shift;
    "f(x) = $self->{coef_a}*x + $self->{coef_b}"
}

sub r_square
{
    my $self = shift;
    my $av_y = sum(values %{$self->{data}}) / scalar %{$self->{data}};
    my $re_s = sum map{($self->evaluate($_) - $av_y)**2} keys %{$self->{data}};
    my $to_s = sum map{($_ - $av_y)**2} values %{$self->{data}};
    my $r_sq = $re_s / $to_s;
    "R² = $r_sq"
}

1;
