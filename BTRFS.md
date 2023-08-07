sudo dd if=/dev/urandom of=/dev/sdX bs=4096 status=progress
sudo fdisk /dev/sdX
g
n
<enter>
<enter>
<enter>
w

sudo cryptsetup --verbose --verify-passphrase luksFormat /dev/sdXY
sudo cryptsetup open /dev/sdXY root
sudo mkfs.btrfs --verbose --label backup1 --checksum xxhash --data single --metadata dup /dev/mapper/root
sudo mkdir -p /mnt/backup1
sudo mount -o compress-force=zstd /dev/mapper/root /mnt/backup1
sudo chown moritz:users /mnt/backup1


sudo btrfs subvolume create /mnt/backup1/nixstore
sudo mkdir -p /mnt/nixstore
sudo mount -o subvol=nixstore -o compress-force=zstd /dev/mapper/root /mnt/nixstore
compsize /mnt/nixstore

sudo umount /mnt/backup1
sudo cryptsetup close root

sudo btrfs subvolume create /mnt/backup1/nixstore2
sudo mkdir -p /mnt/nixstore2
sudo mount -o subvol=nixstore2 -o compress-force=zstd /dev/mapper/root /mnt/nixstore2
sudo rsync -ah --progress /nix/store /mnt/nixstore2
duperemove -r -d -A -h -v --hashfile=/mnt/nixstore2/hashfile /mnt/nixstore2/
compsize /mnt/nixstore2


bees for block level deduplication
