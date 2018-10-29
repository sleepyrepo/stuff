#!/usr/bin/ruby

class Nbss < BinData::Record
  uint32be :typeLen, :initial_value => 0
end

#SMB SYNC
class SmbHead < BinData::Record
  endian :little
  string :protoId, :length => 4, :initial_value => "\xFESMB"
  uint16 :structureSize, :initial_value => 64
  uint16 :creditCharge, :initial_value => 0
  uint32 :status, :initial_value => 0
  uint16 :command, :initial_value => 0
  uint16 :creditRequestResponse, :initial_value => 0
  uint32 :flags, :initial_value => 0
  uint32 :nextCommand, :initial_value => 0
  uint64 :messageId, :initial_value => 0
  uint32 :reserved, :initial_value => 0		#wireshark says thi is PID
  uint32 :treeId, :initial_value => 0
  uint64 :sessionId, :initial_value => 0
  string :signature, :read_length => 16, :initial_value => "\x00"*16 

end

class NegotiateRequest < BinData::Record
  endian :little
  nbss :nbssHead
  smbHead :smbHead
  uint16 :structureSize, :value => 36
  uint16 :dialectCount, :value => 1
  uint16 :securityMode, :value => 1 
  uint16 :reserved, :value => 0
  uint32 :capabilities, :value => 0
  uint128 :clientGuid, :value => 0
  uint64 :clientStartTime, :value => 0 
  #string :dialects, :value => "\x02\x02" 
  string :dialects, :length => lambda { dialectCount * 2 }, :initial_value => [0x0202, 0x0210, 0x0300, 0x0302, 0x0311].pack("v*") 
  string :padding, :onlyif => :negotiateContextList? 	#,lambda { !negotiateContextList.length }
  string :negotiateContextList, :onlyif => lambda { dialects[/#{[0x0311].pack("v")}/] }

  def cal
    nbssHead.typeLen = self.num_bytes - 4
    smbHead.command = SMB2_NEGOTIATE    
  end
end


class NegotiateResponse < BinData::Record
  endian :little
  nbss :nbssHead
  smbHead :smbHead
  uint16 :structureSize, :initial_value => 65
  uint16 :securityMode, :initial_value => 0
  string :dialectRevision, :length => 2, :initial_value => "\x00\x00"
  uint16 :reserved, :initial_value => 0
  uint128 :serverGuid, :initial_value => 0
  uint32 :capabilities, :initial_value => 0
  uint32 :maxTransactSize, :initial_value => 0
  uint32 :maxReadSize, :initial_value => 0
  uint32 :maxWriteSize, :initial_value => 0
  uint64 :systemTime, :initial_value => 0
  uint64 :serverStartTime, :initial_value => 0
  uint16 :securityBufferOffset, :initial_value => 0
  uint16 :securityBufferLength, :initial_value => 0
  uint32 :reserved2, :initial_value => 0
  string :buffer, :length => :securityBufferLength 
  #string :padding, :onlyif => :negotiateContextList?
  #string :negotiateContextList, :onlyif => lambda { dialectRevision == [0x0311].pack("v")[0] }
end

class SessionSetupRequest < BinData::Record
  endian :little
  nbss :nbssHead
  smbHead :smbHead
  uint16 :structureSize, :value => 25
  uint8 :flags, :initial_value => 0
  uint8 :securityMode, :initial_value => 1
  uint32 :capabilities, :initial_value => 0
  uint32 :channel, :initial_value => 0
  uint16 :securityBufferOffset, :initial_value => 0#lambda{smbHead.structureSize + structureSize.initial_value - 1}
  uint16 :securityBufferLength, :initial_value => 0 #lambda { nbssHead.structureSize + :structureSize - 1}
  uint64 :previousSessionId, :initial_value => 0
  string :buffer, :read_length => 256

#def initialize_instance
def cal
    #super
    nbssHead.typeLen = self.num_bytes - 4
    smbHead.command = SMB2_SESSION_SETUP
    smbHead.messageId = $msgId += 1
    smbHead.sessionId = $sessionId
    securityBufferOffset.value = smbHead.structureSize + structureSize - 1#########
    #p securityBufferLength = self.num_bytes - 4 - securityBufferOffset
    securityBufferLength.value = buffer.length
  end
end

class SessionSetupResponse < BinData::Record
  endian :little
  nbss :nbssHead
  smbHead :smbHead
  uint16 :structureSize
  uint16 :sessionFlags
  uint16 :securityBufferOffset
  uint16 :securityBufferLength
  string :buffer, :read_length => :securityBufferLength
end

class TreeConnectRequest < BinData::Record
  endian :little
  nbss :nbssHead
  smbHead :smbHead
  uint16 :structureSize, :value => 9
  uint16 :reserved, :value => 0
  uint16 :pathOffset, :initial_value => 0
  uint16 :pathLength, :initial_value => 0
  string :buffer, :read_length => 256

def cal
    nbssHead.typeLen = self.num_bytes - 4
    smbHead.command = SMB2_TREE_CONNECT
    smbHead.messageId = $msgId += 1
    smbHead.sessionId = $sessionId
    pathOffset.value = smbHead.structureSize + structureSize - 1
    pathLength.value = buffer.length
  end
end

class TreeConnectResponse < BinData::Record
  endian :little
  nbss :nbssHead
  smbHead :smbHead
  uint16 :structureSize
  uint8 :shareType
  uint8 :reserved
  uint16 :shareFlags
  uint16 :capabilities
  uint16 :maximalAccess
end

class CreateRequest < BinData::Record
  endian :little
  nbss :nbssHead
  smbHead :smbHead
  uint16 :structureSize, :value => 57
  uint8 :securityFlags, :value => 0
  uint8 :requestedOplockLevel, :initial_value => 0
  uint32 :impersonationLevel, :initial_value => 2
  uint64 :smbCreateFlags, :value => 0
  uint64 :reserved, :value => 0
  uint32 :desiredAccess, :value => 0x81 #FILE_READ_DATA | FILE_READ_ATTRIBUTES
  uint32 :fileAttributes, :value => 0x10 #DIRECTORY
  uint32 :shareAccess, :value => 0x3 #READ | WRITE
  uint32 :createDisposition, :value => 0x01 #FILE_OPEN
  uint32 :createOptions, :value => 0x01 #FILE_DIRECTORY_FILE
  uint16 :nameOffset, :initial_value => 0
  uint16 :nameLength, :initial_value => 0
  uint32 :createContextsOffset, :initial_value => 0
  uint32 :createContextsLength, :initial_value => 0
  string :buffer, :read_length => 256, :initial_value => "\x00"	#*****why need padd
#[MS-SMB2]--(P68)In the request, the Buffer field MUST be at least one byte in length.

  def cal
    nbssHead.typeLen = self.num_bytes - 4
    smbHead.command = SMB2_CREATE
    smbHead.messageId = $msgId += 1
    smbHead.sessionId = $sessionId
    smbHead.treeId = $treeId
    nameOffset.value = smbHead.structureSize + structureSize - 1
    #nameLength.value = buffer.length
    #createContextsOffset.value = nameOffset.value + 6
  end
end

class CreateResponse < BinData::Record
  endian :little
  nbss :nbssHead
  smbHead :smbHead
  uint16 :structureSize
  uint8 :oplockLevel
  uint8 :flags
  uint32 :createAction
  uint64 :creationTime
  uint64 :lastAccessTime
  uint64 :lastWriteTime
  uint64 :changeTime
  uint64 :allocationSize
  uint64 :endofFile
  uint32 :fileAttributes
  uint32 :reserved2
  uint128 :fileId
  uint32 :createContextsOffset
  uint32 :createContextsLength
  string :buffer, :read_length => :createContextsLength, :onlyif => lambda { createContextsLength > 0 }
end

class QueryDirectoryRequest < BinData::Record	#0x0e
  endian :little
  nbss :nbssHead
  smbHead :smbHead
  uint16 :structureSize, :value => 33 
  uint8 :fileInformationClass, :initial_value => 0x26 #FileIdFullDirectoryInformation
  uint8 :flags, :initial_value => 0
  uint32 :fileIndex, :initial_value => 0
  uint128 :fileId
  uint16 :fileNameOffset
  uint16 :fileNameLength
  uint32 :outputBufferLength, :initial_value => 0xffff
  string :buffer, :read_length => 512

  def cal
    nbssHead.typeLen = self.num_bytes - 4
    smbHead.command = SMB2_QUERY_DIRECTORY
    smbHead.messageId = $msgId += 1
    smbHead.sessionId = $sessionId
    smbHead.treeId = $treeId
    fileId = $fileId
    fileNameOffset.value = smbHead.structureSize + structureSize - 1
    fileNameLength.value = buffer.length
  end
end

class QueryDirectoryResponse < BinData::Record
  endian :little
  nbss :nbssHead
  smbHead :smbHead
  uint16 :structureSize
  uint16 :outputBufferOffset
  uint32 :outputBufferLength
  string :buffer, :read_length => :outputBufferLength	#response has stream of FILE_ID_FULL_DIR_INFORMATION struct

  def list						#lopp thorugh return buffer and retirn array of FILE_ID_FULL_DIR_INFORMATION
    tmp = buffer.to_binary_s
    offset = 0
    fileArr = []
    loop do
      offset = tmp[0].ord
      file = tmp.slice!(0,offset)
      break if file.bytesize < 1
      fileArr << FILE_ID_FULL_DIR_INFORMATION.read(file)
    end
    return fileArr
  end
end

class FILE_ID_FULL_DIR_INFORMATION < BinData::Record
  endian :little
  uint32 :nextEntryOffset
  uint32 :fileIndex
  uint64 :creationTime
  uint64 :lastAccessTime
  uint64 :lastWriteTime
  uint64 :changeTime
  uint64 :endOfFile
  uint64 :allocationSize
  uint32 :fileAttributes
  uint32 :fileNameLength
  uint32 :eaSize
  uint32 :reserved
  uint64 :fileId
  string :fileName, :read_length => :fileNameLength
end

class CloseRequest < BinData::Record
  endian :little
  nbss :nbssHead
  smbHead :smbHead
  uint16 :structureSize, :value => 24
  uint16 :flags, :initial_value => 0
  uint32 :reserved, :value => 0
  uint128 :fileId, :initial_value => 0
 
  def cal
    nbssHead.typeLen = self.num_bytes - 4
    smbHead.command = SMB2_CLOSE
    smbHead.messageId = $msgId += 1
    smbHead.sessionId = $sessionId
    smbHead.treeId = $treeId
  end
end

class CloseResponse < BinData::Record
  endian :little
  nbss :nbssHead
  smbHead :smbHead
  uint16 :structureSize, :value => 60
  uint16 :flags
  uint32 :reserved
  uint64 :creationTime
  uint64 :lastAccessTime
  uint64 :lastWriteTime
  uint64 :changeTime
  uint64 :allocationSize
  uint64 :endofFile
  uint32 :fileAttributes
end

class TreeDisconnectRequest < BinData::Record
  endian :little
  nbss :nbssHead
  smbHead :smbHead
  uint16 :structureSize, :value => 4
  uint16 :reserved, :value => 0

  def cal
    nbssHead.typeLen = self.num_bytes - 4
    smbHead.command = SMB2_TREE_DISCONNECT
    smbHead.messageId = $msgId += 1
    smbHead.sessionId = $sessionId
    smbHead.treeId = $treeId
  end
end

class TreeDisconnectResponse < BinData::Record
  endian :little
  nbss :nbssHead
  smbHead :smbHead
  uint16 :structureSize, :value => 4
  uint16 :reserved, :value => 0
end

class LogoffRequest < BinData::Record
  endian :little
  nbss :nbssHead
  smbHead :smbHead
  uint16 :structureSize, :value => 4
  uint16 :reserved, :value => 0

  def cal
    nbssHead.typeLen = self.num_bytes - 4
    smbHead.command = SMB2_LOGOFF
    smbHead.messageId = $msgId += 1
    smbHead.sessionId = $sessionId
  end
end

class LogoffResponse < BinData::Record
  endian :little
  nbss :nbssHead
  smbHead :smbHead
  uint16 :structureSize, :value => 4
  uint16 :reserved, :value => 0
end
