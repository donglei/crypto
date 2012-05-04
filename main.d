module main;

import crypto.hash.sha1;
import crypto.blockcipher.aes;
import crypto.mode.ecb;

import std.stdio, std.algorithm, std.getopt, std.stream, std.cstream;


/*
 * Simple command line support for accessing functions.
 * Leaving out --in or --out will default to stdin and stdout.
 *
 * >crypto --hash sha1 -in <file>
 * >crypto --enc aes-128-ecb --in <file1> --out <file2> --key <key>
 * >crypto --dec aes-128-ecb --in <file2> --out <file1> --key <key>
*/

void execute(string[] args)
{
    string enc, dec, hash, input, output, key;
    getopt(args,
           "enc", &enc,
           "dec", &dec,
           "hash", &hash,
           "in", &input,
           "out", &output,
           "key", &key
    );

    // Initialize input/output streams to stdin/stdout
    InputStream inStream = din;
    OutputStream outStream = dout;
    if (input != null)
        inStream = new std.stream.File(input);
    if (output != null)
        outStream = new std.stream.File(output, FileMode.Out);
    
    // Encrypt
    if (enc != null)
    {
        switch (enc)
        {
            case "aes-128-ecb":
                auto k = parseHexString!(16)(key);
                auto ecb = new ECB(new AES128(k));
                ecb.encrypt(inStream, outStream);
                break;
            default:
                writeln("Valid parameters for --enc: \naes-128-ecb");
        }
    }

    // Decrypt
    else if (dec != null)
    {

    }

    // Hash
    else if (hash != null)
    {
        switch (hash)
        {
            case "sha1":
                auto sha1 = new SHA1();
                while (!inStream.eof())
                    sha1.put(inStream.readLine());
                outStream.writeLine(sha1.digestHex());
                break;
            default:
                writeln("Valid parameters for --hash: \nsha1");
        }
    }

    // Invalid command
    else
    {
        writeln("Invalid command. Use --enc for encryption, --dec for decryption or --hash for hashing");
    }
}


ubyte[k] parseHexString(uint k)(string s)
if (k % 2 == 0)
{
    char[] hex = cast(char[]) s;
    ubyte[char] lookup;
    lookup['0'] = 0x00; lookup['1'] = 0x01; lookup['2'] = 0x02; lookup['3'] = 0x03; lookup['4'] = 0x04; 
    lookup['5'] = 0x05; lookup['6'] = 0x06; lookup['7'] = 0x07; lookup['8'] = 0x08; lookup['9'] = 0x09;
    lookup['a'] = 0x0a; lookup['b'] = 0x0b; lookup['c'] = 0x0c; lookup['d'] = 0x0d; lookup['e'] = 0x0e; lookup['f'] = 0x0f;
    ubyte[k] res = 0;
    for (uint i = 0; i < hex.length; i += 2)
    {
        char a = hex[i], b = hex[i+1];
        if (!std.ascii.isHexDigit(a) || !std.ascii.isHexDigit(b))
            throw new Exception("Input not hexadecimal, "~s);
        res[i/2] = cast(ubyte) (lookup[a] << 4 | lookup[b]);
    }
    return res;
}


int main(string[] argv)
{
    try
    {
        execute(argv);
    }
    catch (Exception e)
    {
        writeln("Bad input");
        writeln(e);
    }

	return 0;
}
