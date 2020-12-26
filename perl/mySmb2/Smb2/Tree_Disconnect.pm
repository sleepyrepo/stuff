
package Tree_Disconnect{
sub cmd_num{return 0x0004}
sub request{
  my $tree_disconnect_packer = [
    "16le" => 4,	#StructureSize
    "16le" => 0,	#Reserved
  ];
  return Struct->packer($tree_disconnect_packer);
}
sub response{
  my ($class, $data) = @_;
  my $tree_disconnect_parser = [
    structSize => "16le",
    reserved => "16le",
  ];
  return Struct->parser($tree_disconnect_parser, $data);
}

}
1;
