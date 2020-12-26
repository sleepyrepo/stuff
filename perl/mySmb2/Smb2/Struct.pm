
package Struct{
my %PACK_TEMP = (				#pack/unpack template
  "8be" => "C",
  "16be" => "n",
  "32be" => "N",
  "64be" => "Q>",
  "8le" => "C",
  "16le" => "v",
  "32le" => "V",
  "64le" => "Q<",
  "str" => "a",
);

sub packer{
  my ($class, $struct) = @_;
  my $size = @$struct / 2;
  return join"", map{
    my $type = $struct->[$_*2];
    $type eq "str"?                           	#if type str, grab value and len
      pack $PACK_TEMP{$type} . length $struct->[($_*2)+1], $struct->[($_*2)+1] :
      pack $PACK_TEMP{$type}, $struct->[($_*2)+1];
  }(0..$size - 1);
}

sub parser{
  my ($class, $struct, $stream) = @_;
  my $size = @$struct / 2;
  my @keys;					#array to store keys
  my %hash;
  my $unpack_temp = join"", map{		#build unpack template
    push @keys, $struct->[$_*2];		#store keys
    my $type = $struct->[($_*2)+1];		#get data type
    ref $type eq "ARRAY"?			#if type array, unpack as string "a"
      $PACK_TEMP{str} . $type->[0] :
      $PACK_TEMP{$type};
  }(0..$size - 1);
  my @vals = unpack $unpack_temp, $stream;	#parse values from stream to array
  @hash{@keys} = @vals;				#join array key/val pair into hash
  return \%hash;
}
}
1;
