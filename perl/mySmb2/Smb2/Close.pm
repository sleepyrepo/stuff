
package Close{
sub cmd_num {return 0x0006}
sub request{
  my ($class, $fileId) = @_;
  my $close_packer = [
    "16le" => 24,	#struct size
    "16le" => 0,	#Flags
    "32le" => 0,        #Reserved
    "str" => $fileId,	#FileId
  ];
  return Struct->packer($close_packer);
}


sub response{
  my ($class, $data) = @_;
  my $close_parser = [
    structSize => "16le",
    flags => "16le",
    reserved => "32le",
    creationTime => "64le",
    lastAccessTime => "64le",
    lastWriteTime => "64le",
    changeTime => "64le",
    allocationSize => "64le",
    endofFile => "64le",
    fileAttributes => "32le",
  ];
  return Struct->parser($close_parser, $data);
}

}
1;
