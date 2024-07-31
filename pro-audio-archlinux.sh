#!/bin/bash

# Atualizar os pacotes do sistema
echo "Atualizando pacotes do sistema..."
sudo pacman -Syu --noconfirm

# Função para verificar se um pacote está instalado
function instalar_pacote {
    for pacote in "$@"; do
        if ! pacman -Qs $pacote > /dev/null ; then
            echo "Instalando $pacote..."
            sudo pacman -S --noconfirm $pacote
        else
            echo "$pacote já está instalado."
        fi
    done
}

# Instala PipeWire e pacotes relacionados
echo "Instalando PipeWire e pacotes relacionados se não estiverem instalados..."
instalar_pacote pipewire pipewire-pulse pipewire-jack pipewire-alsa wireplumber cpupower

# Verifica se os serviços do PipeWire existem antes de habilitá-los
if systemctl list-unit-files | grep -q 'pipewire.service'; then
    echo "Ativando e iniciando serviços do PipeWire..."
    sudo systemctl enable --now pipewire.service
fi

if systemctl list-unit-files | grep -q 'wireplumber.service'; then
    echo "Ativando e iniciando serviços do WirePlumber..."
    sudo systemctl enable --now wireplumber.service
fi

# Cria os grupos 'realtime' e 'audio' se não existirem
echo "Verificando e criando grupos 'realtime' e 'audio' se necessário..."
if ! grep -q '^realtime:' /etc/group; then
    sudo groupadd realtime
fi

if ! grep -q '^audio:' /etc/group; then
    sudo groupadd audio
fi

# Adiciona o usuário aos grupos 'realtime' e 'audio' para privilégios de tempo real
echo "Adicionando usuário aos grupos 'realtime' e 'audio'..."
sudo usermod -aG realtime,audio $USER

# Configura limites de tempo real
echo "Configurando limites de tempo real..."
sudo tee /etc/security/limits.d/99-realtime.conf > /dev/null <<EOF
@realtime   -  rtprio     99
@realtime   -  memlock    unlimited
@audio      -  rtprio     99
@audio      -  memlock    unlimited
EOF

# Ajusta parâmetros do kernel para otimização de áudio
echo "Ajustando parâmetros do kernel..."
sudo tee /etc/sysctl.d/99-sysctl.conf > /dev/null <<EOF
# Configurações de kernel para otimização de áudio
fs.inotify.max_user_watches = 524288
fs.file-max = 2097152
vm.swappiness = 10
vm.dirty_ratio = 2
vm.dirty_background_ratio = 1
kernel.sched_rt_runtime_us = -1
EOF

# Aplica as mudanças do sysctl
sudo sysctl -p /etc/sysctl.d/99-sysctl.conf

# Configura o 'governor' da CPU para 'performance'
echo "Configurando o governor da CPU para 'performance'..."
sudo systemctl enable --now cpupower.service
sudo tee /etc/default/cpupower > /dev/null <<EOF
# Define o 'governor' a ser usado pelo cpupower
governor='performance'
EOF

sudo systemctl restart cpupower.service

# Verifica se a configuração do governor foi aplicada corretamente
if ! cpupower frequency-info | grep -q "The governor \"performance\" may decide which"; then
    echo "Falha ao definir o governor da CPU como 'performance'. Verifique a configuração manualmente."
fi

# Instala 'rtcqs' para verificar o sistema se não estiver instalado
if ! command -v rtcqs &> /dev/null; then
    echo "Instalando rtcqs..."
    git clone https://aur.archlinux.org/rtcqs.git
    cd rtcqs
    yes | makepkg -si
    cd ..
    rm -rf rtcqs
else
    echo "rtcqs já está instalado."
fi

# Instala e configura 'tuned' se não estiver instalado (comentado pois estava atrasando o carregamento do LXDM)
# if ! pacman -Qs tuned > /dev/null ; then
#     echo "Instalando tuned..."
#     git clone https://aur.archlinux.org/tuned.git
#     cd tuned
#     yes | makepkg -si
#     cd ..
#     rm -rf tuned
# fi
# if systemctl list-unit-files | grep -q 'tuned.service'; then
#     sudo systemctl enable --now tuned
#     sudo tuned-adm profile latency-performance
# fi

# Configura o acesso a /dev/cpu_dma_latency
echo "Configurando acesso a /dev/cpu_dma_latency..."
sudo tee /etc/udev/rules.d/99-cpu-dma-latency.rules > /dev/null <<EOF
KERNEL=="cpu_dma_latency", MODE="0666"
EOF

sudo udevadm control --reload-rules
sudo udevadm trigger

# Instala kernel de tempo real 'linux-rt' se não estiver instalado e o pacote "realtime-privileges"
instalar_pacote linux-rt linux-rt-headers realtime-privileges

# Desabilita mitigações de Spectre/Meltdown
echo "Desabilitando mitigações de Spectre/Meltdown..."
sudo mkdir -p /etc/default/grub.d
sudo tee /etc/default/grub.d/99-spectre-meltdown.cfg > /dev/null <<EOF
GRUB_CMDLINE_LINUX_DEFAULT="mitigations=off"
EOF

# Atualiza o GRUB
sudo grub-mkconfig -o /boot/grub/grub.cfg

echo "Configuração concluída. Por favor, reinicie seu sistema para aplicar todas as configurações."
