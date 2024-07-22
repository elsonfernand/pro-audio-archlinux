# O que esse script faz (ou tenta fazer) #

![image](https://github.com/user-attachments/assets/30789f09-c237-45b8-b66c-a56f40cfbcb7)

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
