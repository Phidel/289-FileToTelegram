@echo off
set /p vers=<"BuildNo.inc"
set exename=FileToTelegram
set release=1.0
set arc=%exename%_%vers%.rar
"C:\Program Files\WinRAR\WinRAR.exe" a "%arc%" %exename%.exe
rem TelegramHelper.exe *.dll data.abs

cd %exename%
gh release upload %release% ..\%arc% --clobber
cd ..

move %arc% for-client\ > nul

rem ��������� ��������� � ����� ������
nircmd.exe clipboard set "https://github.com/Phidel/%exename%/releases/download/%release%/%arc%"
echo ok - https://github.com/Phidel/%exename%/releases/download/%release%/%arc%