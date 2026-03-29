#!/bin/bash
# Arch Linux Minimal Installer für Low-End Hardware (AMD Athlon / 2GB RAM)
# Fokus: Performance & Stabilität

set -e

# --- Variablen ---
USERNAME="sonke"
HOSTNAME="unit-workstation"

echo "------------------------------------------------------"
echo "Starte optimierte Installation für $HOSTNAME"
echo "------------------------------------------------------"

# 1. System Update
pacman -Syu --noconfirm

# 2. Basis Tools & Performance (zRam ist essentiell bei 2GB!)
echo "[*] Installiere Basis-Tools und zRAM-Generator..."
pacman -S --needed --noconfirm \
    base-devel git nano vim sudo networkmanager \
    wget curl htop zram-generator

# 3. Grafik (Speziell für ATI Radeon HD 3200)
echo "[*] Installiere Grafiktreiber (xf86-video-ati)..."
pacman -S --needed --noconfirm \
    xorg-server xorg-xinit xf86-video-ati mesa lib32-mesa

# 4. i3 Desktop & Performance-Compositor
echo "[*] Installiere i3-wm und schlanke Utilities..."
pacman -S --needed --noconfirm \
    i3-wm i3status dmenu alacritty feh picom \
    lightdm lightdm-gtk-greeter

# 5. Audio & Dateimanager (Pipewire ist CPU-schonender)
echo "[*] Installiere Audio und File-Management..."
pacman -S --needed --noconfirm \
    pipewire pipewire-pulse pipewire-alsa pavucontrol \
    thunar gvfs xfce4-power-manager

# 6. Browser-Auswahl (Firefox + uBlock ist das Minimum für 2GB)
pacman -S --needed --noconfirm firefox

# 7. User Setup & Sudo
echo "[*] Richte Benutzer $USERNAME ein..."
if ! id -u "$USERNAME" >/dev/null 2>&1; then
    useradd -m -G wheel -s /bin/bash "$USERNAME"
    echo "Bitte Passwort für $USERNAME festlegen:"
    passwd "$USERNAME"
fi
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

# 8. Hostname & Services
echo "$HOSTNAME" > /etc/hostname
systemctl enable NetworkManager
systemctl enable lightdm

# 9. zRAM Konfiguration (WICHTIG: Macht aus 2GB gefühlte 3GB)
echo "[*] Konfiguriere zRAM..."
cat <<EOF > /etc/systemd/zram-generator.conf
[zram0]
zram-size = ram / 1
compression-algorithm = zstd
EOF

# 10. Xinit & i3 Start-Config
cat <<EOF > /home/$USERNAME/.xinitrc
#!/bin/sh
# Picom mit xrender starten, da GLX auf alter ATI oft laggt
picom --backend xrender & 
exec i3
EOF
chown $USERNAME:$USERNAME /home/$USERNAME/.xinitrc
chmod +x /home/$USERNAME/.xinitrc

echo "------------------------------------------------------"
echo "Fertig! Bitte mit 'reboot' neu starten."
echo "Tipp: Installiere in Firefox sofort 'uBlock Origin'!"
echo "------------------------------------------------------"
