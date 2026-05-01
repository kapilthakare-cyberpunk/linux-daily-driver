
# Use stable Flatpak LibreOffice for command-line tools
alias libreoffice='flatpak run org.libreoffice.LibreOffice'
alias libreoffice-writer='flatpak run org.libreoffice.LibreOffice --writer'
alias libreoffice-calc='flatpak run org.libreoffice.LibreOffice --calc'
alias libreoffice-impress='flatpak run org.libreoffice.LibreOffice --impress'
alias lo='flatpak run org.libreoffice.LibreOffice'
alias lo-headless='flatpak run org.libreoffice.LibreOffice --headless'

# Force Flatpak version by adjusting PATH priority
export PATH="$HOME/.local/bin:$PATH"

# LibreOffice MCP Server commands
alias lo-mcp-start='~/.mcp-libre/start-server.sh'
alias lo-mcp-status='tail -10 ~/mcp-extension.log'
alias lo-mcp-test='~/.mcp-libre/test-connection.sh'
