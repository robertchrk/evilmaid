#!/bin/bash

echo "Decrypting hash database & checking hashes..."
if [[ $(gpg2 --decrypt ./hash.enc) != $(find /boot/ -type f -exec shasum -a 512 {} \; | shasum -a 512) ]]
then
	say "Warning! Hashes changed!"
	echo "Hashes changed, check if there was an update!"
else
	echo "It's okay, move on!"
fi
