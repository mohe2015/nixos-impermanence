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

sudo umount /mnt/backup1
sudo cryptsetup close root