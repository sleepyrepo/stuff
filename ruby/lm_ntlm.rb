#!/usr/bin/ruby

require"openssl"
pass = "pass12345678"

lmStr = 'KGS!@#$%'
#puts lmStr

#LM
LM_MAGIC = "KGS!@\#$%"                          #lm string to enctypt with DES
padded = pass.ljust(14, "\x00")                 #padd password with NULL to 14 bytes
passArr = padded.upcase.scan(/......./)         #split into array of 7 char string

keys = passArr.map do |k|                       #gen keys from each string by appending a "0" to each 7 bits chunk
  bits = k.unpack("B*")[0].scan(/......./)      #grab each 7 bits                 
  ext = bits.map{ |e| e + "0" }.join            #append a 0 to the end of it
  [ext].pack("B*")                              #pack it back
end

lm = keys.map do |k|
  des = OpenSSL::Cipher.new("DES")              #instance DEX cipher
  des.key = k                                   #set key
  des.encrypt                                   #set encrypt mode
  des.update(LM_MAGIC).unpack("H*")             #encrypt the lm string
end

#NTLM
md4 = OpenSSL::Digest.new("MD4")                #straight farward
u = pass.bytes.pack("v*")                       #md4 of a unic  
ode little endian password string
ntlm = md4.digest(u).unpack("H*")[0]

p [lm.join.upcase, ntlm.upcase]

#LM/LTLM library
#gem install smbhash
require"smbhash"                                #nice little library to make Lm/NTLM hash
puts"-"*80
#puts Smbhash.lm_hash(pass)
#puts Smbhash.ntlm_hash(pass)
p Smbhash.ntlmgen(pass)