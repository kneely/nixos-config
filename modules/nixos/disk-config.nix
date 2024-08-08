_: {
  disko.devices = {
    disk = {
      sda = {
        type = "disk";
        device = "/dev/disk/by-id/ata-SanDisk_SDSSDH3_512G_21400U805379";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              type = "EF00";
              size = "1G";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            root = {
              end = "-10G";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
            swap = {
              size = "100%";
              content = {
                type = "swap";
                discardPolicy = "both";
                resumeDevice = true; # resume from hiberation from this device
              };
            };
          };
        };
      };
      sdb = {
        type = "disk";
        device = "/dev/disk/by-id/ata-ST18000NM003D-3DL103_ZVT9H0WN";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "storage";
              };
            };
          };
        };
      };
      sdc = {
        type = "disk";
        device = "/dev/disk/by-id/ata-ST18000NM003D-3DL103_ZVT9PFC7";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "storage";
              };
            };
          };
        };
      };
    };
    zpool = {
      storage = {
        type = "zpool";
        mode = "mirror";
        mountpoint = "/storage";

        datasets = {
          media = {
            type = "zfs_fs";
            mountpoint = "/storage/media";
          };
          databases = {
            type = "zfs_fs";
            mountpoint = "/storage/dbs";
          };
          configs = {
            type = "zfs_fs";
            mountpoint = "/storage/configs";
          };
          docker = {
            type = "zfs_fs";
            mountpoint = "/storage/docker";
          };
          ai = {
            type = "zfs_fs";
            mountpoint = "/storage/ai";
          };
          misc = {
            type = "zfs_fs";
            mountpoint = "/storage/misc";
          };
        };
      };
    };
  };
}
