
New-NetFirewallRule -DisplayName "Allow TraefikEE connections" -Direction Inbound -Program "C:\traefikee\traefikee.exe" -Action Allow