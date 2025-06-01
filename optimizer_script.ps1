# === Painel de Otimizacao CS2 ===
function Registrar-Log {
    param (
        [string]$mensagem
    )

    $dataHora = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $linha = "[$dataHora] $mensagem"
    Add-Content -Path "log_optimizar.txt" -Value $linha
}
function Limpar-Temporarios {
    Write-Host "Limpando arquivos temporarios..." -ForegroundColor Yellow
    Registrar-Log "Arquivos temporarios limpos com sucesso."


    try {
        Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "$env:windir\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "$env:windir\Prefetch\*" -Recurse -Force -ErrorAction SilentlyContinue

        Write-Host "Arquivos temporarios limpos com sucesso!" -ForegroundColor Green
    } catch {
        Write-Host "Ocorreu um erro ao limpar os arquivos." -ForegroundColor Red
    }
}

function Mostrar-TopRAM {
    Write-Host "Top 10 processos que mais consomem MEMORIA (RAM):" -ForegroundColor Cyan
    Get-Process | Sort-Object WorkingSet -Descending | 
        Select-Object -First 10 Name, ID, @{Name="RAM_MB";Expression = {[math]::Round($_.WorkingSet / 1MB, 2)}} |
        Format-Table -AutoSize
}

function Mostrar-TopCPU {
    Write-Host "Top 10 processos que mais consomem CPU (tempo acumulado):" -ForegroundColor Cyan
    Get-Process | Sort-Object CPU -Descending | 
        Select-Object -First 10 Name, ID, @{Name="CPU_s";Expression = {[math]::Round($_.CPU, 2)}} |
        Format-Table -AutoSize
}

function Desativar-ServicosParaJogo {
    Write-Host ""
    Write-Host "Desativando servicos desnecessarios para jogar CS2..." -ForegroundColor Yellow

    $servicos = @(
        "SysMain",
        "WSearch",
        "Fax",
        "Spooler",
        "DiagTrack",
        "DiagServiceHost",
        "DiagSystemHost",
        "OneSyncSvc",
        "XboxGipSvc",
        "XblAuthManager",
        "XblGameSave",
        "BluetoothSupportService",
        "WMPNetworkSvc"
    )
    Write-Host "`nSerão desativados os seguintes serviços:" -ForegroundColor Cyan
    foreach ($svc in $servicos) {
        Write-Host "-> $svc"
    }

    foreach ($svc in $servicos) {
        try {
            Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
        } catch {
            Write-Host "Nao foi possivel parar $svc." -ForegroundColor DarkGray
        }
    }
    Registrar-Log "Servicos desativados: $($servicos -join ', ')"
    Write-Host "`nServicos desativados temporariamente." -ForegroundColor Green
}
function Reativar-ServicosPadrao {
    Write-Host ""
    Write-Host "Reativando serviços padrão do sistema..." -ForegroundColor Yellow

    $servicos = @(
        "SysMain",
        "WSearch",
        "Fax",
        "Spooler",
        "DiagTrack",
        "DiagServiceHost",
        "DiagSystemHost",
        "OneSyncSvc",
        "XboxGipSvc",
        "XblAuthManager",
        "XblGameSave",
        "BluetoothSupportService",
        "WMPNetworkSvc"
    )

    foreach ($svc in $servicos) {
        try {
            Start-Service -Name $svc -ErrorAction SilentlyContinue
            Write-Host "-> $svc reativado." -ForegroundColor Green
        } catch {
            Write-Host "Nao foi possivel iniciar $svc." -ForegroundColor DarkGray
        }
    }
    Registrar-Log "Servicos reativados: $($servicos -join ', ')"
    Write-Host "`nTodos os servicos padrao foram reativados." -ForegroundColor Cyan
}

function Mostrar-ComandosCS2 {
    Write-Host ""
    Write-Host "Comandos recomendados para colocar no lancamento do CS2:" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "-novid             => Remove a intro da Valve (carrega mais rapido)"
    Write-Host "-high              => Inicia o jogo com prioridade alta"
    Write-Host "+fps_max 0         => Libera o FPS (sem limite)"
    Write-Host "+cl_forcepreload 1 => Pre-carrega mapas (menos travamentos)"
    Write-Host "-tickrate 128      => Melhora resposta em servidores locais"
    Write-Host "-nojoy             => Desativa suporte a joystick"
    Write-Host "+mat_queue_mode 2  => Usa threads multiplas para renderizacão"
    Write-Host ""
    Write-Host "Como aplicar:" -ForegroundColor Cyan
    Write-Host "1. Abra a Steam"
    Write-Host "2. Va na biblioteca e clique com botao direito no CS2 > Propriedades"
    Write-Host "3. Em 'Opçoes de Inicializacao', cole os comandos acima em uma linha so"
    Write-Host ""
    Write-Host "Exemplo completo:" -ForegroundColor Green
    Write-Host "-novid -high +fps_max 0 +cl_forcepreload 1 -tickrate 128 -nojoy +mat_queue_mode 2"
}

function Modo-Turbo {
    Registrar-Log "Modo Turbo ativado"

    Write-Host ""
    Write-Host "==== MODO TURBO ATIVADO ====" -ForegroundColor Magenta
    Limpar-Temporarios
    Mostrar-TopRAM
    Mostrar-TopCPU
    Desativar-ServicosParaJogo
    Write-Host "`nModo Turbo concluido. Pronto para jogar!" -ForegroundColor Green
     Registrar-Log "Modo Turbo finalizado"
}

function Pause {
    Write-Host ""
    Write-Host "Pressione qualquer tecla para continuar..." -ForegroundColor DarkGray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

do {
    Clear-Host
    Write-Host "=== Painel de Otimizacao CS2 ===" -ForegroundColor Cyan
    Write-Host "1 - Limpar arquivos temporarios"
    Write-Host "2 - Ver top 10 processos que mais usam RAM"
    Write-Host "3 - Ver top 10 processos que mais usam CPU"
    Write-Host "4 - Desativar servicos para melhorar desempenho no jogo"
    Write-Host "5 - Reativar servicos do sistema apos o jogo"
    Write-Host "6 - Modo Turbo (Executar tudo de uma vez)"
    Write-Host "7 - Ver comandos recomendados para colocar no lancamento do CS2"
    Write-Host "0 - Sair"
    Write-Host ""
    Write-Host "Escolha uma opcao: " -NoNewline
    $opcao = Read-Host

    switch ($opcao) {
        '1' { Limpar-Temporarios; Pause }
        '2' { Mostrar-TopRAM; Pause }
        '3' { Mostrar-TopCPU; Pause }
        '4' { Desativar-ServicosParaJogo; Pause }
        '5' { Reativar-ServicosPadrao; Pause }
        '6' { Modo-Turbo; Pause }
        '7' { Mostrar-ComandosCS2; Pause }

        '0' {
            Write-Host "Saindo..." -ForegroundColor Magenta
            Start-Sleep -Seconds 1
            exit
}

        default { Write-Host "Opcao invalida!"; Pause }
    }

} while ($true)
