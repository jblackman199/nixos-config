# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

{
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    (import <nix-snapd>).nixosModules.default # Install nix-snapd using the flake at /home/jblackman199/flake.nix
  ];

  boot.loader = { # Enable bootloader as Grub
  efi = {
    canTouchEfiVariables = true;
  };
  grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
    useOSProber = true;
    };
  };

  boot.kernelPackages = pkgs.linuxPackages_latest; # Install the latest kernel

  boot.binfmt.registrations.appimage = { # Make AppImages work
    wrapInterpreterInShell = false;
    interpreter = "${pkgs.appimage-run}/bin/appimage-run";
    recognitionType = "magic";
    offset = 0;
    mask = ''\xff\xff\xff\xff\x00\x00\x00\x00\xff\xff\xff'';
    magicOrExtension = ''\x7fELF....AI\x02'';
  };

  swapDevices = [ {
    device = "/var/lib/swapfile";
    size = 8192;
  } ];

  # Hardware stuff

  hardware.opengl = { # Enable OpenGL
    enable = true;
  };

  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot

  hardware.pulseaudio.enable = false; # Enable sound with pipewire.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
    };

  hardware.nvidia = {

    modesetting.enable = true;  # Modesetting is required

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
    # of just the bare essentials.
    powerManagement.enable = true;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of
    # supported GPUs is at:
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
    # Only available from driver 515.43.04+
    # Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = false;

    # Enable the Nvidia settings menu,
	# accessible via `nvidia-settings`
    nvidiaSettings = false;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  time.hardwareClockInLocalTime = true; # Make the time not suck in Windows

  networking.hostName = "jaydens-nix"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  networking.networkmanager.enable = true;  # Enable networking

  time.timeZone = "America/Boise";  # Set your time zone

  i18n.defaultLocale = "en_US.UTF-8"; # Select internationalisation properties

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;

  users.users.jblackman199 = {  # Define a user account. Don't forget to set a password with ‘passwd’
    isNormalUser = true;
    description = "Jayden Blackman";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  nix.extraOptions =  # Enable nix experimental features
  "experimental-features = nix-command flakes";

  nixpkgs.config.allowUnfree = true;  # Allow unfree packages

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

  system.autoUpgrade.enable = true; # Automatically upgrade
  system.autoUpgrade.allowReboot = true;

  nix.gc = { # Collect garbage weekly
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  nix.optimise.automatic = true; # Automatically optimize /nix/store weekly
  nix.optimise.dates = [ "weekly" ];

  # List services that you want to enable:

  services.xserver.videoDrivers = ["nvidia"]; # Load nvidia driver for Xorg and Wayland

  services.snap.enable = true;  # Enable snap
  services.flatpak.enable = true; # Enable flatpak

  programs.steam = {  # Install and enable Steam to run
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ # Let nonfree Steam dependencies work
    "steam"
    "steam-original"
    "steam-run"
  ];

  services.xserver.enable = false;  # Enable the X11 windowing system. You can disable this if you're only using the Wayland session.

  services.displayManager.sddm.enable = true; # Enable SDDM
  services.desktopManager.plasma6.enable = true;  # Enable Plasma 6
  services.displayManager.defaultSession = "plasma"; # Set default session plasme = wayland, plasmax11 = x11
  services.displayManager.sddm.wayland.enable = true; # Enable Plasma Wayland session
  services.displayManager.sddm.autoNumlock = true;  # Enable numlock on SDDM
  environment.plasma6.excludePackages = with pkgs.kdePackages; [  # Exclude listed packages
    oxygen
    elisa
    khelpcenter
  ];

  environment.sessionVariables.NIXOS_OZONE_WL = "1"; # for electron wayland

  services.xserver = {  # Configure keymap in X11
    xkb.layout = "us";
    xkb.variant = "";
  };

  services.printing.enable = true;  # Enable CUPS to print documents

  services.power-profiles-daemon.enable = false; # Disable power profiles daemon
  services.tlp.enable = true; # Enable tlp

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  environment.systemPackages = with pkgs; [ # List packages installed in system profile. To search, run: nix search wget
    birdtray
    discord
    fastfetch
    fish
    fwupd
    git
    hunspell
    hunspellDicts.en_US
    hyphen
    jre8
    jupyter
    kdePackages.discover
    kdePackages.kate
    kdePackages.kdeconnect-kde
    kdePackages.partitionmanager
    kdePackages.plasma-browser-integration
    kdePackages.print-manager
    kdePackages.wrapQtAppsHook
    libreoffice-qt6-fresh
    mythes
    neovim
    ollama
    onedrive
    onedrivegui
    python312Packages.scipy
    python312Packages.sympy
    qalculate-gtk
    qbittorrent
    rnote
    rssguard
    sage
    signal-desktop
    superTuxKart
    thunderbird
    tlp
    ventoy-full
    vlc
    xdg-desktop-portal-gtk
    xournalpp
    xwaylandvideobridge
  ];

  fonts.packages = with pkgs; [ # List fonts installed
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    liberation_ttf
    libertine
  ];

  networking.firewall = { # Open ports for KDE Connect
    enable = true;
    allowedTCPPortRanges = [
      { from = 1714; to = 1764; }
    ];
    allowedUDPPortRanges = [
      { from = 1714; to = 1764; }
    ];
  };

  programs.fish.enable = true;  # Enable Fish
  users.defaultUserShell = pkgs.fish; # Make fish the default shell

  programs.dconf.enable = true; # Fix GTK themes

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
}
