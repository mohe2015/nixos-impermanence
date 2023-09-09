# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, nixpkgs, home-manager, impermanence, rust-overlay, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      home-manager.nixosModule
      impermanence.nixosModules.impermanence
    ];

xdg.portal.enable = true;

  boot.blacklistedKernelModules = [ "hid_logitech_dj" ];

  systemd.services = {
    /*
     * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#LogFilterPatterns=
     * https://forum.manjaro.org/t/stable-update-2023-06-04-kernels-gnome-44-1-plasma-5-27-5-python-3-11-toolchain-firefox/141610/3
     * do not log messages with the following regex
     */
    "user@" = {
      overrideStrategy = "asDropin";
      serviceConfig = {
        LogFilterPatterns = [
          #"~QML"
          #"~QObject:"
          #"~QFont::"
          "~kwin_screencast: Dropping"
        ];
      };
    };
  };

  services.avahi.enable = true;
  services.avahi.nssmdns = true;
  #  services.beesd = {
  #    filesystems = {
  #      backup1 = {
  #        spec = "/mnt/nixstore/";
  #       hashTableSizeMB = 4096;
  ##       extraOptions = [ "--thread-count" "1" "--loadavg-target" "2" ];
  #     };
  #   };
  # };

  security.pam.loginLimits = [{
    domain = "*";
    type = "soft";
    item = "nofile";
    value = "52428800";
  }
    {
      domain = "*";
      type = "hard";
      item = "nofile";
      value = "52428800";
    }];

  #  boot.supportedFilesystems = [ "ecryptfs" ];

  programs.fuse.userAllowOther = true;

  zramSwap = {
    enable = true;
    memoryPercent = 200;
    #writebackDevice = "/dev/disk/by-uuid/c9534520-b58d-4bc2-9a51-0978fd64e1ce";
  };

  systemd.oomd = {
    enableRootSlice = true;
    enableSystemSlice = true;
    enableUserServices = true;
  };

  #nix.settings.auto-optimise-store = true;

  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "moritz" ];
  #virtualisation.virtualbox.guest.enable = true; # broken
  # virtualisation.virtualbox.guest.x11 = true; broken


  systemd.tmpfiles.rules = [
    "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.hip}"
  ];

  hardware.opengl.driSupport = true;
  # For 32 bit applications
  hardware.opengl.driSupport32Bit = true;

  #  hardware.opengl.extraPackages = with pkgs; [
  #    rocm-opencl-icd
  #    rocm-opencl-runtime
  #  ];

  services.minio = {
    enable = true;
  };
  services.gitlab-runner = {
    clear-docker-cache.enable = true;
    clear-docker-cache.dates = "hourly";
    enable = true;
    settings = {
      concurrent = 1;
    };
    services = {
      default = {
        # File should contain at least these two variables:
        # `CI_SERVER_URL`
        # `REGISTRATION_TOKEN`
        registrationConfigFile = "/nix/persistent/gitlab-runner";
        dockerImage = "debian:stable";
        # https://docs.gitlab.com/runner/configuration/advanced-configuration.html#the-runnerscache-section
        registrationFlags = [
          "--docker-host=tcp://127.0.0.1:2375"
          "--cache-type=s3"
          "--cache-shared=true"
          "--cache-s3-server-address=127.0.0.1:9000"
          #  "--cache-path=/var/lib/gitlab-runner/.gitlab-runner/cache"
          "--docker-network-mode=host"
          "--cache-s3-access-key=minioadmin"
          "--cache-s3-secret-key=minioadmin"
          "--cache-s3-bucket-name=test"
          "--cache-s3-insecure=true"
        ];
      };
    };
  };

  # both kernels sometimes work
  #boot.kernelPackages = pkgs.linuxPackages_latest;

  services.flatpak.enable = false;

  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      seccomp-profile = ./moby-seccomp-default.json; # callgrind in docker
    };
    listenOptions = [
      "/run/docker.sock"
      "0.0.0.0:2375"
    ];
  };

  virtualisation = {
    podman = {
      enable = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  programs.command-not-found.enable = false;

  # don't hang the whole network
  # https://discourse.nixos.org/t/system-autoupgrade-nearly-halts-my-system-even-though-nixos-rebuild-doesnt/23820/3
  nix.daemonCPUSchedPolicy = "idle";
  nix.daemonIOSchedClass = "idle";
  nix.daemonIOSchedPriority = 7;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  services.fwupd.enable = true;

  nixpkgs.overlays = [ rust-overlay.overlays.default ];

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "steam"
    "steam-original"
    "steam-run"
    #"discord"
    "vscode"
    "android-studio-stable"
    "android-studio-canary"
    "veracrypt"
  ];

  programs.wireshark.enable = true;
  programs.wireshark.package = pkgs.wireshark;

  programs.steam.enable = false;

  home-manager.users.moritz = {
    home.homeDirectory = "/home/moritz";
    imports = [ impermanence.nixosModules.home-manager.impermanence ];

    home.sessionVariables = {
      QT_QPA_PLATFORM = "wayland";
      CLUTTER_BACKEND = "wayland";
      SDL_VIDEODRIVER = "wayland";
      #NIXOS_OZONE_WL = "1";
    };

    home.sessionPath = [
      "$HOME/.cargo/bin"
    ];

    services.easyeffects.enable = true;
    services.flameshot.enable = true;
    #services.kdeconnect = {
    #  enable = true;
    #  indicator = true;
    #};

    programs = {
      home-manager.enable = true;
      git = {
        enable = true;
        lfs.enable = true;
        userName = "Moritz Hedtke";
        userEmail = "Moritz.Hedtke@t-online.de";
      };
      bash = {
        enable = true;
      };
      gpg.enable = true;
      nix-index.enable = false;
    };

    services.gpg-agent = {
      enable = true;
      enableSshSupport = true;
      enableBashIntegration = true;
    };

    home.packages = [
      #pkgs.btrfs-progs
      pkgs.gparted
      #pkgs.valgrind
      #pkgs.gnuplot
      pkgs.nixpkgs-fmt
      pkgs.git
      #pkgs.gdb
      pkgs.firefox
      #pkgs.discord
      #pkgs.gimp
      pkgs.hwloc
      pkgs.libreoffice-fresh
      pkgs.thunderbird
      pkgs.vscode
      #pkgs.bubblewrap
      #pkgs.chromium
      #pkgs.tor-browser-bundle-bin
      #pkgs.texstudio
      pkgs.texlive.combined.scheme-full
      pkgs.signal-desktop
      #pkgs.xournalpp
      #(pkgs.rust-bin.stable.latest.default.override {
      #  extensions = [ "rust-analyzer" "rust-src" ];
      #  targets = [ "wasm32-unknown-unknown" ];
      #})
      #pkgs.wasm-pack
      #pkgs.wasm-bindgen-cli
      #pkgs.gcc
      #pkgs.pdfgrep
      pkgs.openjdk20
      #pkgs.lyx
      #pkgs.heroic
      #pkgs.vlc
      #pkgs.godot_4
      #pkgs.pympress
      pkgs.filelight
      #pkgs.yarn
      #pkgs.nodejs_latest
      #pkgs.sccache
      #pkgs.iotop
      pkgs.htop
      #pkgs.duperemove
      #pkgs.compsize
      #pkgs.androidStudioPackages.canary
      pkgs.rpi-imager
      #pkgs.gh
      #pkgs.anki-bin
      #pkgs.xorg.xeyes
      #pkgs.kalendar
      #pkgs.libsForQt5.kdepim-addons
      #pkgs.fd
      pkgs.file
      #pkgs.parted
      #pkgs.rnix-lsp
      #pkgs.nil
      #pkgs.nixd
      #pkgs.prismlauncher
      pkgs.gnumake
      #pkgs.jq
      pkgs.arp-scan
    ];

    # /run/current-system/activate
    home.persistence."/nix/persistent/home/moritz" = {
      allowOther = true;
      directories = [
        { directory = ".local/state/home-manager"; method = "bindfs"; }
        { directory = "Android"; method = "symlink"; }
        { directory = "AndroidStudioProjects"; method = "symlink"; }
        { directory = "Downloads"; method = "symlink"; }
        { directory = "Music"; method = "symlink"; }
        { directory = "Pictures"; method = "symlink"; }
        { directory = "Documents"; method = "symlink"; }
        { directory = "Videos"; method = "symlink"; }
        { directory = ".mozilla"; method = "symlink"; }
        { directory = ".config/libreoffice"; method = "symlink"; }
        { directory = ".local/share/kscreen"; method = "symlink"; } # start on external screen by default
        { directory = ".local/share/konsole"; method = "symlink"; } # profile with infinite scrollback
        { directory = ".ssh"; method = "symlink"; }
        { directory = ".local/share/Trash"; method = "symlink"; }
        { directory = ".local/share/Anki2"; method = "symlink"; }
        # found using
        # systemctl --user stop pipewire.service
        # systemctl --user stop pipewire-pulse.service
        { directory = ".local/state/wireplumber"; method = "symlink"; } # restore audio volumes
        { directory = ".local/share/docker"; method = "symlink"; }
        { directory = ".config/discord"; method = "symlink"; } # "config"
        { directory = ".mozilla"; method = "symlink"; }
        { directory = ".config/VSCodium"; method = "symlink"; } # "config"
        { directory = ".config/Code"; method = "symlink"; }
        { directory = ".vscode"; method = "symlink"; }
        { directory = ".vscode-oss"; method = "symlink"; }
        { directory = ".steam"; method = "symlink"; }
        { directory = ".local/share/Steam"; method = "symlink"; }
        { directory = ".thunderbird"; method = "symlink"; }
        { directory = ".config/chromium/"; method = "symlink"; }
        { directory = ".config/easyeffects"; method = "symlink"; }
        { directory = ".cargo"; method = "symlink"; }
        # { directory = ".rustup"; method = "symlink"; }
        { directory = ".local/share/tor-browser"; method = "symlink"; }
        { directory = ".config/Signal"; method = "symlink"; }
        { directory = ".local/share/flatpak/"; method = "symlink"; }
        { directory = ".config/heroic/"; method = "symlink"; }
        { directory = ".config/legendary"; method = "symlink"; }
        { directory = ".local/share/godot"; method = "symlink"; }
        { directory = ".config/godot"; method = "symlink"; }
        { directory = "Games"; method = "symlink"; }
        { directory = ".local/share/PrismLauncher"; method = "symlink"; }
        { directory = ".ecryptfs"; method = "symlink"; }
        { directory = ".Private"; method = "symlink"; }
        { directory = ".local/share/containers"; method = "symlink"; }
      ];
      files = [
        ".bash_history"
        ".config/konsolerc" # set default profile
        #".config/plasma-org.kde.plasma.desktop-appletsrc" # taskbar pins
        #".gtkrc-2.0" # dark theme
        ".config/kcminputrc" # touchpad tap to click
        ".config/baloofilerc" # disable baloo
        ".config/mimeapps.list" # default applications
        ".cache/nix-index/files"
      ];
    };

    home.stateVersion = "23.05";
  };

  environment.persistence."/nix/persistent" = {
    hideMounts = true;
    directories = [
      "/etc/nixos"
      "/var/lib/nixos"
      "/var/lib/docker"
      "/var/log"
      "/var/lib/systemd/coredump"
      "/var/lib/bluetooth"
      "/var/lib/flatpak"
      "/var/lib/minio/"
    ];
    files = [
      "/etc/machine-id"
      "/crypto_keyfile.bin"
    ];
  };

  hardware.enableRedistributableFirmware = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  boot.kernelModules = [ "ecryptfs" ];

  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  # Enable swap on luks
  boot.initrd.luks.devices."luks-c29ff28a-c246-42b7-b1ea-0c3c8d58cc4f".device = "/dev/disk/by-uuid/c29ff28a-c246-42b7-b1ea-0c3c8d58cc4f";
  boot.initrd.luks.devices."luks-c29ff28a-c246-42b7-b1ea-0c3c8d58cc4f".keyFile = "/crypto_keyfile.bin";

  networking.hostName = "nixos"; # Define your hostname.
  networking.wireless = {
    enable = true;
    userControlled.enable = true;
    scanOnLowSignal = false;
    fallbackToWPA2 = false;

    environmentFile = "/nix/persistent/eduroam";
    networks = {
      eduroam = {
        auth = ''
          ssid="eduroam"
          key_mgmt=WPA-EAP
          eap=PEAP
          identity="@IDENTITY@"
          password="@PASSWORD@"
          domain_suffix_match="radius.hrz.tu-darmstadt.de"
          anonymous_identity="eduroam@tu-darmstadt.de"
          phase2="auth=MSCHAPV2"
          ca_cert="/etc/ssl/certs/ca-bundle.crt"
          wpa_deny_ptk0_rekey=1
        '';
      };
      MagentaWLAN-L6J9 = {
        auth = ''
          ssid="MagentaWLAN-L6J9"
          psk="@HOME_PASSWORD@"
        '';
      };
      A = {
        auth = ''
          ssid="@A_SSID@"
          psk="@A_PASSWORD@"
        '';
      };
      CCC = {
        auth = ''
          ssid="darmstadt.ccc.de"
          key_mgmt=WPA-EAP
          eap=TTLS
          identity="random"
          password="@CCC_PASSWORD@"
          ca_cert="/etc/ssl/certs/ca-certificates.crt"
          altsubject_match="DNS:radius.w17.io"
          phase2="auth=PAP"
        '';
      };
    };
  };

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking = {
    useNetworkd = true;
    useDHCP = false;
  };
  systemd.network.enable = true;
  systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;
  systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;
  systemd.services.systemd-networkd.environment.SYSTEMD_LOG_LEVEL = "debug";
  systemd.network = {
    networks = {
      "10-local" = {
        matchConfig.Name = "enp1s0";
        networkConfig = {
          DHCP = "no";
          Address = "10.42.0.1/24";
          DHCPServer = "yes";
          IPForward = "yes";
          IPMasquerade = "yes";
          LLDP = "no";
        };
        dhcpServerConfig = {
          ServerAddress = "10.42.0.1/24";
          Router = "10.42.0.1";
        };
        dhcpServerStaticLeases = [{
          dhcpServerStaticLeaseConfig = {
            MACAddress = "00:e0:4c:68:57:c8";
            Address = "10.42.0.120";
          };
        }];
      };
      "20-enp" = {
        matchConfig.Name = "enp*";
        networkConfig.DHCP = "yes";
        networkConfig.LinkLocalAddressing = "ipv4";
        networkConfig.IPv6AcceptRA = "no";
        networkConfig.LLDP = "no";
      };
      "25-wlp" = {
        matchConfig.Name = "wlp*";
        networkConfig.DHCP = "yes";
        networkConfig.LinkLocalAddressing = "ipv4";
        networkConfig.IPv6AcceptRA = "no";
        networkConfig.LLDP = "no";
      };
      "25-bnep" = {
        matchConfig.Name = "bnep*";
        networkConfig.DHCP = "yes";
      };
    };
  };
  # TODO FIXME home wifi
  # TODO FIXME eduroam https://github.com/mohe2015/nixos/blob/main/hosts/nixos.nix

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  hardware.bluetooth.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  services.xserver.displayManager.defaultSession = "plasmawayland";

  # Configure keymap in X11
  services.xserver = {
    enable = true;
    layout = "de";
    xkbVariant = "";
    videoDrivers = [ "amdgpu" ];
  };

  # Configure console keymap
  console.keyMap = "de";

  # Enable CUPS to print documents.
  services.printing.enable = false;

  # Enable sound with pipewire.
  # /etc/udev/rules.d/90-alsa-restore.rules
  # udevadm test /sys/class/sound/card0/controlC0/
  # udevadm test /sys/class/sound/card1/controlC1/
  # https://github.com/NixOS/nixpkgs/issues/54387
  # works:
  # sudo /nix/store/9r1y944h5vwq661qd5698ydq09m7ywi8-alsa-utils-1.2.8/sbin/alsactl restore 1
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    wireplumber = {
      package = pkgs.wireplumber.override { pipewire = config.services.pipewire.package; };
    };
    package = pkgs.pipewire.override { libcameraSupport = false; };
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.moritz = {
    isNormalUser = true;
    description = "Moritz Hedtke";
    extraGroups = [ "wheel" "docker" "wireshark" ];
    initialHashedPassword = "$6$sUGOG4y2bxFFFsKS$EwMnQ0.qI/BsLCuMZ17bWreafcHfFLr/LDdjHpVBIoLHCu93nZKJAiedmXYyn3vU6f9watzoOgmuBKJMn4U/f/";
  };

  users.mutableUsers = false;

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.logRefusedConnections = false;
  networking.firewall.allowedTCPPorts = [ ];
  networking.firewall.allowedTCPPortRanges = [
    { from = 1714; to = 1764; } # KDE Connect
  ];
  networking.firewall.allowedUDPPortRanges = [
    { from = 1714; to = 1764; } # KDE Connect
  ];
  networking.firewall.allowedUDPPorts = [
    5353 # mdns
  ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false; # TODO FIXME

  #boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  #virtualisation.libvirtd = {
  #  enable = true;
  #  qemu.ovmf.packages = [ pkgs.OVMFFull.fd nixpkgs.legacyPackages.aarch64-linux.OVMF.fd ];
  #};
  programs.dconf.enable = true;
  #environment.systemPackages = with pkgs; [ virt-manager ];

  environment.sessionVariables = {
    TZDIR = "/etc/zoneinfo";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}
