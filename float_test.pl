use v5.10;
use Data::Dumper;
use Data::IEEE754 qw( pack_double_be unpack_double_be );

sub float_to_bits {
  pack "d",shift;
}
sub bits_to_arrayref {
 [unpack "b64", shift]
}
sub arrayref_to_float {
 my $arrayref = shift;
 unpack "d", pack "b64", @$arrayref;
}

my $bits = '0000110111111111011111011110001000101001101111000111100100011011';
my $octal = '0x0DFF7DE229BC791B';
my $float = '2.95175315502427949500613120678E-241';
my $bs = "0b$bits";
my $arrayref = [split //, $bits];

my $tests = [
    unpack('d', pack('b64', split(//,$bits))),

    oct("0b$bits"),
    unpack('d', pack('b64', $bits)),
    unpack('d', pack('B64', $bits)),
    unpack('d', pack('b64', '0b' . $bits)),
    unpack('d', pack('B64', '0b' . $bits)),
    printf("%f", $bs),
    unpack('d', $bs),
    unpack('d', $bits),
    unpack_double_be($bits),
    unpack_double_be($bs),

    arrayref_to_float($arrayref),
$arrayref,
];

say "Expected $float";
say "Octal is $octal";

say Dumper($tests);
