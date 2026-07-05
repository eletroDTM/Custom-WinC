#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent

; ==========================================
; Configuração de Diretórios Seguros
; ==========================================
; Define a pasta AppData\Roaming\Custom-WinC
global DirApp := A_AppData "\Custom-WinC"

; Cria a pasta caso ela não exista
if not DirExist(DirApp) {
    DirCreate(DirApp)
}

global CaminhoIni := DirApp "\config_atalho.ini"
global CaminhoAtalhoStartup := A_Startup "\Custom-WinC.lnk"
; Define o caminho do executável/script dentro da pasta segura
global CaminhoFixo := DirApp "\" A_ScriptName

; ==========================================
; Leitura das Configurações Salvas
; ==========================================
global ModoAtivo := IniRead(CaminhoIni, "Config", "Modo", 1)
global AtalhoDisplay := IniRead(CaminhoIni, "Config", "Atalho", "!g")
global CaminhoPrograma := IniRead(CaminhoIni, "Config", "Programa", "")
global AtalhoFormatado := ""

AtualizarAtalhoFormatado()

; ==========================================
; Configuração do Ícone na Bandeja do Sistema
; ==========================================
A_TrayMenu.Delete()
A_TrayMenu.Add("Configurar Ação do Win+C", MostrarGui)
A_TrayMenu.Add("Sair", (*) => ExitApp())

A_TrayMenu.Default := "Configurar Ação do Win+C"
A_TrayMenu.ClickCount := 1

; ==========================================
; Função da Interface Gráfica (GUI)
; ==========================================
MostrarGui(*) {
    global ModoAtivo, AtalhoDisplay, CaminhoPrograma, CaminhoAtalhoStartup

    JanelaConfig := Gui("+AlwaysOnTop -MinimizeBox -MaximizeBox", "Configuração Win+C")

    ; GRUPO 1: ATALHO
    RadioAtalho := JanelaConfig.Add("Radio", "vOpcaoModo Checked" (ModoAtivo == 1 ? 1 : 0), "Enviar um atalho de teclado")
    ControleEdit := JanelaConfig.Add("Edit", "vNovoAtalho w280 ReadOnly Center", AtalhoDisplay)
    BtnCapturar := JanelaConfig.Add("Button", "w280", "Capturar Novo Atalho")
    BtnCapturar.OnEvent("Click", CapturarTecla.Bind(ControleEdit, BtnCapturar))

    JanelaConfig.Add("Text", "w280 h2 0x10")

    ; GRUPO 2: PROGRAMA
    RadioProg := JanelaConfig.Add("Radio", "Checked" (ModoAtivo == 2 ? 1 : 0), "Executar um programa")
    ControleProg := JanelaConfig.Add("Edit", "vNovoPrograma w280", CaminhoPrograma)
    BtnProcurar := JanelaConfig.Add("Button", "w280", "Procurar Arquivo (.exe)")
    BtnProcurar.OnEvent("Click", ProcurarArquivo.Bind(ControleProg))

    RadioAtalho.OnEvent("Click", (*) => RadioProg.Value := 0)
    RadioProg.OnEvent("Click", (*) => RadioAtalho.Value := 0)

    JanelaConfig.Add("Text", "w280 h2 0x10")

    ; GRUPO 3: INICIALIZAÇÃO
    JanelaConfig.Add("Checkbox", "vOpcaoStartup Checked" (FileExist(CaminhoAtalhoStartup) ? 1 : 0), "Iniciar junto com o Windows")

    JanelaConfig.Add("Text", "w280 h2 0x10")

    BtnSalvar := JanelaConfig.Add("Button", "w280 Default", "Salvar e Fechar")
    BtnSalvar.OnEvent("Click", SalvarConfig.Bind(JanelaConfig))

    JanelaConfig.Show()
}

; ==========================================
; Funções da Interface (Captura e Seleção)
; ==========================================
ProcurarArquivo(ControleProg, *) {
    ArquivoSelecionado := FileSelect(3, , "Selecione o executável", "Aplicativos (*.exe)")
    if (ArquivoSelecionado != "") {
        ControleProg.Value := ArquivoSelecionado
    }
}

CapturarTecla(ControleEdit, BtnCapturar, *) {
    BtnCapturar.Text := "Aguardando... Pressione agora!"
    BtnCapturar.Enabled := false

    ih := InputHook()
    ih.KeyOpt("{All}", "ES")
    ih.KeyOpt("{LCtrl}{RCtrl}{LAlt}{RAlt}{LShift}{RShift}{LWin}{RWin}", "-E")

    ih.Start()
    ih.Wait()

    ModStr := ""
    if GetKeyState("Ctrl", "P")
        ModStr .= "^"
    if GetKeyState("Alt", "P")
        ModStr .= "!"
    if GetKeyState("Shift", "P")
        ModStr .= "+"
    if GetKeyState("LWin", "P") or GetKeyState("RWin", "P")
        ModStr .= "#"

    Key := ih.EndKey
    ControleEdit.Value := ModStr . Key

    BtnCapturar.Text := "Capturar Novo Atalho"
    BtnCapturar.Enabled := true
}

; ==========================================
; Lógica para Salvar no Arquivo e Gerenciar Inicialização
; ==========================================
SalvarConfig(Janela, *) {
    global ModoAtivo, AtalhoDisplay, CaminhoPrograma, CaminhoIni, CaminhoAtalhoStartup, CaminhoFixo

    Valores := Janela.Submit()

    ModoAtivo := Valores.OpcaoModo ? 1 : 2
    AtalhoDisplay := Valores.NovoAtalho
    CaminhoPrograma := Valores.NovoPrograma
    AtivarStartup := Valores.OpcaoStartup

    if (ModoAtivo == 1 and AtalhoDisplay == "") {
        MsgBox("Por favor, capture um atalho válido antes de salvar.")
        Janela.Show()
        return
    }
    if (ModoAtivo == 2 and CaminhoPrograma == "") {
        MsgBox("Por favor, selecione ou digite o caminho de um programa.")
        Janela.Show()
        return
    }

    ; Gerencia a cópia de segurança e o atalho de inicialização
    if (AtivarStartup) {
        ; Se o arquivo sendo executado não for o que está na pasta AppData, copia para lá
        if (A_ScriptFullPath != CaminhoFixo) {
            try {
                FileCopy(A_ScriptFullPath, CaminhoFixo, 1) ; O número 1 permite sobrescrever
            } catch {
                MsgBox("Aviso: Não foi possível copiar o arquivo para a pasta do sistema.")
            }
        }

        ; Cria o atalho apontando sempre para a cópia no AppData
        if not FileExist(CaminhoAtalhoStartup) {
            FileCreateShortcut(CaminhoFixo, CaminhoAtalhoStartup)
        }
    } else {
        if FileExist(CaminhoAtalhoStartup) {
            FileDelete(CaminhoAtalhoStartup)
        }
    }

    IniWrite(ModoAtivo, CaminhoIni, "Config", "Modo")
    IniWrite(AtalhoDisplay, CaminhoIni, "Config", "Atalho")
    IniWrite(CaminhoPrograma, CaminhoIni, "Config", "Programa")

    AtualizarAtalhoFormatado()
}

AtualizarAtalhoFormatado() {
    global AtalhoDisplay, AtalhoFormatado
    RegExMatch(AtalhoDisplay, "^([+^!#]*)(.*)$", &Match)
    AtalhoFormatado := Match[1] "{" Match[2] "}"
}

; ==========================================
; O Tradutor: Decide o que fazer ao pressionar Win+C
; ==========================================
$#c:: {
    global ModoAtivo, AtalhoFormatado, CaminhoPrograma

    if (ModoAtivo == 1) {
        SendInput(AtalhoFormatado)
    }
    else if (ModoAtivo == 2) {
        try {
            Run(CaminhoPrograma)
        } catch {
            MsgBox("Não foi possível iniciar o programa.`nVerifique se o caminho está correto.")
        }
    }
}