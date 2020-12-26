
package Spnego{
my $TAG = {
  ASN1_BINARY           => 0x04,
  ASN1_OID              => 0x06,
  ASN1_ENUMERATED       => 0x0a,
  ASN1_SEQUENCE         => 0x30,
  ASN1_SET              => 0x31,
  ASN1_APPLICATION      => 0x60,
  ASN1_CONTEXT          => 0xa0,
};

my $OID_MECH_NTLMSSP = pack"H*", "2b06010401823702020a";
my $OID_SPNEGO = pack"H*", "2b0601050502";

sub gen_asn{
  my ($tag, $data) = @_;
  my $len = length $data;
  my $length = $len < 0x80? pack"C", $len :
    $len < 0x100? pack"CC", 0x81, $len :
    $len < 0x10000? pack"Cn", 0x82, $len :
    die"asn data too long";
  return pack("C", $tag) . $length . $data;
}

sub negTokenInit{
  my ($class, $token) = @_;
  my $mechToken = gen_asn(0xa2, gen_asn($TAG->{ASN1_BINARY}, $token));
  my $mechTypeList = gen_asn(0xa0, gen_asn($TAG->{ASN1_SEQUENCE}, gen_asn($TAG->{ASN1_OID}, $OID_MECH_NTLMSSP)));
  my $negTokenInit = gen_asn(0xa0, gen_asn($TAG->{ASN1_SEQUENCE}, $mechTypeList . $mechToken));
  my $spnego = gen_asn($TAG->{ASN1_OID}, $OID_SPNEGO);
  return gen_asn($TAG->{ASN1_APPLICATION}, $spnego . $negTokenInit);
}

sub negTokenTarg{
  my ($class, $token) = @_;
  my $responseToken = gen_asn(0xa2, gen_asn($TAG->{ASN1_BINARY}, $token));
  my $negTokenTarg = gen_asn(0xa1, gen_asn($TAG->{ASN1_SEQUENCE}, $responseToken));
  return $negTokenTarg
}


}
1;
