@echo off
set /p vers=<"BuildNo.inc"
set basename=FileToTelegram
set release=1.0
set arc=%basename%_%vers%.rar
set ProjectNo=289
set reponame=%ProjectNo%-%basename%
set url=https://github.com/Phidel/%reponame%/releases/download/%release%/%arc%

echo %reponame%, release %release%
echo %arc%

"C:\Program Files\WinRAR\WinRAR.exe" a "%arc%" %basename%.exe
rem TelegramHelper.exe *.dll data.abs

gh release upload %release% %arc% --clobber

move %arc% for-client\ > nul

rem поместить ссылку на скачивание в буфер обмена
nircmd.exe clipboard set "%url%"
echo %url%