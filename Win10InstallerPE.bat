@echo off
:Ver
cls
echo ********************************************
echo *Windows 10 1803 Winpe-tch�p Windows�C���X�g�[���[ for BIOS*
echo ********************************************
echo Ver.1.0
echo.
echo.

rem -----------------------------------------------------

:Start
echo.
color C
set Start=
set /P Start="���̃C���X�g�[���[�͑��Ȏd�l�ł��B�����N�����Ă����ȐӔC�Ŏg�p���Ă��������B���ӂ��܂����H (Y/N)"
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
SET /P sysdrv="��L���m�F���A�C���X�g�[���Ώۃf�B�X�N�� ���p ���� 1���� �œ��͂��Ă������� (��: 1 )"
if "%sysdrv%" == "" (
  goto :sysdrvcheck
)

goto :syschrcheck

rem -----------------------------------------------------

:syschrcheck
echo lis vol | diskpart
echo.
set syschr=
SET /P syschr="��L���m�F���A��L�ɑ��݂��Ȃ��C�ӂ̃h���C�u���^�[�� �啶�� ���p �p�� 1���� �œ��͂��Ă������� (��: C )"
if "%syschr%" == "" (
  goto :syschrcheck
)

goto :deletecheck

rem -----------------------------------------------------

:deletecheck
echo.
set delete=
SET /P delete="�f�B�X�N%sysdrv%�͊��S�ɍ폜����܂��B���̑���͂��Ƃɖ߂��܂���B�폜�����s���܂����H (Y/N)"
if "%delete%" == "" (
  goto :deletecheck
)
if /i {%delete%}=={yes} (goto :delete)
if /i {%delete%}=={y} (goto :delete)

echo Y�ȊO�����͂���܂����B�J�n�m�F�ɖ߂�܂�...
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
SET /P wimpath="USB�������ɂ���install.wim�̏ꏊ���t���p�X�Ŏw�肵�Ă��������B (��: D:\install.wim )"
if "%wimpath%" == "" (
  goto :wimpath
)

goto :install

rem -----------------------------------------------------

:install
echo.
echo �C���X�g�[�����J�n���܂�...
dism /apply-image /imagefile:%wimpath% /index:1 /applydir:%syschr%:\
bootrec /fixmbr
bootrec /fixboot
bootrec /scanos
bootrec /rebuildbcd

goto :regedit

rem -----------------------------------------------------

:regedit
echo.

reg load HKLM\SOFT %syschr%:\Windows\System32\config\SOFTWARE
reg add HKLM\SOFT\Microsoft\Windows\CurrentVersion\Policies\System /v VerboseStatus /t REG_DWORD /d 1
reg add HKLM\SOFT\Microsoft\Windows\CurrentVersion\Policies\System /v EnableCursorSuppression /t REG_DWORD /d 0
reg unload HKLM\SOFT

goto :end

rem -----------------------------------------------------

:end

echo �������܂����BEnter�������ƍċN�����܂��B
timeout 10
wpeutil reboot