#!/bin/bash

# Calculates, stores and encrypts hashes of /boot to be able to detect tampering.
# It's important to store hash.enc on a read-only device to make sure nobody can tamper your hashes.
# Use a OpenPGP smartcard!
# Todo: Adjust the recipient

echo "Calculating, storing and encrypting hashes..."
srm -z ./hash.enc
find /boot/ -type f -exec shasum -a 512 {} \; | shasum -a 512 | gpg2 --trust-model always -r USER --output ./hash.enc --encrypt
echo "Finished!"
