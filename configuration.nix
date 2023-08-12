# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, home-manager, impermanence, rust-overlay, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      home-manager.nixosModule
      impermanence.nixosModules.impermanence
    ];

#  services.beesd = {
#    filesystems = {
#      backup1 = {
#        spec = "/mnt/nixstore/";
 #       hashTableSizeMB = 4096;
 ##       extraOptions = [ "--thread-count" "1" "--loadavg-target" "2" ];
 #     };
 #   };
 # };

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

  nix.settings.auto-optimise-store = true;

  #virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "moritz" ];
  # virtualisation.virtualbox.guest.enable = true; # broken
  # virtualisation.virtualbox.guest.x11 = true; broken


  systemd.tmpfiles.rules = [
    "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.hip}"
  ];

  hardware.opengl.driSupport = true;
  # For 32 bit applications
  hardware.opengl.driSupport32Bit = true;

  hardware.opengl.extraPackages = with pkgs; [
    rocm-opencl-icd
    rocm-opencl-runtime
  ];

  services.minio = {
    enable = false;
  };
  services.gitlab-runner = {
    enable = false;
    settings = {
      concurrent = 50;
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
  boot.kernelPackages = pkgs.linuxPackages_latest;

  services.flatpak.enable = true;

  #virtualisation.docker.rootless = {
  #  enable = true;
  #  setSocketVariable = true;
  #};

  virtualisation = {
    podman = {
      enable = false;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  programs.dconf.enable = true;

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
  ];

  programs.fuse.userAllowOther = true;

  programs.steam.enable = false;

  home-manager.users.moritz = {
    home.homeDirectory = "/home/moritz";
    imports = [ impermanence.nixosModules.home-manager.impermanence ];

    home.sessionVariables = {
      QT_QPA_PLATFORM = "wayland";
      CLUTTER_BACKEND = "wayland";
      SDL_VIDEODRIVER = "wayland";
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
      nix-index.enable = true;
    };

    home.packages = [
      pkgs.btrfs-progs
      pkgs.gparted
      #pkgs.valgrind
      #pkgs.gnuplot
      pkgs.nixpkgs-fmt
      pkgs.git
      #pkgs.gdb
      pkgs.firefox
      #pkgs.discord
      #pkgs.gimp
      pkgs.libreoffice-fresh
      pkgs.betterbird
      pkgs.vscode
      #pkgs.bubblewrap
      pkgs.chromium
      #pkgs.tor-browser-bundle-bin
      #pkgs.texstudio
      #pkgs.texlive.combined.scheme-full
      pkgs.signal-desktop
      pkgs.xournalpp
      (pkgs.rust-bin.stable.latest.default.override {
        extensions = [ "rust-analyzer" "rust-src" ];
        targets = [ "wasm32-unknown-unknown" ];
      })
      pkgs.wasm-pack
      pkgs.wasm-bindgen-cli
      pkgs.gcc
      #pkgs.pdfgrep
      pkgs.openjdk19
      #pkgs.lyx
      #pkgs.heroic
      pkgs.vlc
      #pkgs.godot_4
      #pkgs.pympress
      pkgs.filelight
      pkgs.yarn
      pkgs.nodejs_latest
      #pkgs.sccache
      pkgs.iotop
      pkgs.htop
      pkgs.duperemove
      pkgs.compsize
      pkgs.androidStudioPackages.canary
      pkgs.rpi-imager
      pkgs.gh
      pkgs.anki-bin
      pkgs.xorg.xeyes
      #pkgs.kalendar
      #pkgs.libsForQt5.kdepim-addons
      pkgs.fd
    ];

    home.persistence."/nix/persistent/home/moritz" = {
      allowOther = true;
      directories = [
        "Android"
        "AndroidStudioProjects"
        "Downloads"
        "Music"
        "Pictures"
        "Documents"
        "Videos"
        ".mozilla"
        ".config/libreoffice"
        ".local/share/kscreen" # start on external screen by default
        ".local/share/konsole" # profile with infinite scrollback
        ".ssh"
        ".local/share/Trash"
        ".local/share/Anki2"
        # found using
        # systemctl --user stop pipewire.service
        # systemctl --user stop pipewire-pulse.service
        ".local/state/wireplumber" # restore audio volumes
        ".local/state/home-manager"
        ".local/share/docker"
        ".config/discord" # "config"
        ".mozilla"
        ".config/VSCodium" # "config"
        ".config/Code"
        ".vscode"
        ".vscode-oss"
        ".steam"
        ".local/share/Steam"
        ".thunderbird"
        ".config/chromium/"
        ".config/easyeffects"
        ".cargo"
        #".rustup"
        ".local/share/tor-browser"
        ".config/Signal"
        ".local/share/flatpak/"
        ".config/heroic/"
        ".config/legendary"
        ".local/share/godot"
        ".config/godot"
        "Games"
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
    };
  };

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking = {
    useDHCP = false;
  };
  systemd.network.enable = true;
  systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;
  systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;
  systemd.network = {
    networks = {
      "20-enp" = {
        matchConfig.Name = "enp*";
        networkConfig.DHCP = "yes";
        dhcpV4Config = {
          RouteMetric = 10;
        };
        ipv6AcceptRAConfig = {
          RouteMetric = 10;
        };
      };
      "25-wlp" = {
        matchConfig.Name = "wlp*";
        networkConfig = {
          DHCP = "yes";
          DNS = "1.1.1.1";
        };
        dhcpV4Config = {
          RouteMetric = 20;
        };
        ipv6AcceptRAConfig = {
          RouteMetric = 20;
        };
      };
      "25-bnep" = {
        matchConfig.Name = "bnep*";
        networkConfig.DHCP = "yes";
        dhcpV4Config = {
          RouteMetric = 20;
        };
        ipv6AcceptRAConfig = {
          RouteMetric = 20;
        };
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
    extraGroups = [ "wheel" "docker" ];
    initialHashedPassword = "$6$sUGOG4y2bxFFFsKS$EwMnQ0.qI/BsLCuMZ17bWreafcHfFLr/LDdjHpVBIoLHCu93nZKJAiedmXYyn3vU6f9watzoOgmuBKJMn4U/f/";
  };

  users.mutableUsers = false;

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.logRefusedConnections = false;
  networking.firewall.allowedTCPPorts = [ 2375 ];
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
  # networking.firewall.enable = false;

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  virtualisation.libvirtd.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}
