
package Negotiate{
sub cmd_num{ return 0x0000 }
sub request{
  shift;
  my $nego_packer = [
    "16le" => 36,         #struct size
    "16le" => 1,          #dialect count
    "16le" => 0,          #secure mode
    "16le" => 0,          #reserve
    "32le" => 0,          #capability
    "str" => "\x11"x16,   #ClientGuid
    #"16le" => 0,         #Reserved2
    "64le" => 0,          #start time
    "16le" => 0x0202,     #dialects 0x0202
    "str" => "\x00"x1,    #pad
  ];
  return Struct->packer($nego_packer);
}

sub response{
shift;
  my $data = shift;
  my $nego_parser = [
    structSize => "16le",
    secMode => "16le",
    dialect => "16le",
    reserved => "16le",
    serverGuid => [16],
    capability => "32le",
    maxTranSize => "32le",
    maxReadSize => "32le",
    maxWriteSize => "32le",
    systemTime => "64le",
    startTime => "64le",
    blobOffset => "16le",
    blobLen => "16le",
    reserved2 => "32le",
    data => ["*"],
  ];
  my $nego_res = Struct->parser($nego_parser, $data);
  return $nego_res;
}
}
1;
