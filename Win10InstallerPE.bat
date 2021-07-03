@echo off
:Ver
cls
echo ********************************************
echo *Windows 10 1803 PE用 Windowsインストーラー*
echo ********************************************
echo Ver.1.0
echo.
echo.

rem -----------------------------------------------------

:Start
echo.
color C
set Start=
set /P Start="このインストーラーは即席仕様のゴミです。何が起こっても自己責任で使用してください。同意しますか？ (Y/N)"
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
SET /P syschr="上記を確認し、上記に存在しない任意のドライブレターを 大文字 半角 英字 1文字 で入力してください (例: C )"
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
echo convert mbr >> temp.txt
echo create partition primary >> temp.txt
echo format fs=ntfs quick >> temp.txt
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

goto :install

rem -----------------------------------------------------

:install
echo.
echo インストールを開始します...
dism /apply-image /imagefile:%wimpath% /index:1 /applydir:%syschr%:\
bootrec /fixmbr
bootrec /fixboot
bootrec /scanos
bootrec /rebuildbcd

goto :regedit

rem -----------------------------------------------------

:regedit
echo.
color C
echo ここからは手動です。指示に従って操作してください。
echo.
color
start regedit
echo HKEY_LOCAL_MACHINEを選択してください
echo.
rem pause 
echo ファイル(F)→ハイブの読み込み から C:\Windows\System32\config\SOFTWARE を読み込んでください。名前はSOFT
echo.
rem pause
rem echo ファイル(F)→ハイブの読み込み から C:\Windows\System32\config\SYSTEM を読み込んでください。名前はSYS
rem pause
echo HKEY_LOCAL_MACHINE\SOFT\Microsoft\Windows\CurrentVersion\Policies\System に移動してください
echo.
rem pause
echo 右クリック→新規→DWORD(32ビット)値 名前を VerboseStatus 値を 1
echo.
rem pause
echo EnableCursorSuppression の値を 0
echo.
rem echo ===================================================
rem echo.
rem echo ファイル(F)→ハイブの読み込み から C:\Windows\System32\config\SYSTEM を読み込んでください。名前はSYS
rem echo.
rem echo HKEY_LOCAL_MACHINE\SYS\Setup に移動してください
rem echo.
rem echo CmdLine の値を cmd.exe
pause

goto :end

rem -----------------------------------------------------

:end

echo 完了しました。Enterを押すと再起動します。
pause
wpeutil reboot