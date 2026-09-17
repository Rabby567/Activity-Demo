$taskName = "ActivityTrack Employee Agent"
try {
  Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction Stop
  Write-Host "Automatic startup removed."
} catch {
  Write-Host "Startup task was not found."
}
Read-Host "Press Enter to close"
