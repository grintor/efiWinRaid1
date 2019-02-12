@set from=ltalerts@alexspc.com
@set to=chris@alexspc.com
@set server=smtp.office365.com
@set enc_password=01000000d08c9ddf0115d1118c7a00c04fc297eb01000000ae0402f6be13a14fb2fb6bb873f6449f000000000200000000001066000000010000200000000072589a29ecf1c85cb6b8ce7d9c1f56e50a16db3fc4a7c85eb67ff42369dc78000000000e8000000002000020000000737b10f2fa73b0f6be13771ee5e3187f6b6d66f35cc27d56b3d437869b6d39f22000000046166cc17a5472e04a48437b96b440ba7eefc754089a6d7e1390cc032f148f614000000062a1eb63e1e89ad31641cd0999549ef0b80caac5cf43802c20ffd29ddbdac263e522a07347de7b06077929a0e9b93cf241fa0c2cc3c8df50db09f4d78faf0c63
@set email_subject=Failed Redundancy: LaF
@set email_body=Failed Redundancy detected at loaves and fishes server
@echo off

:: example: raid_alert.cmd test
:: sends a test email
if "%1"=="test" goto send_email

:: example: raid_alert.cmd make_enc_password "password123"
:: outputs the enc_password to C:\enc_password.txt
if "%1"=="make_enc_password" powershell -command "'%2' | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString" > C:\enc_password.txt


echo list volume | diskpart | find "Failed Rd" && goto send_email
goto :EOF

:send_email

powershell -command $SMTPClient = New-Object Net.Mail.SmtpClient('%server%', 587); ^
                    $SMTPClient.EnableSsl = $true; ^
					$securePwd = ConvertTo-SecureString -String "%enc_password%"; ^
					$credentials = New-Object System.Net.NetworkCredential('%from%', $securePwd); ^
                    $SMTPClient.Credentials = New-Object System.Net.NetworkCredential('%from%', $securePwd); ^
                    $SMTPClient.Send('%from%', '%to%', '%email_subject%', '%email_body%');
