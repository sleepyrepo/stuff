
package Query_Directory{
my $FILE_INFO_CLASS = {
  FileDirectoryInformation => 0x01,
  FileFullDirectoryInformation => 0x02,
  FileIdFullDirectoryInformation => 0x26,
  FileBothDirectoryInformation => 0x03,
  FileIdBothDirectoryInformation => 0x25,
  FileNamesInformation => 0x0C,
};
my $FLAGS = {
  SMB2_RESTART_SCANS => 0x01,
  SMB2_RETURN_SINGLE_ENTRY => 0x02,
  SMB2_INDEX_SPECIFIED => 0x04,
  SMB2_REOPEN => 0x10,
};

sub cmd_num{ return 0x000E }
sub request{
  my ($class, $fileId, $pattern) = @_;
  my $query_dir_packer = [
    "16le" => 33,		#struct size
    "8le" => 0x01,        	#FileInformationClass
    "8le" => 1,          	#Flags
    "32le" => 0,          	#FileIndex
    "str" => $fileId,		#FileId
    "16le" => 64+33-1,		#FileNameOffset
    "16le" => length $pattern,	#FileNameLength
    "32le" => 0xffff,          	#OutputBufferLength
    "str" => $pattern,		#buff
  ];
  return Struct->packer($query_dir_packer);
}



sub response{
  my ($class, $data) =  @_;
  my $query_dir_parser = [
    structSize => "16le",
    buffOffset => "16le",
    buffLength => "32le",
    data => ["*"],
  ];
  return Struct->parser($query_dir_parser, $data);
}

}
1;
