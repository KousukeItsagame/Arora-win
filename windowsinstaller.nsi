; Copyright 2008 Jason A. Donenfeld <Jason@zx2c4.com>
; Edited By Kousuke March 2011

; For fulfilling the dependencies of arora you need ieshims.dll
; This file changed directory since internet explorer 8
; The new directory is \program files\internet explorer\
; In this script I added the directory to the path so this file can be accessed
; Firefox needs this dll as well
; When adding things to PATH admin privileges are required sadly
; I also fixed a bug when removing shortcut

;prerequisites:
;an already build arora source
;an already build qt source
;an already build openssl
;killproc_dll download http://nsis.sourceforge.net/KillProcDLL_plug-in
;envarupdate.nsh download http://nsis.sourceforge.net/mediawiki/images/a/ad/EnvVarUpdate.7z
;the correct msvc redistributable according the compiler you used
;the redistributable file can be downloaded from microsoft website)
;check if paths to files are correct
;renaming installer to the version you use

;changelog:
;release unofficial windowsinstaller2.nsi
;add ieshims.dll to path
;add admin rights for windows vista/7
;renamed needed programs to latest version
;using MUI2 for better look installer

SetCompressor /SOLID /FINAL lzma

!define PRODUCT_NAME "Arora"
!define /date PRODUCT_VERSION "0.11.0"
;!define /date PRODUCT_VERSION "Snapshot (%#m-%#d-%#Y)"
!define PRODUCT_DIR_REGKEY "Software\Microsoft\Windows\CurrentVersion\App Paths\arora.exe"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"
!define QTDIR "C:\Qt471\"

!include "MUI2.nsh"
!define MUI_ABORTWARNING
!define MUI_ICON ".\src\browser.ico"
!define MUI_UNICON ".\src\browser.ico"

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!define MUI_FINISHPAGE_RUN "$INSTDIR\arora.exe"
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

!insertmacro MUI_LANGUAGE "English"
Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
OutFile "${PRODUCT_NAME} ${PRODUCT_VERSION} Installer.exe"
InstallDir "$PROGRAMFILES\${PRODUCT_NAME}"
InstallDirRegKey HKLM "${PRODUCT_DIR_REGKEY}" ""
ShowInstDetails show
ShowUnInstDetails show

;Needed for windows vista and 7
;http://nsis.sourceforge.net/Shortcuts_removal_fails_on_Windows_Vista

;install files as admin
RequestExecutionLevel admin

;path manipulation headers
!include "LogicLib.nsh"
!include "EnvVarUpdate.nsh" 

Section "Add to Path"
	 ${EnvVarUpdate} $0 "PATH" "A" "HKLM" "%PROGRAMFILES%\Internet Explorer"
SectionEnd

Section "Main Components"
  KillProcDLL::KillProc "arora.exe"
  Sleep 100
  SetOverwrite on

  SetOutPath "$INSTDIR"
  File "arora.exe"
  File "tools\htmlToXbel\release\htmlToXBel.exe"
  File "tools\cacheinfo\release\arora-cacheinfo.exe"
  File "tools\placesimport\release\arora-placesimport.exe"
  File "${QTDIR}\lib\QtCore4.dll"
  File "${QTDIR}\lib\QtGui4.dll"
  File "${QTDIR}\lib\QtNetwork4.dll"
  File "${QTDIR}\lib\QtWebKit4.dll"
  File "${QTDIR}\lib\QtScript4.dll"
  File "${QTDIR}\lib\QtSql4.dll"
  ;File "${QTDIR}\lib\phonon4.dll"
  File "C:\arorasdk\openssl-1.0.0c\out32dll\ssleay32.dll"
  File "C:\arorasdk\openssl-1.0.0c\out32dll\libeay32.dll"

  SetOutPath "$INSTDIR\locale"
  File "src\.qm\locale\*.qm"
  File "${QTDIR}\translations\qt*.qm"

  SetOutPath "$INSTDIR\sqldrivers"
  File "${QTDIR}\plugins\sqldrivers\qsqlite4.dll"

  SetOutPath "$INSTDIR\imageformats"
  File "${QTDIR}\plugins\imageformats\qtiff4.dll"
  File "${QTDIR}\plugins\imageformats\qsvg4.dll"
  File "${QTDIR}\plugins\imageformats\qmng4.dll"
  File "${QTDIR}\plugins\imageformats\qjpeg4.dll"
  File "${QTDIR}\plugins\imageformats\qico4.dll"
  File "${QTDIR}\plugins\imageformats\qgif4.dll"

  SetOutPath "$INSTDIR\iconengines"
  File "${QTDIR}\plugins\iconengines\qsvgicon4.dll"

  SetOutPath "$INSTDIR\codecs"
  File "${QTDIR}\plugins\codecs\qtwcodecs4.dll"
  File "${QTDIR}\plugins\codecs\qkrcodecs4.dll"
  File "${QTDIR}\plugins\codecs\qjpcodecs4.dll"
  File "${QTDIR}\plugins\codecs\qcncodecs4.dll"

  SetOutPath "$INSTDIR\phonon_backend"
  File "${QTDIR}\plugins\phonon_backend\phonon_ds94.dll"
SectionEnd

Section Icons
  ;Needed when using admin rights vista/7
  SetShellVarContext all
  CreateShortCut "$SMPROGRAMS\Arora.lnk" "$INSTDIR\arora.exe"
SectionEnd

Section Uninstaller
  WriteUninstaller "$INSTDIR\uninst.exe"
  WriteRegStr HKLM "${PRODUCT_DIR_REGKEY}" "" "$INSTDIR\arora.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayName" "$(^Name)"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "UninstallString" "$INSTDIR\uninst.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayIcon" "$INSTDIR\arora.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
SectionEnd

Section MSVC
  InitPluginsDir
  SetOutPath $PLUGINSDIR

  File "C:\msvc\vcredist2010\vcredist_x86.exe"
  DetailPrint "Installing Visual C++ 2010 Libraries"
  ExecWait '"$PLUGINSDIR\vcredist_x86.exe" /q:a /c:"msiexec /i vcredist.msi /quiet"'
SectionEnd

Section Uninstall
  KillProcDLL::KillProc "arora.exe"
  Sleep 100
  ;needed when using admin rights vista/7
  SetShellVarContext all
  Delete "$SMPROGRAMS\Arora.lnk"
  ${Un.EnvVarUpdate} $0 "PATH" "R" "HKLM" "%PROGRAMFILES%\Internet Explorer"
  Delete "$INSTDIR\Uninst.exe"
  RMDir /r "$INSTDIR"
  DeleteRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}"
  DeleteRegKey HKLM "${PRODUCT_DIR_REGKEY}"
   
SectionEnd

BrandingText "arora-browser.org"
