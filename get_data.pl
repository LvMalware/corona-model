#!/usr/bin/env perl
use utf8;
use JSON;
use strict;
use warnings;
use HTTP::Tiny;

my $request = HTTP::Tiny->new()->get('https://www.coronavirus.com.br/wp-content/uploads/c19/data.json?_t=1591530776');
#https://xx9p7hp1p7.execute-api.us-east-1.amazonaws.com/prod/PortalCasos
if ($request->{success})
{
    my $data = JSON::from_json($request->{content});
    open my $out, ">", "brasil.txt";
    my $days = $data->{countries}->{Brazil}->{dates};
    for my $day (0 .. @$days - 1)
    {
        print $out ($day + 1) . "        " . $days->[$day]->{'confirmed'} . "\n";
    }
    close $out;
}
