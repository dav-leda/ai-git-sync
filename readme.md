# AI Git Sync

**[English](#english) | [Español](#español)**

---

## Español

### Tabla de Contenidos
- [Características](#características)
- [Requisitos Previos](#requisitos-previos)
- [Instalación](#instalación-1)
- [Configuración para Windows](#configuración-para-windows)
- [Uso](#uso-1)
- [Variables de Entorno](#variables-de-entorno)
- [Mensajes de Commit con IA](#mensajes-de-commit-con-ia)
- [Salida](#salida)
- [Manejo de Errores](#manejo-de-errores)
- [Integración](#integración-1)
- [Solución de Problemas](#solución-de-problemas)

Un script inteligente de sincronización de Git que maneja automáticamente cambios locales y remotos con mensajes de commit generados por IA usando la API de Claude.

### Características

- **Mensajes de Commit con IA**: Genera mensajes de commit inteligentes usando la API de Claude
- **Sincronización Automática**: Maneja cambios locales, remotos y fusión sin problemas
- **Resolución Inteligente de Conflictos**: Fusiona automáticamente cambios locales y remotos cuando es posible
- **Mecanismo de Respaldo**: Funciona incluso sin acceso a la API con mensajes de commit predeterminados 
- **Salida con Códigos de Color**: Retroalimentación visual clara con mensajes de estado coloreados
- **Operación Segura**: Manejo integral de errores y validación de repositorio git

### Requisitos Previos

- Git instalado y configurado
- Shell Bash con utilidades Unix (`curl`, `grep`, `sed`, `tr`, `wc`)
  - **macOS/Linux**: Integrado
  - **Windows**: Requiere WSL, Git Bash, o Cygwin (ver [Configuración para Windows](#configuración-para-windows))
- *(Opcional)* Clave API de Claude para mensajes de commit con IA

### Instalación

1. **Descargar el script:**

   **Opción A: Clonar el repositorio completo**
   ```bash
   git clone https://github.com/dav-leda/ai-git-sync.git
   cd ai-git-sync
   chmod +x ai-git-sync.sh
   ```

   **Opción B: Descargar solo el script (si está disponible públicamente)**
   ```bash
   curl -O https://github.com/dav-leda/ai-git-sync/raw/main/ai-git-sync.sh
   chmod +x ai-git-sync.sh
   ```

   **Opción C: Crear el script manualmente**
   ```bash
   # Copia el código del script desde el repositorio y créalo localmente
   nano ai-git-sync.sh
   # Pega el contenido del script y guarda
   chmod +x ai-git-sync.sh
   ```

2. *(Opcional)* Para mensajes de commit con IA, configura tu clave API de Claude:

   **Opción A: Archivo .env (recomendado para proyectos)**
   ```bash
   echo "CLAUDE_API_KEY=tu_clave_api_aqui" > .env
   ```

   **Opción B: Variable de entorno del shell**
   ```bash
   export CLAUDE_API_KEY="tu_clave_api_aqui"
   # O agrégalo a tu ~/.bashrc o ~/.zshrc para que persista
   echo 'export CLAUDE_API_KEY="tu_clave_api_aqui"' >> ~/.bashrc
   ```

### Configuración para Windows

Los usuarios de Windows tienen varias opciones para ejecutar este script Bash:

#### Opción 1: Subsistema de Windows para Linux (WSL) - Recomendado

1. **Instalar WSL**:
   ```powershell
   wsl --install
   ```

2. **Abrir terminal WSL** y seguir los pasos de instalación estándar

3. **Acceder archivos de Windows** desde WSL:
   ```bash
   cd /mnt/c/tu/ruta/del/proyecto
   ./ai-git-sync.sh
   ```

#### Opción 2: Git Bash

1. **Instalar Git para Windows** (incluye Git Bash): https://git-scm.com/download/win

2. **Abrir Git Bash** y navegar a tu repositorio

3. **Ejecutar el script**:
   ```bash
   ./ai-git-sync.sh
   ```

#### Opción 3: Cygwin

1. **Instalar Cygwin**: https://www.cygwin.com/

2. **Incluir paquetes requeridos**: `git`, `curl`, `grep`, `sed`, `bash`

3. **Ejecutar desde terminal Cygwin**:
   ```bash
   ./ai-git-sync.sh
   ```

### Uso

#### Uso Básico

Tienes varias opciones para ejecutar el script:

**Opción 1: Copiar el script a tu proyecto**
```bash
# Copia el script a la raíz de tu repositorio
cp /ruta/a/ai-git-sync.sh ./
chmod +x ai-git-sync.sh
./ai-git-sync.sh
```

**Opción 2: Usar ruta absoluta**
```bash
# Desde cualquier repositorio Git
/ruta/completa/a/ai-git-sync.sh
```

**Opción 3: Agregar al PATH del sistema**
```bash
# Mover a directorio en PATH
sudo mv ai-git-sync.sh /usr/local/bin/ai-git-sync
sudo chmod +x /usr/local/bin/ai-git-sync
# Luego desde cualquier repositorio:
ai-git-sync
```

#### Lo que Hace el Script

El script automáticamente:

1. **Valida** que estés en un repositorio Git
2. **Obtiene** los últimos cambios del repositorio remoto
3. **Confirma** cualquier cambio local con un mensaje generado por IA
4. **Extrae** cambios remotos si existen
5. **Fusiona** cambios cuando existen cambios tanto locales como remotos
6. **Empuja** commits locales al repositorio remoto

#### Ejemplos de Flujo de Trabajo

**Escenario 1: Solo Cambios Locales**
```
Cambios locales detectados → Preparar todos los cambios → Generar mensaje de commit con IA → Confirmar → Empujar
```

**Escenario 2: Solo Cambios Remotos**
```
Cambios remotos detectados → Extraer cambios → Repositorio actualizado
```

**Escenario 3: Cambios Locales y Remotos**
```
Cambios locales → Confirmar con mensaje IA → Extraer cambios remotos → Auto-fusionar → Empujar resultado fusionado
```

### Variables de Entorno

#### Requerido para Características IA

- `CLAUDE_API_KEY`: Tu clave API de Anthropic Claude para generar mensajes de commit inteligentes

#### Archivo de Entorno

Crea un archivo `.env` en la raíz de tu repositorio:

```bash
# Configuración API Claude
CLAUDE_API_KEY=tu_clave_api_claude_aqui
```

### Mensajes de Commit con IA

Cuando se proporciona una clave API de Claude, el script:

- Analiza tu diff de git y archivos cambiados
- Genera mensajes de commit convencionales (feat:, fix:, docs:, etc.)
- Mantiene mensajes concisos y descriptivos (máx. 72 caracteres)
- Recurre a mensajes simples si la API no está disponible

#### Ejemplos de Mensajes Generados por IA

```
feat: agregar middleware de autenticación de usuario
fix: resolver fuga de memoria en procesamiento de datos
docs: actualizar documentación API con ejemplos
refactor: simplificar lógica de conexión a base de datos
```

### Salida

El script proporciona retroalimentación con códigos de color:

- 🔵 **[INFO]**: Mensajes informativos sobre operaciones actuales
- 🟢 **[SUCCESS]**: Finalización exitosa de operaciones
- 🟡 **[WARNING]**: Advertencias no críticas (ej. respaldo de API)
- 🔴 **[ERROR]**: Errores críticos que detienen la ejecución

### Manejo de Errores

El script incluye manejo robusto de errores para:

- Repositorios no-git
- Problemas de conectividad de red
- Fallas de API (con respaldo)
- Conflictos de fusión (resolución manual requerida)
- Ramas remotas faltantes

### Integración

#### Como Alias de Git

Agregar a tu `~/.gitconfig`:

```ini
[alias]
    sync = "!sh /ruta/a/ai-git-sync.sh"
```

Luego usar: `git sync`

### Solución de Problemas

#### Problemas Comunes

**El script sale con "Not a git repository"**
- Asegúrate de ejecutar el script desde dentro de un repositorio Git
- Verifica que la carpeta `.git` existe en los directorios actuales o padre

**Windows: errores "command not found"**
- Asegúrate de usar WSL, Git Bash, o Cygwin
- Verifica que todas las utilidades Unix requeridas estén disponibles (`curl`, `grep`, `sed`, `tr`)
- Verifica que el script tenga terminaciones de línea Unix (LF, no CRLF)

**Clave API no funciona**
- Verifica que tu clave API de Claude sea correcta
- Verifica que el archivo `.env` esté en el mismo directorio que el script
- Asegúrate de que la clave API tenga permisos apropiados

---

## English

### Table of Contents
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Windows Setup](#windows-setup)
- [Usage](#usage)
- [Environment Variables](#environment-variables)
- [AI-Powered Commit Messages](#ai-powered-commit-messages)
- [Output](#output)
- [Error Handling](#error-handling)
- [Integration](#integration)
- [Troubleshooting](#troubleshooting)

An intelligent Git synchronization script that automatically handles local and remote changes with AI-powered commit messages using Claude API.

## Features

- **AI-Powered Commit Messages**: Generates intelligent, conventional commit messages using Claude API
- **Automatic Synchronization**: Handles local changes, remote changes, and merging seamlessly
- **Smart Conflict Resolution**: Automatically merges local and remote changes when possible
- **Fallback Mechanism**: Works even without API access with sensible default commit messages
- **Color-Coded Output**: Clear visual feedback with colored status messages
- **Safe Operation**: Comprehensive error handling and git repository validation

## Prerequisites

- Git installed and configured
- Bash shell with Unix utilities (`curl`, `grep`, `sed`, `tr`, `wc`)
  - **macOS/Linux**: Built-in
  - **Windows**: Requires WSL, Git Bash, or Cygwin (see [Windows Setup](#windows-setup))
- *(Optional)* Claude API key for AI-powered commit messages

## Installation

1. **Download the script:**

   **Option A: Clone the entire repository**
   ```bash
   git clone https://github.com/dav-leda/ai-git-sync.git
   cd ai-git-sync
   chmod +x ai-git-sync.sh
   ```

   **Option B: Download script only (if publicly available)**
   ```bash
   curl -O https://github.com/dav-leda/ai-git-sync/raw/main/ai-git-sync.sh
   chmod +x ai-git-sync.sh
   ```

   **Option C: Create the script manually**
   ```bash
   # Copy the script code from the repository and create it locally
   nano ai-git-sync.sh
   # Paste the script content and save
   chmod +x ai-git-sync.sh
   ```

2. *(Optional)* For AI-powered commit messages, set up your Claude API key:

   **Option A: .env file (recommended for projects)**
   ```bash
   echo "CLAUDE_API_KEY=your_api_key_here" > .env
   ```

   **Option B: Shell environment variable**
   ```bash
   export CLAUDE_API_KEY="your_api_key_here"
   # Or add it to your ~/.bashrc or ~/.zshrc to persist
   echo 'export CLAUDE_API_KEY="your_api_key_here"' >> ~/.bashrc
   ```

## Windows Setup

Windows users have several options to run this Bash script:

### Option 1: Windows Subsystem for Linux (WSL) - Recommended

1. **Install WSL**:
   ```powershell
   wsl --install
   ```

2. **Open WSL terminal** and follow the standard installation steps

3. **Access Windows files** from WSL:
   ```bash
   cd /mnt/c/your/project/path
   ./ai-git-sync.sh
   ```

### Option 2: Git Bash

1. **Install Git for Windows** (includes Git Bash): https://git-scm.com/download/win

2. **Open Git Bash** and navigate to your repository

3. **Run the script**:
   ```bash
   ./ai-git-sync.sh
   ```

### Option 3: Cygwin

1. **Install Cygwin**: https://www.cygwin.com/

2. **Include required packages**: `git`, `curl`, `grep`, `sed`, `bash`

3. **Run from Cygwin terminal**:
   ```bash
   ./ai-git-sync.sh
   ```


## Usage

### Basic Usage

You have several options to run the script:

**Option 1: Copy script to your project**
```bash
# Copy the script to your repository root
cp /path/to/ai-git-sync.sh ./
chmod +x ai-git-sync.sh
./ai-git-sync.sh
```

**Option 2: Use absolute path**
```bash
# From any Git repository
/full/path/to/ai-git-sync.sh
```

**Option 3: Add to system PATH**
```bash
# Move to a directory in PATH
sudo mv ai-git-sync.sh /usr/local/bin/ai-git-sync
sudo chmod +x /usr/local/bin/ai-git-sync
# Then from any repository:
ai-git-sync
```

### What the Script Does

The script automatically:

1. **Validates** that you're in a Git repository
2. **Fetches** the latest changes from the remote repository
3. **Commits** any local changes with an AI-generated message
4. **Pulls** remote changes if they exist
5. **Merges** changes when both local and remote changes are present
6. **Pushes** local commits to the remote repository

### Workflow Examples

#### Scenario 1: Only Local Changes
```
Local changes detected → Stage all changes → Generate AI commit message → Commit → Push
```

#### Scenario 2: Only Remote Changes
```
Remote changes detected → Pull changes → Repository updated
```

#### Scenario 3: Both Local and Remote Changes
```
Local changes → Commit with AI message → Pull remote changes → Auto-merge → Push merged result
```

#### Scenario 4: Repository Up to Date
```
No changes detected → Report status → No action needed
```

## Environment Variables

### Required for AI Features

- `CLAUDE_API_KEY`: Your Anthropic Claude API key for generating intelligent commit messages

### Environment File

Create a `.env` file in your repository root:

```bash
# Claude API Configuration
CLAUDE_API_KEY=your_claude_api_key_here
```

## AI-Powered Commit Messages

When a Claude API key is provided, the script:

- Analyzes your git diff and changed files
- Generates conventional commit messages (feat:, fix:, docs:, etc.)
- Keeps messages concise and descriptive (max 72 characters)
- Falls back to simple messages if the API is unavailable

### Example AI-Generated Messages

```
feat: add user authentication middleware
fix: resolve memory leak in data processing
docs: update API documentation with examples
refactor: simplify database connection logic
```

## Output

The script provides color-coded feedback:

- 🔵 **[INFO]**: Informational messages about current operations
- 🟢 **[SUCCESS]**: Successful completion of operations
- 🟡 **[WARNING]**: Non-critical warnings (e.g., API fallback)
- 🔴 **[ERROR]**: Critical errors that stop execution

## Error Handling

The script includes robust error handling for:

- Non-git repositories
- Network connectivity issues
- API failures (with fallback)
- Merge conflicts (manual resolution required)
- Missing remote branches

## Integration

### As a Git Alias

Add to your `~/.gitconfig`:

```ini
[alias]
    sync = "!sh /path/to/ai-git-sync.sh"
```

Then use: `git sync`

### As a Pre-commit Hook

Create `.git/hooks/pre-push`:

```bash
#!/bin/bash
/path/to/ai-git-sync.sh
```

### In CI/CD Pipelines

```yaml
# Example GitHub Actions step
- name: Sync Repository
  run: |
    chmod +x ./ai-git-sync.sh
    ./ai-git-sync.sh
  env:
    CLAUDE_API_KEY: ${{ secrets.CLAUDE_API_KEY }}
```

## Troubleshooting

### Common Issues

**Script exits with "Not a git repository"**
- Ensure you're running the script from within a Git repository
- Check that `.git` folder exists in the current or parent directories

**Windows: "command not found" errors**
- Ensure you're using WSL, Git Bash, or Cygwin
- Verify all required Unix utilities are available (`curl`, `grep`, `sed`, `tr`)
- Check that the script has Unix line endings (LF, not CRLF)

**Windows: Permission denied**
- Make the script executable: `chmod +x ai-git-sync.sh`
- Ensure your shell environment has proper permissions

**API key not working**
- Verify your Claude API key is correct
- Check that the `.env` file is in the same directory as the script
- Ensure the API key has appropriate permissions

**Merge conflicts**
- The script will pause for manual resolution
- Resolve conflicts manually and run the script again

### Debug Mode

For verbose output, modify the script to include:
```bash
set -x  # Enable debug mode
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

MIT License - see LICENSE file for details

## Support

For issues and questions:
- Check the troubleshooting section
- Review git status and logs
- Ensure API credentials are properly configured