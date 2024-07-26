# powershell magic, first attempt at an install script
Write-Host "Installing Chocolatey..."
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

Write-Host "Installing rust..."
Invoke-WebRequest -Uri 'https://win.rustup.rs/x86_64' -OutFile '.\rustup-init.exe'
invoke-expression "& .\rustup-init.exe"

$env:Path += ';' + (Join-Path $env:HOMEPATH '.cargo\bin')

Write-Host "Installing Nerd Fonts: Fantasque Sans Mono"

choco install nerd-fonts-fantasquesansmono -y

Write-Host 'Installing cmake...'

$env:Path += ';C:\Program Files\CMake\bin'

Write-Host 'Installing Go...'

Invoke-WebRequest -Uri 'https://go.dev/dl/go1.22.5.windows-amd64.msi' -OutFile '.\go1.22.5.windows-amd64.msi'
invoke-expression "& msiexec /quiet /passive /i go1.22.5.windows-amd64.msi"

Write-Host 'Installing Node...'

choco install fnm -y
fnm env --use-on-cd | Out-String | Invoke-Expression
fnm use --install-if-missing 20

Write-Host 'Installing Google Cloud SDK...'

(New-Object Net.WebClient).DownloadFile("https://dl.google.com/dl/cloudsdk/channels/rapid/GoogleCloudSDKInstaller.exe", "$env:Temp\GoogleCloudSDKInstaller.exe")

& $env:Temp\GoogleCloudSDKInstaller.exe

choco install cmake --installargs 'ADD_CMAKE_TO_PATH=System' --apply-install-arguments-to-dependencies -y

Write-Host 'Installing starship...'

cargo install starship --locked

Write-Host 'Installing cli and gui tools...'

choco install -y kubernetes-cli kubectx terraform fzf lsd kubernetes-helm azure-cli openlens go-task cloudflared vscodium bicep powershell-core microsoft-windows-terminal
pwsh -Command "Install-Module -Name Az -Repository PSGallery -Force"

Write-Host 'Configuring PowerShell...'

New-Item -ItemType Directory -Force ~/.config;New-Item -ItemType file ~/.config/starship.toml;
cd ~/.config;starship preset pastel-powerline -o "starship.toml"

Write-Host 'Installing Terminal...'

# TODO: Check versions
Invoke-WebRequest -Uri https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx -outfile C:\Temp\Microsoft.VCLibs.x86.14.00.Desktop.appx
Add-AppxPackage C:\Temp\Microsoft.VCLibs.x86.14.00.Desktop.appx

Invoke-WebRequest -Uri https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.5/Microsoft.UI.Xaml.2.8.x64.appx -outfile C:\Temp\Microsoft.UI.Xaml.2.8.x64.appx
Add-AppxPackage C:\Temp\Microsoft.UI.Xaml.2.8.x64.appx

Invoke-WebRequest -Uri https://github.com/microsoft/terminal/releases/download/v1.18.2822.0/Microsoft.WindowsTerminal_1.18.2822.0_8wekyb3d8bbwe.msixbundle -outfile C:\Temp\Microsoft.WindowsTerminal_1.18.2822.0_8wekyb3d8bbwe.msixbundle
Add-AppxPackage C:\Temp\Microsoft.WindowsTerminal_1.18.2822.0_8wekyb3d8bbwe.msixbundle

Write-Host 'Installing VS Codium extensions...'

codium --install-extension jeanp413.open-remote-ssh
codium --install-extension Equinusocio.vsc-material-theme-icons
codium --install-extension Codeium.codeium
codium --install-extension EditorConfig.EditorConfig
codium --install-extension mitchdenny.ecdc
codium --install-extension eamodio.gitlens
codium --install-extension seatonjiang.gitmoji-vscode
codium --install-extension golang.go
codium --install-extension humao.rest-client
codium --install-extension rust-lang.rust-analyzer
codium --install-extension SonarSource.sonarlint-vscode
codium --install-extension RobbOwen.synthwave-vscode
codium --install-extension Gruntfuggly.todo-tree

