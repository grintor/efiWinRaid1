@echo off
c:
cd c:\

cls
echo ===========================================
echo we will open disk management.
echo make sure that you delete out any old mirrors
echo (if applicable)
echo ===========================================
pause
start /wait diskmgmt.msc

cls
echo ===========================================
echo we will open msconfig.
echo go to the boot tab and make sure current os is set as default os
echo delete anything else
echo check "make all setting perm." box.
echo ===========================================
pause
start /wait msconfig

cls
echo ==here are your disks==============================================================
echo list disk >diskpart_list_disk.txt
diskpart /s diskpart_list_disk.txt
del diskpart_list_disk.txt
echo.
echo ==please enter the disk number you want to mirrror FROM==============================
set /p fromdisk=: 

cls
echo ==here are your disks==============================================================
echo list disk >diskpart_list_disk.txt
diskpart /s diskpart_list_disk.txt
del diskpart_list_disk.txt
echo.
echo ==please enter the disk number you want to mirrror TO==============================
set /p todisk=: 


cls
echo ==here are the partitions for disk %fromdisk%===============================================
echo select disk %fromdisk% >diskpart_list_part.txt
echo list part >>diskpart_list_part.txt
diskpart /s diskpart_list_part.txt
del diskpart_list_part.txt
echo.
echo ==please enter the partition number that is the efi boot partition=================
set /p efipart=: 

cls
echo ==This will delete all data on disk %todisk%=======================================
pause
pause
pause

echo select disk %todisk% >diskpart_script.txt
echo clean >>diskpart_script.txt
echo convert GPT >>diskpart_script.txt
echo select partition 1 >>diskpart_script.txt
echo delete partition override >>diskpart_script.txt
echo create partition efi size=100 >>diskpart_script.txt
echo create partition msr size=128 >>diskpart_script.txt
echo convert dynamic >>diskpart_script.txt
echo select partition 1 >>diskpart_script.txt
echo assign letter=S >>diskpart_script.txt
echo format fs=FAT32 quick >>diskpart_script.txt

echo select disk %fromdisk% >>diskpart_script.txt
echo convert dynamic >>diskpart_script.txt
echo select volume C >>diskpart_script.txt
echo add disk=%todisk% >>diskpart_script.txt
echo select partition %efipart% >>diskpart_script.txt
echo assign letter=P >>diskpart_script.txt

diskpart /s diskpart_script.txt
del diskpart_script.txt

robocopy p:\ s:\ /e /r:0

bcdedit /export s:\EFI\Microsoft\Boot\BCD
bcdedit /store s:\EFI\Microsoft\Boot\BCD /set {bootmgr} device partition=s:

:: get the last identifier (because it should be secondary plex)
for /f "tokens=1,2" %%n in ('bcdedit /store s:\EFI\Microsoft\Boot\BCD /enum') do if "%%n"=="identifier" set identifier=%%o

bcdedit /store s:\EFI\Microsoft\Boot\BCD /default %identifier%

echo select volume P >diskpart_cleanup.txt
echo remove >>diskpart_cleanup.txt
echo select volume S >>diskpart_cleanup.txt
echo remove >>diskpart_cleanup.txt
diskpart /s diskpart_cleanup.txt
del diskpart_cleanup.txt

echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo ==process complete. good luck======================================================

pause > nul
