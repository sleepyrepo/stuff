
package Logoff{
sub cmd_num{return 0x0002}
sub request{
  my $logoff_packer = [
    "16le" => 4,	#StructureSize
    "16le" => 0,	#Reserved
  ];
  return Struct->packer($logoff_packer);
}
sub response{
  my ($class, $data) = @_;
  my $logoff_parser = [
    structSize => "16le",
    reserved => "16le",
  ];
  return Struct->parser($logoff_parser, $data);
}

}
1;
