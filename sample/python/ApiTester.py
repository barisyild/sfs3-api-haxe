import SFS3_API_PY as _api

SFSObject = _api.com_smartfoxserver_v3_entities_data_SFSObject
SFSArray = _api.com_smartfoxserver_v3_entities_data_SFSArray

#
# Long values crash encoder
#
def testCrashOnLong():
	import math
	sfso = SFSObject()
	sfso.putLong("long", int(math.pow(2,61)))

	## Also crashes when cast to integer:
	# sfso.putLong("long", int(math.pow(2,61)))
	
	print(sfso.getDump())		## works
	print(sfso.getHexDump())	## crash on encoding

#
# No type checking
# Will cause random bugs at runtime
#
def testTypeChecks():
	sfso = SFSObject()
	sfso.putShortString("Hello", "World")
	sfso.putIntArray("ints", "Hello") ## Should fire an exception 
	print(sfso.getDump()) ## Prints data types as numbers, rather than the correct description

	res = sfso.getIntArray("ints")
	print(f"Integers: {res}")

#
# Crashes on encoding
#
def testEncoding():
	sfso = testData()
	bytes = sfso.toBinary()
	

# Moderately complex object
def testData():
	import random
	rngSize = 2 * 1024
	rngBytes = [random.randrange(256) for _ in range(rngSize)]
	
	sfso = SFSObject()
	sfso.putNull("nil")
	sfso.putByte("byte", 0xFF)
	sfso.putBool("bool", True)
	sfso.putShort("short", 16)
	sfso.putInt("int", 85 * 1000)
	sfso.putFloat("float",  10.33)
	sfso.putDouble("double", 3.14)
	sfso.putLong("long", 2 ^ 55)
	sfso.putShortString("sstr", "Hello this is a short string")
	sfso.putString("str", "Hello this is a bit of a longer string, with a bunch more words and charachters")
	sfso.putText("text", "Some Text")
	sfso.putByteArray("bytes", rngBytes)
	sfso.putBoolArray("bools", [True, True, False, False, True])
	sfso.putShortArray("shorts", [ 20, 1, -10,  55, 33, -1552, 788])
	sfso.putIntArray("ints", [120, -311, 10, 755, 3030, -10552, 99788, 11551, -33792])
	sfso.putLongArray("longs", [1550020, 19700500111, -1450000, 55000700122, 30303030, -1552000, 9988788])
	sfso.putFloatArray("floats", [ 1/2, 5/3, 7/3, 19/7, 31/2])
	sfso.putDoubleArray("doubles", [ 1/2, 5/3, 7/3, 19/7, 31/2])

	sfso.putShortStringArray("sstrs", [
		"alpha",
		"beta",
		"gamma",
		"delta",
		"epsilon"
	]);
	
	sfso.putStringArray("strs", [
		"Alpha",
		"Beta",
		"Gamma",
		"Delta",
		"Epsilon"
	]);
	
	vic20 = SFSObject()
	vic20.putString("Brand", "Commodore")
	vic20.putString("Model", "VIC20")
	vic20.putString("CPU", "MOS 6502")
	vic20.putString("RAM", "5KB")
	vic20.putString("ROM", "20KB")
	vic20.putString("Storage", "Cassette Tape")
	
	commodores = SFSArray()
	commodores.addShortString("C16")
	commodores.addShortString("C64")
	commodores.addShortString("C128")
	commodores.addShortString("Amiga 500")

	numbers = SFSArray()
	numbers.addShortArray([ 1, 2, 3, 4, 5, 6 ])
	numbers.addIntArray([ 10, 20, 30, 40, 50, 60 ])
	numbers.addLongArray([ 100, 200, 300, 400, 500, 600 ])
	numbers.addFloatArray([ 1.1, 2.2, 3.3, 4.4, 5.5, 6.6 ])
	
	sfso.putSFSObject("sfsobj", vic20)
	sfso.putSFSArray("sfsArr", commodores)
	sfso.putSFSArray("numbers", numbers)

	return sfso

#
# Crashes on decode -- Original object:
#
#	var sfso = new SFSObject();
#	sfso.putSFSObject("emptySFSO", new SFSObject());
#	sfso.putString("str", "Nested arrays test");
#	sfso.putSFSArray("emptySFSA", new SFSArray());
#	sfso.putStringArray("strs", List.of("a", "b", "c", "d", "e", "f", "g", "h", "i", "l", "m", "n"));
#	sfso.putIntArray("ints", List.of());
#	sfso.putString("chars", "... ))) {{{[[[ ((( ...");
#	sfso.putDoubleArray("doubles", List.of(0.1,0.2,0.3,0.4));
#	sfso.putShortString("sstr", "a short string");
#
def testDecoder():
	bytes = [0x12, 0x00, 0x08, 0x03, 0x73, 0x74, 0x72, 0x08, 0x00, 0x12, 0x4E, 0x65, 0x73, 0x74, 0x65, 0x64, 0x20, 0x61, 0x72, 0x72, 0x61, 0x79, 0x73, 0x20, 0x74, 0x65, 0x73, 0x74, 0x04, 0x73, 0x74, 0x72, 0x73, 0x10, 0x00, 0x0C, 0x00, 0x01, 0x61, 0x00, 0x01, 0x62, 0x00, 0x01, 0x63, 0x00, 0x01, 0x64, 0x00, 0x01, 0x65, 0x00, 0x01, 0x66, 0x00, 0x01, 0x67, 0x00, 0x01, 0x68, 0x00, 0x01, 0x69, 0x00, 0x01, 0x6C, 0x00, 0x01, 0x6D, 0x00, 0x01, 0x6E, 0x09, 0x65, 0x6D, 0x70, 0x74, 0x79, 0x53, 0x46, 0x53, 0x41, 0x11, 0x00, 0x00, 0x04, 0x69, 0x6E, 0x74, 0x73, 0x0C, 0x00, 0x00, 0x07, 0x64, 0x6F, 0x75, 0x62, 0x6C, 0x65, 0x73, 0x0F, 0x00, 0x04, 0x3F, 0xB9, 0x99, 0x99, 0x99, 0x99, 0x99, 0x9A, 0x3F, 0xC9, 0x99, 0x99, 0x99, 0x99, 0x99, 0x9A, 0x3F, 0xD3, 0x33, 0x33, 0x33, 0x33, 0x33, 0x33, 0x3F, 0xD9, 0x99, 0x99, 0x99, 0x99, 0x99, 0x9A, 0x09, 0x65, 0x6D, 0x70, 0x74, 0x79, 0x53, 0x46, 0x53, 0x4F, 0x12, 0x00, 0x00, 0x04, 0x73, 0x73, 0x74, 0x72, 0x13, 0x0E, 0x61, 0x20, 0x73, 0x68, 0x6F, 0x72, 0x74, 0x20, 0x73, 0x74, 0x72, 0x69, 0x6E, 0x67, 0x05, 0x63, 0x68, 0x61, 0x72, 0x73, 0x08, 0x00, 0x16, 0x2E, 0x2E, 0x2E, 0x20, 0x29, 0x29, 0x29, 0x20, 0x7B, 0x7B, 0x7B, 0x5B, 0x5B, 0x5B, 0x20, 0x28, 0x28, 0x28, 0x20, 0x2E, 0x2E, 0x2E]
	SFSObject.newFromBinaryData(bytes)

## All these tests have issues
def main():
	testDecoder()
	testCrashOnLong()
	testEncoding()
	testTypeChecks()

if __name__ == '__main__':
	main()

