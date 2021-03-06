#    This file is part of Metasm, the Ruby assembly manipulation suite
#    Copyright (C) 2007 Yoann GUILLOT
#
#    Licence is LGPL, see LICENCE in the top-level directory

require 'metasm/exe_format/main'

module Metasm
# special class that decodes a PE or ELF file from its signature
# does not support other exeformats (for now)
class AutoExe < ExeFormat
class UnknownSignature < InvalidExeFormat ; end
def self.load(str, *a)
	s = str
	s = str.data if s.kind_of? EncodedData
	execlass_from_signature(s).load(str, *a)
end
def self.execlass_from_signature(raw)
	if raw[0, 4] == "\x7fELF"; ELF
	elsif off = raw[0x3c, 4].unpack('V').first and raw[off, 4] == "PE\0\0"; PE
	else raise UnknownSignature, 'unrecognized executable file format'
	end
end
def self.orshellcode(cpu=Ia32.new)
	# here we create an anonymous subclass of AutoExe whose #exe_from_sig is patched to return a Shellcode if no signature is recognized (instead of raise()ing)
	c = Class.new(self)
	# yeeehaa
	class << c ; self ; end.send(:define_method, :execlass_from_signature) { |raw|
		begin
			super
		rescue UnknownSignature
			Shellcode.withcpu(cpu)
		end
	}
	c
end
end
end