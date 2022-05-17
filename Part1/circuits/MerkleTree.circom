pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/poseidon.circom";
include "../node_modules/circomlib/circuits/Switcher.circom";

template BuildRow(width_in) {
    var width_out = width_in / 2;
    signal input in[width_in];

    signal output out[width_out];

    component hash_fns[width_out];

    for(var i = 0; i < width_out; i++) {
        hash_fns[i] = Poseidon(2);
        hash_fns[i].inputs[0] <== in[i * 2];
        hash_fns[i].inputs[1] <== in[i * 2+ 1];

        out[i] <== hash_fns[i].out;
    }
}

template CheckRoot(depth) { // compute the root of a MerkleTree of n Levels 
    signal input leaves[2**depth];
    signal output root;
    component rows[depth];
    component t[2**depth];

    for(var i = 0; i < depth; i++) {
        var nodes_in_row = 2 ** (depth - i);
        rows[i] = BuildRow(nodes_in_row);
        for(var k = 0; k < nodes_in_row; k++) {
            rows[i].in[k] <== i == 0 ? leaves[k] : rows[i - 1].out[k];
         }
    }
    root <== rows[depth - 1].out[0];
}

template MerkleTreeInclusionProof(n) {
    signal input leaf;
    signal input path_elements[n];
    signal input path_index[n]; // proof index are 0's and 1's indicating whether the current element is on the left or right

    signal output root; // note that this is an OUTPUT signal

    // n array of path_index computations
    component switchers[n];
    // n array of poseidon hash functions
    component hashers[n];

    for (var i = 0; i < n; i++) {
        // instantiate a switcher that will swap the values of L and R depending on input
        switchers[i] = Switcher();
        // set the switchers selector - what decides output position - to the path_index, which is 0 or 1
        switchers[i].sel <== path_index[i];
        // instantiate the poseidon hash circuit
        hashers[i] = Poseidon(2);

        // set input 1 to either the leaf (the first hash) or the previous iteration's hash
        switchers[i].L <== i == 0 ? leaf : hashers[i - 1].out;
        // set input 2 to the proof element
        switchers[i].R <== path_elements[i];

        // based on the path_index - which tells us the input and outputs - set the R and L values on the poseidon hash input
        hashers[i].inputs[0] <== switchers[i].outL;
        hashers[i].inputs[1] <== switchers[i].outR;
    }

    // after all iterations, the root will be `hash`
    root <== hashers[n - 1].out;
}