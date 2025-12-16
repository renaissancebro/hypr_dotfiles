# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.

  networking.wireless.enable = false;  # Enables wireless support via wpa_supplicant.


  networking.networkmanager = {
    enable = true;  
    wifi.backend = "wpa_supplicant";
   };



  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  # networking.networkmanager.enable = true;
  #services.networkmanager.enable = true;
  #services.networkmanager.wpa_supplicant.enable = true;
  # Set your time zone.
  time.timeZone = "America/Chicago";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

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

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
    
  # Enable Hyprland Desktop env

  environment.pathsToLink = [ "/share/wayland-sessions" ];

#  services.desktopManager.defaultSession = "Hyprland";
  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
    options = "ctrl:nocaps";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  services.gnome.gnome-keyring.enable = true;

  security.pam.services = { 
	  login.enableGnomeKeyring = true;
  	  sudo.enableGnomeKeyring = true;
	};

  # Enable sound with pipewire.
    
  hardware.enableAllFirmware = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    # media-session.enable = true;
  };

   
  # Make sure power management is generally on
  powerManagement.enable = true;

  # Use the modern AMD CPU driver
  boot.kernelParams = [
    "amd_pstate=active"  # or "guided" if you want the kernel to balance perf vs power
  ];
# Use AMD GPU backlight instead of ACPI fallback
# Ensure AMDGPU driver is loaded
  boot.kernelModules = [ "amdgpu" ];

  # Optional: explicitly pick a governor; with amd_pstate this usually becomes "powersave" / "performance"
  powerManagement.cpuFreqGovernor = "powersave"; 

 # Disable power-profiles-daemon (conflicts with auto-cpufreq)
  services.power-profiles-daemon.enable = false;

  # Auto-cpufreq for better AMD battery management
  services.auto-cpufreq = {
    enable = true;
    settings = {
      battery = {
        governor = "powersave";
        turbo = "never";
      };
      charger = {
        governor = "performance";
        turbo = "auto";
      };
    };
  };

 # For Bluetooth sound (headphones, airpods)
 hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  services.blueman.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput = {
	enable = true;


	mouse = {
	  naturalScrolling = true;
	};
	touchpad = {
	  naturalScrolling = true;
	};
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.joshuaf = {
    isNormalUser = true;
    description = "Joshua Freeman";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      kdePackages.kate
    #  thunderbird
    ];
  };

  # Install firefox.
  programs.firefox.enable = true; 

  # Install hyprland
  programs.hyprland.enable = true;
	

  hardware.graphics = {
	enable = true;
	enable32Bit = true;
};
  
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;  # optional
    dedicatedServer.openFirewall = false; # optional
  };

   hardware.amdgpu.opencl.enable = true;  # OpenCL for AMD




  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget

  # sysPac
  environment.systemPackages = with pkgs; [

    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  	wget
	neovim
    ripgrep
    fd
    tree-sitter
    lua-language-server
	git
	curl
	firefox
	# google-chrome
	libreoffice-fresh
	libsForQt5.okular
	alacritty	
	kitty 
	blueman
	bluez
	wl-clipboard
    fastfetch
    iwd
    cliphist
    # hyprland internet helpers
    
    # Ai stuff
    openai
    python3
    claude-code
    
    # Nvim
    gcc
    nodejs
    nodePackages.npm
    gnome-keyring
    libsecret
    
    # LSP servers
    pyright
    typescript-language-server
    vscode-langservers-extracted  # html, css, json
    lua-language-server
    bash-language-server
    python311Packages.python-lsp-server

	# Steam stuff
	gamemode

	# Audio
    alsa-utils
    alsa-plugins
    cava

	# VS Code
	vscode
    
    # Wayland stuff
    neofetch
    htop
    waybar
    wofi
    networkmanagerapplet
    networkmanager
    # hyprpaper
    swww 
    brightnessctl
    light #fallback
    gammastep


	# Python + Jupyter (via Nix)
	(python311.withPackages (ps: with ps; [
	  ipython
	  jupyterlab
	  numpy
	  pandas

	]))
	
	
  ];
 	
  nix.settings.experimental-features = ["nix-command" "flakes" ];



  location = {
    latitude = 38.627003;   # Replace with your latitude
    longitude = -90.199402;# Replace with your longitude
    };
  services.redshift = {
    enable = true;
    package = pkgs.gammastep;
    brightness = {
      day = "0.6";
      night = "0.6";
    };
    temperature = {
      day = 4000;
      night = 3000;
    };
  };
  # Remap keys	
  # services.xserver = {
  # layout = "us";
	#  xkb.options = "ctrl:nocaps";
	#};



 # services.pipewire.enable = true; 	

  environment.shellAliases = {
      nixc = "sudo vim /etc/nixos/configuration.nix";
      nr = "sudo nixos-rebuild switch";
    };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;
    
  services.ollama = {
    enable = true;
};

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

}
