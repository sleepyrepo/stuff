#!/usr/bin/ruby
#encoding: ascii-8bit

#gem install bindata
#gem install rubyntlm
require"bindata"
require"socket"
require"rubyntlm"
require_relative"packets"
require_relative"constantGssSpnego"

$sessionId = 0
$msgId = 0
$treeId = 0
$fileId = 0

ip = "10.0.0.10"
port = 445
user = "administrator"
pass = "pass1234"
ops = { :domain => ".", 
	:workstation => "WORKSTATION" }
share = "\\\\#{ip}\\ADMIN$"

TCPSocket.open(ip, port) do |s|
  puts""
  puts"NegotiateRequest"
  ngReq = NegotiateRequest.new
  ngReq.cal
  p ngReq
  s.print(ngReq.to_binary_s)

  puts""
  puts"NegotiateResponse"
  p ngRes = NegotiateResponse.read(s.recv(0xffff))

  puts""
  puts"SessionSetup NTLM negotiate"
  setupReq = SessionSetupRequest.new
  #somehow workstation is required regardless of flags :TARGET_INFO
  client = Net::NTLM::Client.new(user, pass, ops)
  t1 = client.init_context()

#p t1.serialize.unpack("H*")
#t1 = Net::NTLM::Message::Type1.new()
#t1.flag = 0x8200
#t1.workstation = "WORKSTATION"
#t1.domain = "."
#setupReq.buffer =  gssapi + Net::NTLM::Message::Type1.new().serialize

  setupReq.buffer =  negTokenInit1(t1.serialize)
  setupReq.cal
  p setupReq
  s.print(setupReq.to_binary_s)

  puts""
  puts"SessionSetup NTLM challenge"
  p setupRes = SessionSetupResponse.read(s.recv(0xffff))
  $sessionId = setupRes.smbHead.sessionId

  puts""
  puts"SessionSetup NTLM authenticate"
  setupReq = SessionSetupRequest.new
  challenge = [setupRes.buffer[/NTLMSSP.+/]].pack("m")
  t3 = client.init_context(challenge)

  setupReq.buffer =  negTokenTarg3(t3.serialize)
  setupReq.cal
  p setupReq
  s.print(setupReq.to_binary_s)

  puts""
  puts"SessionSetup NTLM results"
  p setupRes = SessionSetupResponse.read(s.recv(0xffff))

  puts""
  puts"TreeConnectRequest"
  tcReq = TreeConnectRequest.new
  tcReq.buffer = share.bytes.pack("v*")
  tcReq.cal
  p tcReq
  s.print(tcReq.to_binary_s)

  puts""
  puts"TreeConnectResponse"
  p setupRes = TreeConnectResponse.read(s.recv(0xffff))
  $treeId = setupRes.smbHead.treeId

  puts""
  puts"CreateRequest"
  createReq = CreateRequest.new
  #createReq.buffer = ""
  createReq.cal
  p createReq
  p createReq.to_binary_s.unpack("H*")
  s.print(createReq.to_binary_s)

  puts""
  puts"CreateResponse"
  p createRes = CreateResponse.read(s.recv(0xffff))
  $fileId = createRes.fileId

  puts""
  puts"QueryDirectoryRequest"
  qdReq = QueryDirectoryRequest.new
  qdReq.fileId = $fileId
  qdReq.buffer = "*".unpack("c*").pack("v*")		#pattern name must be unicode
  qdReq.cal
  p qdReq
  s.print(qdReq.to_binary_s)

  sleep(0.5)						#give time for dir list packets to arrive
  puts""
  puts"QueryDirectoryResponse"
  qdRes = QueryDirectoryResponse.read(s.recv(0xffff))
  p qdRes
  qdRes.list.each{|e| print e.fileName.unpack("v*").pack("c*")," "}

  puts""
  puts"CloseRequest"
  cReq = CloseRequest.new
  cReq.fileId = $fileId
  cReq.cal
  p cReq
  s.print(cReq.to_binary_s)

  puts""
  puts"CloseResponse"
  p CloseResponse.read(s.recv(0xffff))

  puts""
  puts"TreeDisconnectRequest"
  tdReq = TreeDisconnectRequest.new
  tdReq.cal
  p tdReq
  s.print(tdReq.to_binary_s)

  puts""
  puts"TreeDisconnectResponse"
  p TreeDisconnectResponse.read(s.recv(0xffff))


  puts""
  puts"LogoffRequest"
  loReq = LogoffRequest.new
  loReq.cal
  p loReq
  s.print(loReq.to_binary_s)

  puts""
  puts"LogoffResponse"
  p loRes = LogoffResponse.read(s.recv(0xffff))
end
