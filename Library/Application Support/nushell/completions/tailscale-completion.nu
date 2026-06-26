# nu-version: 0.106.0
#
# Nushell completions for Tailscale CLI.
#
# Design notes:
# - This file does not call `tailscale completion __complete`.
# - It uses Nu `export extern` definitions plus small Nu completers.
# - Import with:
#     use /path/to/tailscale-completions.nu *

def "nu-complete tailscale commands" [] {
  [
    { value: up description: "Connect to Tailscale and authenticate if needed" }
    { value: down description: "Disconnect from Tailscale" }
    { value: bugreport description: "Generate a bug report identifier" }
    { value: cert description: "Generate HTTPS certificate and key files" }
    { value: completion description: "Generate shell completions supported by Tailscale" }
    { value: configure description: "Configure resources included in your tailnet" }
    { value: dns description: "DNS diagnostic commands" }
    { value: drive description: "Manage Taildrive shares" }
    { value: exit-node description: "List or suggest exit nodes" }
    { value: file description: "Send and receive files using Taildrop" }
    { value: funnel description: "Expose local services to the internet through Tailscale Funnel" }
    { value: ip description: "Print a device's Tailscale IP address" }
    { value: licenses description: "Print open source license information" }
    { value: lock description: "Manage Tailnet Lock" }
    { value: login description: "Log in to Tailscale" }
    { value: logout description: "Log out and expire the current node login" }
    { value: metrics description: "Expose or write client metrics" }
    { value: netcheck description: "Report current network conditions" }
    { value: ping description: "Ping a device over Tailscale" }
    { value: serve description: "Serve local content or services to your tailnet" }
    { value: set description: "Change selected Tailscale preferences" }
    { value: ssh description: "Start a Tailscale SSH session" }
    { value: status description: "Show connection status" }
    { value: switch description: "Switch local Tailscale account" }
    { value: syspolicy description: "List or reload system policy settings" }
    { value: systray description: "Run the Linux system tray client" }
    { value: update description: "Update or downgrade the Tailscale client" }
    { value: version description: "Print version information" }
    { value: wait description: "Wait until Tailscale is ready" }
    { value: web description: "Open the local Tailscale web UI" }
  ]
}

def "nu-complete tailscale bool" [] {
  [ true false ]
}

def "nu-complete tailscale shell" [] {
  [
    { value: bash description: "Bash completion script" }
    { value: zsh description: "Zsh completion script" }
    { value: fish description: "Fish completion script" }
    { value: powershell description: "PowerShell completion script" }
  ]
}

def "nu-complete tailscale risk" [] {
  [
    { value: lose-ssh description: "Accept risk of losing SSH access" }
    { value: all description: "Accept all risk prompts" }
  ]
}

def "nu-complete tailscale netfilter-mode" [] {
  [ on nodivert off ]
}

def "nu-complete tailscale file-conflict" [] {
  [
    { value: skip description: "Skip conflicting files" }
    { value: overwrite description: "Overwrite existing files" }
    { value: rename description: "Write to a numbered filename" }
  ]
}

def "nu-complete tailscale serve-subcommands" [] {
  [
    { value: status description: "Show Serve status" }
    { value: reset description: "Reset Serve configuration" }
    { value: get-config description: "Write current service configuration to a file" }
    { value: set-config description: "Apply service configuration from a file" }
    { value: drain description: "Drain a Service from this node" }
    { value: advertise description: "Advertise this node as a Service host" }
  ]
}

def "nu-complete tailscale funnel-subcommands" [] {
  [
    { value: status description: "Show Funnel status" }
    { value: reset description: "Reset Funnel configuration" }
  ]
}

def "nu-complete tailscale lock-subcommands" [] {
  [
    { value: init description: "Initialize Tailnet Lock" }
    { value: status description: "Show Tailnet Lock status" }
    { value: add description: "Add trusted signing keys" }
    { value: remove description: "Remove trusted signing keys" }
    { value: sign description: "Sign a node key or auth key" }
    { value: disable description: "Disable Tailnet Lock for the tailnet" }
    { value: disablement-kdf description: "Compute a disablement value" }
    { value: log description: "List Tailnet Lock changes" }
    { value: local-disable description: "Disable Tailnet Lock locally" }
    { value: revoke-keys description: "Revoke Tailnet Lock keys" }
  ]
}

def "nu-complete tailscale configure-subcommands" [] {
  [
    { value: kubeconfig description: "Configure kubectl through a Tailscale auth proxy" }
    { value: mac-vpn description: "Install or uninstall macOS VPN configuration" }
    { value: synology description: "Configure Synology outbound connectivity" }
    { value: sysext description: "Manage the macOS Tailscale system extension" }
    { value: systray description: "Manage the Linux systray client" }
  ]
}

def "nu-complete tailscale configure-mac-vpn-subcommands" [] {
  [
    { value: install description: "Install the macOS VPN configuration" }
    { value: uninstall description: "Uninstall the macOS VPN configuration" }
  ]
}

def "nu-complete tailscale configure-sysext-subcommands" [] {
  [
    { value: activate description: "Register the macOS system extension" }
    { value: deactivate description: "Deactivate the macOS system extension" }
    { value: status description: "Print system extension enablement status" }
  ]
}

def "nu-complete tailscale exit-node-subcommands" [] {
  [
    { value: list description: "List exit nodes" }
    { value: suggest description: "Suggest a recommended exit node" }
  ]
}

def "nu-complete tailscale file-subcommands" [] {
  [
    { value: cp description: "Copy files to a host" }
    { value: get description: "Move files out of the Taildrop inbox" }
  ]
}

def "nu-complete tailscale drive-subcommands" [] {
  [
    { value: share description: "Create or modify a share" }
    { value: rename description: "Rename a share" }
    { value: unshare description: "Remove a share" }
    { value: list description: "List current shares" }
  ]
}

def "nu-complete tailscale metrics-subcommands" [] {
  [
    { value: print description: "Show client metrics" }
    { value: write description: "Write metrics to a file" }
  ]
}

def "nu-complete tailscale syspolicy-subcommands" [] {
  [
    { value: list description: "List system policies or policy errors" }
    { value: reload description: "Reload system policies" }
  ]
}

def "nu-complete tailscale switch-subcommands" [] {
  [
    { value: remove description: "Remove a local Tailscale account" }
  ]
}

def "nu-complete tailscale theme" [] {
  [ dark dark:nobg light light:nobg ]
}

def "nu-complete tailscale update-track" [] {
  [ stable unstable release-candidate ]
}

def "nu-complete tailscale output-format" [] {
  [ text json ]
}

def "nu-complete tailscale peers" [] {
  let status = try { ^tailscale status --json | from json } catch { null }

  if ($status == null) {
    return []
  }

  mut completions = []

  let self = try { $status | get Self } catch { null }
  if ($self != null) {
    let host = try { $self | get HostName } catch { "" }
    let dns = try { $self | get DNSName | str replace --regex '\.$' '' } catch { "" }
    let ips = try { $self | get TailscaleIPs } catch { [] }

    if ($host | is-not-empty) {
      $completions = $completions | append { value: $host description: "Self hostname" style: light_blue }
    }
    if ($dns | is-not-empty) {
      $completions = $completions | append { value: $dns description: "Self MagicDNS name" style: light_blue }
    }
    for ip in $ips {
      $completions = $completions | append { value: $ip description: $"Self address for ($host)" style: light_cyan }
    }
  }

  let peers = try { $status | get Peer | transpose id peer } catch { [] }

  for row in $peers {
    let peer = $row.peer
    let host = try { $peer | get HostName } catch { "" }
    let dns = try { $peer | get DNSName | str replace --regex '\.$' '' } catch { "" }
    let ips = try { $peer | get TailscaleIPs } catch { [] }
    let os = try { $peer | get OS } catch { "unknown" }
    let online = try { $peer | get Online } catch { false }
    let state = if $online { "online" } else { "offline" }

    if ($host | is-not-empty) {
      $completions = $completions | append { value: $host description: $"Peer, ($os), ($state)" style: green }
    }
    if ($dns | is-not-empty) {
      $completions = $completions | append { value: $dns description: $"MagicDNS, ($os), ($state)" style: green }
    }
    for ip in $ips {
      $completions = $completions | append { value: $ip description: $"Address for ($host), ($state)" style: light_cyan }
    }
  }

  {
    options: {
      case_sensitive: false
      completion_algorithm: prefix
      sort: false
    }
    completions: ($completions | uniq-by value)
  }
}

# Tailscale CLI root.
export extern "tailscale" [
  command?: string@"nu-complete tailscale commands" # Command
  --socket: path                                    # Path to tailscaled socket
  --help(-h)                                       # Show help
  --version                                        # Print version
  ...args
]

# Connect your device to Tailscale and authenticate if needed.
export extern "tailscale up" [
  --accept-dns             # Accept DNS configuration from the admin console
  --accept-risk: string@"nu-complete tailscale risk"          # Accept risk and skip confirmation
  --accept-routes          # Accept subnet routes advertised by other nodes
  --advertise-connector                                      # Offer to be an app connector
  --advertise-exit-node    # Offer to be an exit node
  --advertise-routes: string                                 # Comma-separated subnet routes to advertise
  --advertise-tags: string                                   # Tags to apply to this device
  --auth-key: string                                         # Auth key used to authenticate
  --client-id: string                                        # OAuth client ID for auth-key generation
  --client-secret: string                                    # OAuth client secret or file: path
  --exit-node: string@"nu-complete tailscale peers"           # Exit node IP or name
  --exit-node-allow-lan-access # Allow LAN access while using an exit node
  --force-reauth                                             # Force re-authentication
  --hostname: string                                         # Hostname to use for this device
  --json                                                     # Output machine-readable JSON where supported
  --login-server: string                                     # Coordination server URL
  --netfilter-mode: string@"nu-complete tailscale netfilter-mode" # Netfilter mode
  --operator: string                                         # Unix username allowed to operate tailscaled
  --qr                                                       # Show QR code for login URL where supported
  --reset                                                    # Reset unspecified settings to defaults
  --shields-up             # Block incoming connections from tailnet devices
  --snat-subnet-routes     # Source NAT traffic to advertised routes
  --ssh                    # Run a Tailscale SSH server
  --stateful-filtering     # Apply stateful filtering
  --timeout: string                                          # Maximum time to wait
  --unattended                                               # Windows: keep running after current user logs out
  --webclient              # Expose local web client to tailnet
  --socket: path                                             # Path to tailscaled socket
  --help(-h)                                                 # Show help
]

# Disconnect from Tailscale.
export extern "tailscale down" [
  --accept-risk: string@"nu-complete tailscale risk" # Accept risk and skip confirmation
  --reason: string                                  # Reason for disconnecting
  --socket: path                                    # Path to tailscaled socket
  --help(-h)                                       # Show help
]

# Generate a bug report identifier.
export extern "tailscale bugreport" [
  --diagnose     # Print extra diagnostic information to logs
  --record       # Record a reproduction window
  --socket: path # Path to tailscaled socket
  --help(-h)     # Show help
]

# Generate certificate and key files.
export extern "tailscale cert" [
  hostname?: string@"nu-complete tailscale peers" # Hostname to issue a certificate for
  --cert-file: path                               # Certificate output path
  --key-file: path                                # Private key output path
  --min-validity: string                          # Minimum remaining validity duration
  --serve-demo                                    # Serve demo on :443
  --socket: path                                  # Path to tailscaled socket
  --help(-h)                                     # Show help
]

# Generate completions for shells supported by Tailscale.
export extern "tailscale completion" [
  shell?: string@"nu-complete tailscale shell" # Shell
  --flags: string@"nu-complete tailscale bool"   # Include flags in suggestions
  --descs: string@"nu-complete tailscale bool"   # Include descriptions
  --socket: path                               # Path to tailscaled socket
  --help(-h)                                  # Show help
]

export extern "tailscale completion bash" [
  --flags: string@"nu-complete tailscale bool"
  --descs: string@"nu-complete tailscale bool"
  --help(-h)
]

export extern "tailscale completion zsh" [
  --flags: string@"nu-complete tailscale bool"
  --descs: string@"nu-complete tailscale bool"
  --help(-h)
]

export extern "tailscale completion fish" [
  --flags: string@"nu-complete tailscale bool"
  --descs: string@"nu-complete tailscale bool"
  --help(-h)
]

export extern "tailscale completion powershell" [
  --flags: string@"nu-complete tailscale bool"
  --descs: string@"nu-complete tailscale bool"
  --help(-h)
]

# DNS diagnostic commands.
export extern "tailscale dns" [
  command?: string # Subcommand
  --json           # Output JSON
  --socket: path   # Path to tailscaled socket
  --help(-h)       # Show help
  ...args
]

export extern "tailscale dns status" [
  --json         # Output JSON
  --socket: path # Path to tailscaled socket
  --help(-h)     # Show help
]

export extern "tailscale dns query" [
  name: string   # DNS name to query
  --json         # Output JSON
  --socket: path # Path to tailscaled socket
  --help(-h)     # Show help
]

# Configure resources included in your tailnet.
export extern "tailscale configure" [
  command?: string@"nu-complete tailscale configure-subcommands" # Subcommand
  --socket: path                                                 # Path to tailscaled socket
  --help(-h)                                                    # Show help
  ...args
]

export extern "tailscale configure kubeconfig" [
  hostname: string@"nu-complete tailscale peers" # Hostname or FQDN
  --http                                        # Use HTTP instead of HTTPS
  --socket: path                                # Path to tailscaled socket
  --help(-h)                                   # Show help
]

export extern "tailscale configure mac-vpn" [
  command?: string@"nu-complete tailscale configure-mac-vpn-subcommands"
  --socket: path
  --help(-h)
  ...args
]

export extern "tailscale configure mac-vpn install" [
  --socket: path
  --help(-h)
]

export extern "tailscale configure mac-vpn uninstall" [
  --socket: path
  --help(-h)
]

export extern "tailscale configure synology" [
  --socket: path
  --help(-h)
]

export extern "tailscale configure sysext" [
  command?: string@"nu-complete tailscale configure-sysext-subcommands"
  --socket: path
  --help(-h)
  ...args
]

export extern "tailscale configure sysext activate" [
  --socket: path
  --help(-h)
]

export extern "tailscale configure sysext deactivate" [
  --socket: path
  --help(-h)
]

export extern "tailscale configure sysext status" [
  --socket: path
  --help(-h)
]

export extern "tailscale configure systray" [
  --enable-startup: string # Supported value: systemd
  --socket: path
  --help(-h)
]

# Taildrive.
export extern "tailscale drive" [
  command?: string@"nu-complete tailscale drive-subcommands" # Subcommand
  --socket: path                                             # Path to tailscaled socket
  --help(-h)                                                # Show help
  ...args
]

export extern "tailscale drive share" [
  name: string # Share name
  path: path   # Directory path
  --socket: path
  --help(-h)
]

export extern "tailscale drive rename" [
  oldname: string # Existing share name
  newname: string # New share name
  --socket: path
  --help(-h)
]

export extern "tailscale drive unshare" [
  name: string # Share name
  --socket: path
  --help(-h)
]

export extern "tailscale drive list" [
  --socket: path
  --help(-h)
]

# Exit nodes.
export extern "tailscale exit-node" [
  command?: string@"nu-complete tailscale exit-node-subcommands" # Subcommand
  --socket: path                                                 # Path to tailscaled socket
  --help(-h)                                                    # Show help
  ...args
]

export extern "tailscale exit-node list" [
  --filter: string # Filter by country
  --json           # Output JSON
  --socket: path
  --help(-h)
]

export extern "tailscale exit-node suggest" [
  --json
  --socket: path
  --help(-h)
]

# Taildrop.
export extern "tailscale file" [
  command?: string@"nu-complete tailscale file-subcommands" # Subcommand
  --socket: path                                            # Path to tailscaled socket
  --help(-h)                                               # Show help
  ...args
]

export extern "tailscale file cp" [
  ...paths: path # Files followed by target host:
  --name: string # Alternate filename
  --targets      # List possible file cp targets
  --update-interval: string # Progress repaint interval
  --verbose(-v)  # Verbose output
  --socket: path
  --help(-h)
]

export extern "tailscale file get" [
  target_directory?: path # Target directory
  --conflict: string@"nu-complete tailscale file-conflict" # Conflict behavior
  --loop          # Keep receiving files
  --verbose(-v)   # Verbose output
  --wait          # Wait if inbox is empty
  --socket: path
  --help(-h)
]

# Funnel.
export extern "tailscale funnel" [
  target_or_command?: string@"nu-complete tailscale funnel-subcommands" # Target or subcommand
  off?: string                                                          # Use `off` to disable a matching funnel
  --bg                                                                  # Run in background
  --https: int                                                          # HTTPS listen port
  --http: int                                                           # HTTP listen port
  --tcp: int                                                            # TCP listen port
  --set-path: string                                                    # URL path mount point
  --tls-terminated-tcp: int                                             # TCP with TLS terminated
  --yes                                                                 # Confirm changes
  --socket: path                                                        # Path to tailscaled socket
  --help(-h)                                                           # Show help
  ...args
]

export extern "tailscale funnel status" [
  --json
  --socket: path
  --help(-h)
]

export extern "tailscale funnel reset" [
  --yes
  --socket: path
  --help(-h)
]

# IP addresses.
export extern "tailscale ip" [
  hostname?: string@"nu-complete tailscale peers" # Hostname
  -4                                             # Only return IPv4
  -6                                             # Only return IPv6
  -1                                             # Only return one address, preferring IPv4
  --assert: string                               # Assert node IP
  --socket: path                                 # Path to tailscaled socket
  --help(-h)                                    # Show help
]

export extern "tailscale licenses" [
  --socket: path
  --help(-h)
]

# Tailnet Lock.
export extern "tailscale lock" [
  command?: string@"nu-complete tailscale lock-subcommands" # Subcommand
  --socket: path                                            # Path to tailscaled socket
  --help(-h)                                               # Show help
  ...args
]

export extern "tailscale lock init" [
  ...trusted_keys: string # tlpub: trusted keys
  --confirm              # Do not prompt for confirmation
  --gen-disablement-for-support # Generate a support disablement secret
  --gen-disablements: int       # Number of disablement secrets to generate
  --socket: path
  --help(-h)
]

export extern "tailscale lock status" [
  --json
  --socket: path
  --help(-h)
]

export extern "tailscale lock add" [
  ...trusted_keys: string # tlpub: trusted keys
  --socket: path
  --help(-h)
]

export extern "tailscale lock remove" [
  ...trusted_keys: string # tlpub: trusted keys
  --re-sign # Re-sign invalidated signatures
  --socket: path
  --help(-h)
]

export extern "tailscale lock sign" [
  ...keys: string # nodekey:, auth key, or tlpub:
  --socket: path
  --help(-h)
]

export extern "tailscale lock disable" [
  disablement_secret: string # disablement-secret:
  --socket: path
  --help(-h)
]

export extern "tailscale lock disablement-kdf" [
  hex_encoded_disablement_secret: string
  --socket: path
  --help(-h)
]

export extern "tailscale lock log" [
  --json
  --limit: int
  --socket: path
  --help(-h)
]

export extern "tailscale lock local-disable" [
  --socket: path
  --help(-h)
]

export extern "tailscale lock revoke-keys" [
  ...keys: string # tlpub: keys
  --cosign
  --finish
  --fork-from: string
  --socket: path
  --help(-h)
]

# Login/logout.
export extern "tailscale login" [
  --accept-dns
  --accept-routes
  --advertise-connector
  --advertise-exit-node
  --advertise-routes: string
  --advertise-tags: string
  --auth-key: string
  --client-id: string
  --client-secret: string
  --exit-node: string@"nu-complete tailscale peers"
  --exit-node-allow-lan-access
  --force-reauth
  --hostname: string
  --login-server: string
  --qr
  --shields-up
  --snat-subnet-routes
  --ssh
  --timeout: string
  --unattended
  --socket: path
  --help(-h)
]

export extern "tailscale logout" [
  --reason: string
  --socket: path
  --help(-h)
]

# Metrics.
export extern "tailscale metrics" [
  command?: string@"nu-complete tailscale metrics-subcommands"
  --socket: path
  --help(-h)
  ...args
]

export extern "tailscale metrics print" [
  --socket: path
  --help(-h)
]

export extern "tailscale metrics write" [
  path?: path
  --socket: path
  --help(-h)
]

# Network diagnostics.
export extern "tailscale netcheck" [
  --verbose(-v)
  --json
  --socket: path
  --help(-h)
]

export extern "tailscale ping" [
  hostname_or_ip: string@"nu-complete tailscale peers" # Hostname or IP
  --c: int                                             # Maximum number of pings
  --icmp             # ICMP-level ping
  --peerapi          # Try PeerAPI
  --size: int                                          # Ping message size
  --timeout: string                                    # Timeout duration
  --tsmp             # TSMP-level ping
  --until-direct     # Stop once direct path is established
  --verbose          # Verbose output
  --socket: path
  --help(-h)
]

# Serve.
export extern "tailscale serve" [
  target_or_command?: string@"nu-complete tailscale serve-subcommands" # Target or subcommand
  off?: string                                                         # Use `off` to disable a matching serve
  --bg                                                                 # Run in background
  --https: int                                                         # HTTPS listen port
  --http: int                                                          # HTTP listen port
  --tcp: int                                                           # TCP listen port
  --set-path: string                                                   # URL path mount point
  --tls-terminated-tcp: int                                            # TCP with TLS terminated
  --yes                                                                # Confirm changes
  --socket: path                                                       # Path to tailscaled socket
  --help(-h)                                                          # Show help
  ...args
]

export extern "tailscale serve status" [
  --json
  --socket: path
  --help(-h)
]

export extern "tailscale serve reset" [
  --yes
  --socket: path
  --help(-h)
]

export extern "tailscale serve get-config" [
  file: path
  --all
  --service: string
  --socket: path
  --help(-h)
]

export extern "tailscale serve set-config" [
  file: path
  --all
  --service: string
  --socket: path
  --help(-h)
]

export extern "tailscale serve drain" [
  service: string # Service name, for example svc:my-service
  --socket: path
  --help(-h)
]

export extern "tailscale serve advertise" [
  service: string # Service name, for example svc:my-service
  --service: string
  --socket: path
  --help(-h)
]

# Set preferences.
export extern "tailscale set" [
  --accept-dns
  --accept-risk: string@"nu-complete tailscale risk"
  --accept-routes
  --advertise-connector
  --advertise-exit-node
  --advertise-routes: string
  --auto-update
  --exit-node: string@"nu-complete tailscale peers"
  --exit-node-allow-lan-access
  --hostname: string
  --netfilter-mode: string@"nu-complete tailscale netfilter-mode"
  --nickname: string
  --operator: string
  --relay-server-port: string
  --relay-server-static-endpoints: string
  --report-posture
  --shields-up
  --snat-subnet-routes
  --ssh
  --stateful-filtering
  --update-check
  --webclient
  --socket: path
  --help(-h)
]

# Tailscale SSH.
export extern "tailscale ssh" [
  destination: string@"nu-complete tailscale peers" # host or user@host
  ...args: string
  --socket: path
  --help(-h)
]

# Status and account switching.
export extern "tailscale status" [
  --active
  --browser
  --header
  --json
  --listen: string
  --peers
  --self
  --web
  --socket: path
  --help(-h)
]

export extern "tailscale switch" [
  account?: string
  --list
  --json
  --socket: path
  --help(-h)
]

export extern "tailscale switch remove" [
  id: string
  --socket: path
  --help(-h)
]

# System policy and tray.
export extern "tailscale syspolicy" [
  command?: string@"nu-complete tailscale syspolicy-subcommands"
  --json
  --socket: path
  --help(-h)
  ...args
]

export extern "tailscale syspolicy list" [
  --json
  --socket: path
  --help(-h)
]

export extern "tailscale syspolicy reload" [
  --json
  --socket: path
  --help(-h)
]

export extern "tailscale systray" [
  --theme: string@"nu-complete tailscale theme"
  --enable-startup: string
  --socket: path
  --help(-h)
]

# Update/version/wait.
export extern "tailscale update" [
  --track: string@"nu-complete tailscale update-track"
  --version: string
  --yes
  --socket: path
  --help(-h)
]

export extern "tailscale version" [
  --daemon
  --json
  --upstream
  --track: string@"nu-complete tailscale update-track"
  --socket: path
  --help(-h)
]

export extern "tailscale wait" [
  --timeout: string
  --socket: path
  --help(-h)
]

export extern "tailscale web" [
  --socket: path
  --help(-h)
]
