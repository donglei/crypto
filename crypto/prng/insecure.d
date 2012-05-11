module crypto.prng.insecure;

import crypto.prng.d;

class InsecurePRNG : PRNG
{
    override void nextBytes(ubyte[] buffer){
        buffer[] = 0x01;
    }
}