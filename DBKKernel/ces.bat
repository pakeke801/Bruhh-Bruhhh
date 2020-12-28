@echo off
command /C echo changing to dos-16 file structure
set C_DEFINES=
set LINKER_FLAGS=/INTEGRITYCHECK

set copycmd=/Y
copy sources.cesigned sources

build -cZ
if %ERRORLEVEL%==0 goto success
goto error

:success
	if "%AMD64%"=="1" goto x86success

	copy .\obj%BUILD_ALT_DIR%\i386\dbk.sys "..\Bruhh Bruhhh\bin\dbk32.sys"
        copy .\obj%BUILD_ALT_DIR%\i386\dbk.sys .\obj%BUILD_ALT_DIR%\i386\dbk32.sys
        copy .\obj%BUILD_ALT_DIR%\i386\dbk.pdb .\obj%BUILD_ALT_DIR%\i386\dbk32.pdb
        "c:\Program Files (x86)\Windows Kits\8.1\bin\x64\signtool.exe" sign /a /sha1 B43612984DA774647384FC539EF17C41305F92E2 /ac "..\bruhh bruhhh\release\sig\GlobalSign Root CA.crt" /t http://timestamp.globalsign.com/scripts/timstamp.dll "..\Bruhh Bruhhh\bin\dbk32.sys"
	"c:\Program Files (x86)\Windows Kits\8.1\bin\x64\signtool.exe" sign /a /sha1 A9F93214813B99645897CA59E4E83EBA4F65818B /ac "..\bruhh bruhhh\release\sig\GlobalSign Root CA.crt" /tr http://timestamp.globalsign.com/?signature=sha2 /td SHA256 /fd SHA256 /as "..\Bruhh Bruhhh\bin\dbk32.sys



	goto successend

:x86success:
	copy .\obj%BUILD_ALT_DIR%\amd64\dbk.sys "..\Bruhh Bruhhh\bin\bru64.sys"
        copy .\obj%BUILD_ALT_DIR%\amd64\dbk.sys .\obj%BUILD_ALT_DIR%\amd64\bru64.sys
        copy .\obj%BUILD_ALT_DIR%\amd64\dbk.pdb .\obj%BUILD_ALT_DIR%\amd64\bru64.pdb
        "c:\Program Files (x86)\Windows Kits\8.1\bin\x64\signtool.exe" sign /a  /ac "..\bruhh bruhhh\release\sig\GlobalSign Root CA.crt" /t http://timestamp.globalsign.com/scripts/timstamp.dll "..\Bruhh Bruhhh\bin\bru64.sys"
	"c:\Program Files (x86)\Windows Kits\8.1\bin\x64\signtool.exe" sign /a /ac "..\bruhh bruhhh\release\sig\GlobalSign Root CA.crt" /tr http://timestamp.globalsign.com/?signature=sha2 /td SHA256 /fd SHA256 /as "..\Bruhh Bruhhh\bin\bru64.sys


	siggen\siggen.exe "..\Bruhh Bruhhh\bin\bruhhbruhhh-i386.exe"
	siggen\siggen.exe "..\Bruhh Bruhhh\bin\bruhhbruhhh-x86_64.exe"
	siggen\siggen.exe "..\Bruhh Bruhhh\bin\vmdisk.img"


	goto successend




:error
echo.
echo error. Check the compile log
goto exit

:successend
echo.
echo done
if "%AMD64%"=="1" echo Please verify the file is signed




:exit