#!/usr/bin/env perl
use v5.10;
use strict;
use warnings;
use Data::Dumper;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Getopt::Long::Descriptive;
use Experiment;
use Paws;
use List::Util qw/max/;
use MIME::Base64;

local $Data::Dumper::Pair = ': ';
local $Data::Dumper::Varname = 'params';
local $Data::Dumper::Indent = 1;

my ($opt, $usage) = describe_options(
  'run_experiment.pl %o <some-arg>',
  [ 'generations=i', "Number of generations",       { default => 100 } ],
  [ 'population=i',  "Players in each generation",  { default => 100 } ],
  [ 'games=i',       "Number of games for fitness", { default => 20 } ],
  [],
  [ 'crossover=f', "Crossover rate",     { default => 0.95 } ],
  [ 'mutation=f',  "Mutation rate",      { default => 0.05 } ],
  [],
  [ 'bits=i',    "Number of bits to use in Chromosome",{ default => 8 } ],
  [ 'decimal=i', "Decimal part of the Chromosome",     { default => 0 } ],
  [],
  [ 'forks=i', "Number of forks",{ default => 4 } ],
  [],
  [ 'instance-type=s', "AWS instance type",                { required => 1 } ],
  [ 'iam-role=s',      "AWS role for the instance",        { default => '2048Bucket' } ],
  [ 's3-bucket=s',     "S3 bucket to store the results",   { default => '2048bucket' } ],
  [ 'region=s',        "AWS region",                       { default => 'eu-west-1' } ],
  [ 'ami=s',           "AMI ID to build the instance",     { default => 'ami-a8d2d7ce' } ],
  [ 'bid-price=f',     "Ammount to bid",                   { default => 0 } ],
  [ 'overbid=f',       "Overbid current highest price by", { implies => { bid_price => 0 } } ],
  [],
  [ 'help|h', "print usage message and exit", { shortcircuit => 1 } ],
);

if ($opt->help) {
    say($usage->text);
}
else {
    say "Launching instance " . $opt->instance_type;

    my $ec2 = Paws->service('EC2', region => $opt->region);

    $ec2->RequestSpotInstances(
        LaunchSpecification => {
            ImageId => $opt->ami,
            InstanceType => $opt->instance_type,
            UserData => encode_base64(build_startup_script()),
            IamInstanceProfile => { Name => $opt->iam_role },
        },
        SpotPrice => get_bid_price($ec2),
    );
}

sub get_bid_price {
    my $ec2 = shift;

    return $opt->bid_price if $opt->bid_price;

    my $bid_prices = $ec2->DescribeSpotPriceHistory(
        Filters => [
            { Name => 'instance-type', Values => [$opt->instance_type] },
            { Name => 'product-description', Values => ['Linux/UNIX'] },
        ],
    );


    my $max_price = max map { $_->SpotPrice } @{$bid_prices->SpotPriceHistory};

    return ($max_price || 0) + $opt->overbid;
}

sub build_startup_script {
    my $params = join(' ',
        map { "--$_=$opt->{$_}" }
        qw/generations population games crossover mutation bits decimal forks/
    );

    my $bucket = $opt->s3_bucket;

    return "#!/bin/bash
    git clone https://github.com/meis/2048GA/
    cd 2048GA/
    ./script/install_dependencies.sh
    carton install

    # AWS client
    apt -y install python-setuptools python-pip
    pip install awscli

    carton exec -- script/run_experiment.pl $params
    aws s3 cp output/*csv s3://$bucket

    shutdown -h now
    ";
}
