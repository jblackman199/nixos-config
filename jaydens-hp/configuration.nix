# Edit this configuration file to define what should be installed on your system. Help is available
# in the configuration.nix(5) man page and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

{
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    (import <nix-snapd>).nixosModules.default # Install nix-snapd using the flake at /home/jblackman199/flake.nix
  ];

  boot = { # Enable bootloader as Grub
    initrd.verbose = false;
    consoleLogLevel = 0;
    kernelParams = ["quiet" "udev.log_level=3"];
    loader.efi = {
      canTouchEfiVariables = true;
    };
    loader.grub = {
      enable = true;
      efiSupport = true;
      device = "nodev";
      useOSProber = true;
      theme = pkgs.stdenv.mkDerivation {
        pname = "distro-grub-themes";
        version = "3.1";
        src = pkgs.fetchFromGitHub {
          owner = "AdisonCavani";
          repo = "distro-grub-themes";
          rev = "v3.1";
          hash = "sha256-ZcoGbbOMDDwjLhsvs77C7G7vINQnprdfI37a9ccrmPs=";
        };
        installPhase = "cp -r customize/nixos $out";
      };
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

  # Hardware stuff

  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot

  hardware.pulseaudio.enable = false; # Enable sound with pipewire.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    #jack.enable = true;  If you want to use JACK applications, uncomment this
  };

  hardware.graphics.enable = true; # Enable OpenGL

  networking.hostName = "jaydens-nix"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # networking.proxy.default = "http://user:password@proxy:port/";  # Configure network proxy if necessary
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

  # media-session.enable = true;  # use the example session manager

  users.users.jblackman199 = {  # Define a user account. Don't forget to set a password with ‘passwd’
    isNormalUser = true;
    description = "Jayden Blackman";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  nix.extraOptions =  # Enable nix experimental features
  "experimental-features = nix-command flakes";

  # This value determines the NixOS release from which the default settings for stateful data,
  # like file locations and database versions on your system were taken. It‘s perfectly fine
  # and recommended to leave this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

  system.autoUpgrade = {
    enable = true; # Automatically upgrade
    randomizedDelaySec = "30sec"; # Raise upgrade attempts
  };

  nix.gc = { # Collect garbage weekly
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  nix.optimise.automatic = true; # Automatically optimize /nix/store weekly
  nix.optimise.dates = [ "weekly" ];

  # List services that you want to enable:

  services.snap.enable = true;  # Enable snap
  services.flatpak.enable = true; # Enable flatpak

  services.xserver.enable = false;  # Enable the X11 windowing system. You can disable this if you're only using the Wayland session.

  services.displayManager.sddm.enable = true; # Enable SDDM
  services.desktopManager.plasma6.enable = true;  # Enable Plasma 6
  services.displayManager.defaultSession = "plasma"; # Set default session plasme = wayland, plasmax11 = x11
  services.displayManager.sddm.wayland.enable = true; # Set SDDM to Wayland
  services.displayManager.sddm.autoNumlock = true;  # Enable numlock on SDDM
  environment.plasma6.excludePackages = with pkgs.kdePackages; [  # Exclude listed packages
    breeze-grub
    elisa
    khelpcenter
    krdp
    oxygen
  ];

  environment.sessionVariables.NIXOS_OZONE_WL = "1"; # for electron wayland

  services.xserver = {  # Configure keymap in X11
    xkb.layout = "us";
    xkb.variant = "";
  };

  services.printing.enable = true;  # Enable CUPS to print documents

  services.printing.drivers = with pkgs; [ # List printer drivers to install
    cnijfilter2
  ];

  services.power-profiles-daemon.enable = false; # Disable power profiles daemon
  services.tlp.enable = true; # Enable tlp

  services.tailscale.enable = true; # Install and enable tailscale

  # services.openssh.enable = true; # Enable the OpenSSH daemon.

  # services.xserver.libinput.enable = true;  # Enable touchpad support (enabled default in most desktopManager).

  nixpkgs.config.allowUnfree = true;  # Allow unfree packages

  environment.systemPackages = with pkgs; [ # List packages installed in system profile. To search, run: nix search wget
    bottom
    cpufetch
    discord
    fastfetch
    fish
    fwupd
    hunspell
    hunspellDicts.en_US
    hyphen
    jupyter
    kdePackages.discover
    kdePackages.dolphin-plugins
    kdePackages.ffmpegthumbs
    kdePackages.isoimagewriter
    kdePackages.kasts
    kdePackages.kate
    kdePackages.kdeconnect-kde
    kdePackages.kdegraphics-thumbnailers
    kdePackages.kde-gtk-config
    kdePackages.kimageformats
    kdePackages.partitionmanager
    kdePackages.plasma-browser-integration
    kdePackages.print-manager
    kdePackages.qtimageformats
    kdePackages.sddm-kcm
    kdePackages.sonnet
    kdePackages.svgpart
    libreoffice-qt6-fresh
    lshw
    mythes
    qalculate-gtk
    qbittorrent
    ramfetch
    rclone
    rnote
    sage
    signal-desktop
    thunderbird
    tlp
    vlc
    xdg-desktop-portal-gtk
    xournalpp
    xwaylandvideobridge
  ];

  fonts.packages = with pkgs; [ # List fonts installed
    liberation_ttf
    libertine
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    noto-fonts-lgc-plus
    noto-fonts-monochrome-emoji
    unicode-emoji
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

  # programs.mtr.enable = true; # Some programs need SUID wrappers, can be configured further or are started in user sessions.
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
}
