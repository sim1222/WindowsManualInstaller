@echo off
:Ver
cls
echo ********************************************
echo *Windows 10 1803 Winpe-tch用 Windowsインストーラー for UEFI*
echo ********************************************
echo Ver.1.0
echo.
echo.

rem -----------------------------------------------------

:Start
echo.
color C
set Start=
set /P Start="このインストーラーは即席仕様です。何が起こっても自己責任で使用してください。同意しますか？ (Y/N)"
if "%Start%" == "" (
  goto :Start
)
if /i {%Start%}=={y} (goto :sysdrvcheck)
if /i {%Start%}=={yes} (goto :sysdrvcheck)

pause
EXIT

rem -----------------------------------------------------

:sysdrvcheck
cls
color
echo lis dis | diskpart
echo.
set sysdrv=
SET /P sysdrv="上記を確認し、インストール対象ディスクを 半角 数字 1文字 で入力してください (例: 1 )"
if "%sysdrv%" == "" (
  goto :sysdrvcheck
)

goto :syschrcheck

rem -----------------------------------------------------

:syschrcheck
echo lis vol | diskpart
echo.
set syschr=
SET /P syschr="上記を確認し、上記に存在しない任意のドライブレターを 大文字 半角 英字 1文字 で入力してください W, Xは使用しないでください (例: C )"
if "%syschr%" == "" (
  goto :syschrcheck
)

goto :deletecheck

rem -----------------------------------------------------

:deletecheck
echo.
set delete=
SET /P delete="ディスク%sysdrv%は完全に削除されます。この操作はもとに戻せません。削除を実行しますか？ (Y/N)"
if "%delete%" == "" (
  goto :deletecheck
)
if /i {%delete%}=={yes} (goto :delete)
if /i {%delete%}=={y} (goto :delete)

echo Y以外が入力されました。開始確認に戻ります...
timeout 5
goto :Ver

rem -----------------------------------------------------

:delete

echo sel dis %sysdrv% > temp.txt
echo clean >> temp.txt
echo convert gpt >> temp.txt
echo create partition efi size=500 >> temp.txt
echo format fs=fat32 quick >> temp.txt
echo assign letter w >> temp.txt
echo create partition primary >> temp.txt
echo format quick >> temp.txt
echo assign letter %syschr% >> temp.txt
diskpart /s temp.txt

goto :wimpath

rem -----------------------------------------------------

:wimpath
echo.
set wimpath=
SET /P wimpath="USBメモリにあるinstall.wimの場所をフルパスで指定してください。 (例: D:\install.wim )"
if "%wimpath%" == "" (
  goto :wimpath
)

goto :wimselect

rem -----------------------------------------------------


:wimselect
dism /get-wiminfo /imagefile:%wimpath% 
set wimnum=
set /P wimnum="インストールしたいOSのWIM番号を入力してください。 (例: 1 )"
if "%wimnum%" == "" (
  goto :wimselect
)

goto :install

rem -----------------------------------------------------


:install
echo.
echo インストールを開始します...
dism /apply-image /imagefile:%wimpath% /index:%wimnum% /applydir:%syschr%:\
bcdboot %syschr%:\Windows /s W: /f UEFI

goto :regedit

rem -----------------------------------------------------

:regedit
echo.

reg load HKLM\SOFT %syschr%:\Windows\System32\config\SOFTWARE
reg add HKLM\SOFT\Microsoft\Windows\CurrentVersion\Policies\System /v VerboseStatus /t REG_DWORD /d 1 /f
reg add HKLM\SOFT\Microsoft\Windows\CurrentVersion\Policies\System /v EnableCursorSuppression /t REG_DWORD /d 0 /f
reg unload HKLM\SOFT

goto :end

rem -----------------------------------------------------

:end

echo 完了しました。Enterを押すと再起動します。
pause
wpeutil reboot