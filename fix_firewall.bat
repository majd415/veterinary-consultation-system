@echo off
echo Opening port 8081 for Laravel Dev Server...
netsh advfirewall firewall add rule name="Laravel Dev Server" dir=in action=allow protocol=TCP localport=8081
echo.
echo Done! Port 8081 is now open.
echo You can now run the app on your real device.
pause
