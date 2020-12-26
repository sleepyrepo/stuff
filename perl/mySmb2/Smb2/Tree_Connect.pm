
package Tree_Connect{
sub cmd_num{ return 0x0003 }
sub request{
  my ($class, $path) = @_;
  my $tree_connect_packer = [
    "16le" => 9,		#struct size
    "16le" => 0,		#Reserved
    "16le" => 64+8,        	#PathOffset
    "16le" => length $path,     #PathLength
    "str" => $path,		
  ];
  return Struct->packer($tree_connect_packer);
}


sub response{
  my ($class, $data) = @_;
  my $tree_connect_parser = [
    structSize => "16le",
    shareType => "8le",
    reserved => "8le",
    flags => "32le",
    capability => "32le",
    maximalAccess => "32le",
  ];
  my $tree_connect_res = Struct->parser($tree_connect_parser, $data);
  return $tree_connect_res;
}
}
1;
