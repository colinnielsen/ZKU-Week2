#!/bin/bash
cd circuits

if [ -f ./powersOfTau28_hez_final_15.ptau ]; then
    echo "powersOfTau28_hez_final_15.ptau already exists. Skipping."
else
    echo 'Downloading powersOfTau28_hez_final_15.ptau'
    curl https://hermez.s3-eu-west-1.amazonaws.com/powersOfTau28_hez_final_15.ptau -o powersOfTau28_hez_final_15.ptau
fi

echo "input circuit name"
read NAME

echo "Compiling ${NAME}.circom..."

# compile circuit

circom ${NAME}.circom --r1cs
snarkjs r1cs info ${NAME}.r1cs

# Start a new zkey and make a contribution

snarkjs groth16 setup ${NAME}.r1cs powersOfTau28_hez_final_15.ptau ${NAME}_0000.zkey
snarkjs zkey contribute ${NAME}_0000.zkey ${NAME}_final.zkey --name="1st Contributor Name" -v -e="random text"

rm ${NAME}.r1cs
rm ${NAME}_0000.zkey

cd ../