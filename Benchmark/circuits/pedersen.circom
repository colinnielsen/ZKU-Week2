pragma circom 2.0.3;

include "../circomlib/circuits/pedersen.circom";

template Example () {
    signal input a;
    signal input b;
    signal output c;
    
    component hash = Pedersen(2);
    hash.in[0] <== a;
    hash.in[1] <== b;

    log(hash.out[0]);
    c <== hash.out[0];
}

component main  = Example();

/* INPUT = {
    "a": "4",
    "b": "16"
} */
