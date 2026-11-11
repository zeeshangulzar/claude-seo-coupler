# Coupler.io for Claude SEO: uninstaller (Windows / PowerShell).
# Mirrors uninstall.sh.
[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

$SkillTarget = Join-Path $HOME ".claude/skills/seo-coupler"
$McpConfigJson = Join-Path $HOME ".claude.json"

if (Test-Path $SkillTarget) {
    Remove-Item -Path $SkillTarget -Recurse -Force
    Write-Host "[OK] Removed $SkillTarget"
}

if (Test-Path $McpConfigJson) {
    $settingsContent = Get-Content $McpConfigJson -Raw | ConvertFrom-Json
    if ($settingsContent.mcpServers -and ($settingsContent.mcpServers.PSObject.Properties.Name -contains 'coupler-io')) {
        $settingsContent.mcpServers.PSObject.Properties.Remove('coupler-io')
        # Same atomic, BOM-free write as install.ps1.
        $TempConfigJson = Join-Path (Split-Path -Parent $McpConfigJson) ".claude.json.$([guid]::NewGuid().ToString('N')).tmp"
        $jsonText = $settingsContent | ConvertTo-Json -Depth 100
        [System.IO.File]::WriteAllText($TempConfigJson, $jsonText, (New-Object System.Text.UTF8Encoding $false))
        Move-Item -Path $TempConfigJson -Destination $McpConfigJson -Force
        Write-Host "[OK] Removed mcpServers.coupler-io from $McpConfigJson"
    } else {
        Write-Host "  (no mcpServers.coupler-io entry to remove in $McpConfigJson)"
    }
}

Write-Host "Done."
