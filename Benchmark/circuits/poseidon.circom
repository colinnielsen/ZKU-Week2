pragma circom 2.0.3;

include "../circomlib/circuits/poseidon.circom";

template Example () {
    signal input a;
    signal output c;
    component hash = Poseidon(1);
    hash.inputs[0] <== a;

    c <== hash.out;
}

component main = Example();

/* INPUT = {
    "a": "1"
} */