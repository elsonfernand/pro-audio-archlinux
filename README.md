<h1 align="center"> O que esse script faz (ou tenta fazer) </h1>

<p align="center">
  <img width="250" src="https://th.bing.com/th/id/OIG2.J4trgm2XhgGuB_tG1jWR?w=1024&h=1024&rs=1&pid=ImgDetMain" alt="Tux, boladão, fazendo um som" >
</p>
<p align="center">
  <img width="160" src="https://archlinux.org/static/logos/archlinux-logo-dark-scalable.518881f04ca9.svg" alt="Arch Linux logo svg" >
</p>

Seguindo <a href="https://wiki.linuxaudio.org/wiki/system_configuration" target="blank">a wiki do Linux Audio</a> e verificando com o "rtcqs" (Realtime Configuration Quick Scan), esses são alguns passos para configuração de baixa latência no Arch Linux.

01. **Atualização do Sistema:** Atualiza todos os pacotes instalados no sistema.
02. **Função *instalar_pacote*:** Verifica se cada pacote está instalado antes de tentar instalá-lo.
03. **Instalação do *PipeWire*:** O script instala o *pipewire*, *pipewire-pulse*, *pipewire-jack*, *pipewire-alsa* e o *wireplumber*. Também ativa e inicia os serviços *pipewire.service* e *wireplumber.service*.
04. **Adição ao Grupo "realtime":** Adiciona o usuário atual ao grupo realtime para privilégios de tempo real.
05. **Configuração de Limites de Tempo Real:** Define os limites de prioridade e bloqueio de memória para o grupo realtime.
06. **Ajustes de Parâmetros do Kernel:** Aplica várias configurações de kernel recomendadas para otimização de áudio.
07. **Configurar o Governor da CPU para Performance:** Verifica e configura o *governor* da CPU para *performance*.
08. **Instalação do "rtcqs":** Clona o repositório rtcqs do AUR com o pacote "git" e instala a ferramenta para verificar a configuração do sistema.
09. **Instalação e Configuração do "tuned":** Instala o tuned, ativa e aplica o perfil de latency-performance.
10. **Configurar Acesso a */dev/cpu_dma_latency*:** Adiciona uma regra *udev* para configurar o acesso a */dev/cpu_dma_latency*.

Este script deve cobrir a maioria das otimizações necessárias para gravação de áudio com baixa latência no Arch Linux. Depois de executar o script, é recomendável reiniciar o sistema para garantir que todas as configurações sejam aplicadas corretamente.
