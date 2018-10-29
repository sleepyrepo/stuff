SMB2_NEGOTIATE = 0x0000
SMB2_SESSION_SETUP = 0x0001
SMB2_LOGOFF = 0x0002
SMB2_TREE_CONNECT = 0x0003
SMB2_TREE_DISCONNECT = 0x0004
SMB2_CREATE = 0x0005
SMB2_CLOSE = 0x0006
SMB2_FLUSH = 0x0007
SMB2_READ = 0x0008
SMB2_WRITE = 0x0009
SMB2_LOCK = 0x000A
SMB2_IOCTL = 0x000B
SMB2_CANCEL = 0x000C
SMB2_ECHO = 0x000D
SMB2_QUERY_DIRECTORY = 0x000E
SMB2_CHANGE_NOTIFY = 0x000F
SMB2_QUERY_INFO = 0x0010
SMB2_SET_INFO = 0x0011
SMB2_OPLOCK_BREAK = 0x0012
SMB2_FLAGS_SERVER_TO_REDIR = 0x00000001
SMB2_FLAGS_ASYNC_COMMAND = 0x00000002
SMB2_FLAGS_RELATED_OPERATIONS = 0x00000004
SMB2_FLAGS_SIGNED = 0x00000008
SMB2_FLAGS_PRIORITY_MASK = 0x00000070
SMB2_FLAGS_DFS_OPERATIONS = 0x10000000
SMB2_FLAGS_REPLAY_OPERATION = 0x20000000
SMB2_NEGOTIATE_SIGNING_ENABLED = 0x0001
SMB2_NEGOTIATE_SIGNING_REQUIRED = 0x0002
SMB2_GLOBAL_CAP_DFS = 0x00000001
SMB2_GLOBAL_CAP_LEASING = 0x00000002
SMB2_GLOBAL_CAP_LARGE_MTU = 0x00000004
SMB2_GLOBAL_CAP_MULTI_CHANNEL = 0x00000008
SMB2_GLOBAL_CAP_PERSISTENT_HANDLES = 0x00000010
SMB2_GLOBAL_CAP_DIRECTORY_LEASING = 0x00000020
SMB2_GLOBAL_CAP_ENCRYPTION = 0x00000040

ASN1_BINARY      = 0x04
ASN1_OID         = 0x06
ASN1_ENUMERATED  = 0x0a
ASN1_SEQUENCE    = 0x30
ASN1_SET         = 0x31
ASN1_APPLICATION = 0x60
ASN1_CONTEXT     = 0xa0

OID_SPNEGO       = ["2b0601050502"].pack("H*")
OID_MECH_NTLMSSP = ["2b06010401823702020a"].pack("H*")
OID_MECH_NEGOEX  = '1.3.6.1.4.1.311.2.2.30'

SPNEGO_ACCEPT_COMPLETED  = 0
SPNEGO_ACCEPT_INCOMPLETE = 1
NTLMSSP_ID_STR = "NTLMSSP\0"
NTLMSSP_NEGOTIATE = 1
NTLMSSP_CHALLENGE = 2
NTLMSSP_AUTH      = 3
NTLMSSP_SIGNATURE = 4
NTLMSSP_ITEM_TERMINATOR    = 0
NTLMSSP_ITEM_NETBIOSHOST   = 1
NTLMSSP_ITEM_NETBIOSDOMAIN = 2
NTLMSSP_ITEM_DNSHOST       = 3
NTLMSSP_ITEM_DNSDOMAIN     = 4
NTLMSSP_ITEM_TIMESTAMP     = 7
NTLMSSP_FLAGS_CLIENT = 0x60008215
NTLMSSP_FLAGS_SERVER = 0x628a8215

def genAsn(tag, content)		#return asn1 string from tag and content
					#basic ASN1 = tag(1) + len(1..n) + content(...)
  conLen = ""				#hex representation of content len
  bytesUse = 0				#number of bytes needs to describe content len
  if content.bytesize >= 0x80		#ASN1 DER rule, if content len >= 128, set content 
					#len to 0x8[number ob bytes to dscribe contentlen]
					#and use following bytes to place content length
					#ie content len = 512 = 82 02 00 
    conLen = "%02x"%[content.bytesize]	#cpontent len in hex form
    conLen = "0" + conLen if conLen.bytesize % 2
					#prepend "0" if needed
    bytesUse = conLen.bytesize / 2	#find bytes needed to place content byte len
  else 
    conLen = "%02x"%[content.bytesize]	#if content len < 128 just use one byte
  end
  dataLen = bytesUse == 0? conLen : "8%i"%[bytesUse] + conLen
  dataLen = [dataLen].pack("H*")
  return [tag].pack("c") + dataLen + content
end


def negTokenInit1(token)		#only deal with NTLM for now
  mechToken = genAsn(0xa2, genAsn(ASN1_BINARY, token))
  mechTypeList = genAsn(0xa0, genAsn(ASN1_SEQUENCE, genAsn(ASN1_OID, OID_MECH_NTLMSSP))) if token[/NTLMSSP\x00/]
  negTokenInit = genAsn(0xa0, genAsn(ASN1_SEQUENCE, mechTypeList + mechToken))
  spnego = genAsn(ASN1_OID, OID_SPNEGO)
  gss = genAsn(ASN1_APPLICATION, spnego + negTokenInit)
  return gss
end

def negTokenTarg3(token)		#only deal with NTLM for now

  responseToken = genAsn(0xa2, genAsn(ASN1_BINARY, token))
  negTokenTarg = genAsn(0xa1, genAsn(ASN1_SEQUENCE, responseToken))
  return negTokenTarg
end

#pass = "123"
#gem install smbhash
#require"smbhash"
#puts"-"*80
#puts Smbhash.lm_hash(pass)
#puts Smbhash.ntlm_hash(pass)
#p Smbhash.ntlmgen(pass)

#NTLM negotiation message
#negotiateMessage = ""
#negotiateMessage << "NTLMSSP\x00"	#signature
#negotiateMessage << [1].pack("V")	#message type
#negotiateMessage << [0].pack("V")	#flags
#negotiateMessage <<			#8 DomainNameFields
#negotiateMessage <<			#8 WorkstationFields
#negotiateMessage <<			#8 version
#negotiateMessage << 			#payloas
#i.e. 
#"NTLMSSP\x00\x01\x00\x00\x007\x82\b\xE0\x00\x00\x00\x00 \x00\x00\x00\x00\x00\x00\x00 \x00\x00\x00kali"
#["4e544c4d53535000 01000000 378208e0 0000000020000000 0000000020000000 6b616c69"]


#challengeMessage = ""
#challengeMessage << "NTLMSSP\x00"	#signature
#challengeMessage << [2].pack("V")	#must be 2, message type
#challengeMessage << 			#8 TargetNameFields
#challengeMessage << [0].pack("V")	#NegotiateFlags
#challengeMessage << 			#8 ServerChallenge, (server NONCE)
#challengeMessage << [0].pack("q<") 	#8 reserved
#challengeMessage << 			#8 TargetInfoFields
#challengeMessage << 			#8 version
#challengeMessage << 			#payload

#4e544c4d53535000 02000000 1200120038000000 15828a62 b748dd298a7b1212 
#0000000000000000 680068004a000000 0601b11d0000000f 
#570049004e003700500052004f003600340002001200570049004e003700500052004f003600340001001200570049004e003700500052004f003600340004001200770069006e003700500072006f003600340003001200770069006e003700500072006f0036003400070008007accc14d7469d40100000000

#authenticationMessage = ""
#authenticationMessage << "NTLMSSP\x00"	#signature
#authenticationMessage << [3].pack("V")	#msg type, must be 3
#authenticationMessage << 		#8 LmChallengeResponseFields
#authenticationMessage << 		#8 NtChallengeResponseFields
#authenticationMessage << 		#8 DomainNameFields
#authenticationMessage << 		#8 UserNameFields
#authenticationMessage << 		#8 WorkstationFields
#authenticationMessage << 		#8 EncryptedRandomSessionKeyFields
#authenticationMessage << [0].pack("V")	#NegotiateFlags
#authenticationMessage <<		#8 version
#authenticationMessage <<		#16 MIC
#authenticationMessage <<		#payload


#-> session_setup + NTLM negotiation message
#<- session_setup + NTLM clallenge message(8 bytes challenge)
#-> session_setup + NTLM auth message
#<- session_setup SUCESS

=begin
http://luca.ntop.org/Teaching/Appunti/asn1.html
Class		Bit 8	Bit 7
universal	0	0
application	0	1
context-spec	1	0
private		1	1

Type		Tag number(decimal)	Tag number(hexadecimal)
INTEGER		2			02
BIT STRING	3			03
OCTET STRING	4			04
NULL		5			05
OID		6			06
SEQUENCE/OF	16			10
SET and SET OF	17			11
PrintableString	19			13
T61String	20			14
IA5String	22			16
UTCTime		23			17

#bits 6 = 0 = primitive encoding
#bitr 5-1 = tag number
https://msdn.microsoft.com/en-us/library/ms995330.aspx
ASN.1 DER Lengths
If a length is < 127, the lower 7 bits of the start byte will describe the length, 
and the uppermost bit will be zero (that is, the byte will be <= 0x7F). 
If the length is > 127, the uppermost bit will be 1 and the lower 7 bits will indicate 
how many following bytes are used to indicate the length 
(that is, 0x82 means that the following 2 bytes describe the length).

A sequence identifier is byte 0x30
NegTokenInit	0xa0 <followed by length>	0xa0, 0x82, 0x05, 0xd9
NegTokenTarg	0xa1 <followed by Length>	0xa1, 0x81, 0x85

type 1
60 48 = application 72 bytes = true		*generic GSS header*
      06 06 = OID 6 bytes = true SPNEGO		**
            2b0601050502 			**
      a0 3e = NegTokenInit 62 bytes = true
            30 3c = universal SEQUENCE 60 bytes = true
                  a0 0e = element[0] 14 bytes = true MechTypeList
                        30 0c universal 12 bytes = true 
                              06 0a = OID 10  bytes = true NTLMSSP
                                    2b06010401823702020a 
                  a2 2a element[2] 42 bytes = true MechToken
                        04 28 = universal OCTET STRING 40 bytes = true
                              4e544c4d53535000010000001582086200000000280000000000000028000000060100000000000f

NegTokenInit ::= SEQUENCE {
   mechTypes     [0]  MechTypeList  OPTIONAL,
   reqFlags      [1]  ContextFlags  OPTIONAL,
   mechToken     [2]  OCTET STRING  OPTIONAL,
   mechListMIC   [3]  OCTET STRING  OPTIONAL
}

#Unlike when a NegTokenInit is sent, the NegTokenTarg is not prepended by a generic GSS header
type 2 (response has no generic GSS header)

a1 81 ce = NegTokenTarg 206 bytes = true (len = 0x81, usu 0xce as len instaed)
      30 81 cb = universal SEQUENCE 203  bytes = true (len = 0x81, usu 0xcb as len instaed) 
               a0 03 = element[0] 3 bytes = true negResult = 1
                     0a 01 01 
               a1 0c = element[1] 12 bytes = true supportedMech
                     06 0a = OID 10 bytes = true NTLMSSP
                           2b06010401823702020a 
               a2 81 b5 = element[2] = 181 bytes = true responseToken (len = 0x81, usu 0xb5 as len instaed)
                        04 81 b2 = OCTET STRING 178 bytes = true (len = 0x81, usu 0xb5 as len instaed)
                                 4e544c4d5353500002000000120012003800000015828a62bb3c6ae6f10263280000000000000000680068004a0000000601b11d0000000f570049004e003700500052004f003600340002001200570049004e003700500052004f003600340001001200570049004e003700500052004f003600340004001200770069006e003700500072006f003600340003001200770069006e003700500072006f003600340007000800e43f04b2876dd40100000000

NegTokenTarg      ::=  SEQUENCE {
   negResult      [0]  ENUMERATED {
                            accept_completed (0),
                            accept_incomplete (1),
                            rejected (2) }  OPTIONAL,
   supportedMech  [1]  MechType             OPTIONAL,
   responseToken  [2]  OCTET STRING         OPTIONAL,
   mechListMIC    [3]  OCTET STRING         OPTIONAL
}

type 3

a1 82 01d8 = NegTokenTarg 472 bytes = true
           30 82 01d4 universal SEQUENCE 468  bytes = true 
                      a2 82 01bc element[2] =  444 bytes = true responseToken
                                 04 82 01b8 
                                            4e544c4d53535000030000001800180058000000040104017000000012001200740100001a001a008601000008000800a001000010001000a801000015820862060100000000000f8140ba6e44da9af484448f8db69988bc0000000000000000000000000000000000000000000000004d4f38335f5913353b2401437097c7680101000000000000e43f04b2876dd4014677be346b9443900000000002001200570049004e003700500052004f003600340001001200570049004e003700500052004f003600340004001200770069006e003700500072006f003600340003001200770069006e003700500072006f003600340007000800e43f04b2876dd401060004000200000008003000300000000000000000000000000000004b783396f2f5f7f32ca996e5ba7074eb2621c740a3a60f96ed6a995d20116b440a0010000000000000000000000000000000000009001c0063006900660073002f00310030002e0030002e0030002e00310030000000000057004f0052004b00470052004f0055005000610064006d0069006e006900730074007200610074006f0072004b0041004c00490056e2cacdecda9b1cbeb6400f0c3e261ba31204100100000061f1c6fdcdec7a0400000000
                      a3 12 element[3] =  18 bytes = false mechListMIC **not needed**
                            04 10 OCTET STRING 16 bytes = true
                                  0100000061f1c6fdcdec7a0400000000

last packet

a1 1b = NegTokenTarg 27 bytes = true
      30 19 universal SEQUENCE 25  bytes = true
            a0 03 element[0] 3 bytes = true negResult = 1
                  0a 01 00 
            a3 12 element[0] 3 bytes = true mechListMIC
                  04 10 OCTET STRING 16 bytes = true
                        0100000036f550446e396c0c00000000
=end

=begin
require"rubyntlm"

user = "administrator"
pass = "pass1234"
ops = { :domain => "WORKGROUP",
        :workstation => "badc0ffe" }

client = Net::NTLM::Client.new(user, pass, ops)
p t1 = client.init_context
p t1.serialize.unpack("H*")
puts"-"
t2 = "4e544c4d5353500002000000120012003800000015828a62b748dd298a7b12120000000000000000680068004a0000000601b11d0000000f570049004e0037$
bin = [t2].pack("H*")
t2_b64 = [bin].pack("m")
p t3 = client.init_context(t2_b64)
p t3.serialize.unpack("H*")
puts"-"

puts"-"*80
p t1 = Net::NTLM::Message::Type1.new()
p t1.serialize.unpack("H*")
puts"-"
bla = [t2].pack("H*")
p t2 = Net::NTLM::Message.parse(bla)
puts"-"
p t3 = t2.response({:user => user, :password => pass})
=end
