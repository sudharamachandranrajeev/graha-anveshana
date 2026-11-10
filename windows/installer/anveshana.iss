; Graha Anveshana for Windows: Inno Setup script. The release workflow builds the app
; (flutter build windows) and compiles this with
;   iscc /DAppVersion=0.1.0 windows\installer\anveshana.iss
; Installs for the current user by default (no admin prompt). Uninstalling
; leaves the encrypted data in %APPDATA%\Anveshana alone.

#ifndef AppVersion
  #define AppVersion "0.0.0"
#endif
#define Release "..\..\build\windows\x64\runner\Release"

[Setup]
; Graha Anveshana's own id. Up to 0.12.0 it wrongly shared Bhojana's
; ({55825A17-...}), so Windows treated the apps as one; see [Code] below.
AppId={{F96051B1-6F25-4804-B685-5FC768E030C1}
AppName=Graha Anveshana
AppVersion={#AppVersion}
AppVerName=Graha Anveshana {#AppVersion}
AppPublisher=Rajeev Sudharamachandran
DefaultDirName={autopf}\Anveshana
DefaultGroupName=Graha Anveshana
DisableProgramGroupPage=yes
OutputDir=..\..\build\installer
OutputBaseFilename=Graha-Anveshana-{#AppVersion}-windows-x64-setup
SetupIconFile=..\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\anveshana.exe
UninstallDisplayName=Graha Anveshana
Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
CloseApplications=yes
; Windows 10 1809 or later (and Windows 11)
MinVersion=10.0.17763

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "{#Release}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\Graha Anveshana"; Filename: "{app}\anveshana.exe"; Comment: "Homes: renting, buying and lettings"
Name: "{autodesktop}\Graha Anveshana"; Filename: "{app}\anveshana.exe"; Tasks: desktopicon

[InstallDelete]
; Shortcuts from 0.12.0 and before, named "Anveshana" and pointing into the
; shared folder.
Type: files; Name: "{userprograms}\Anveshana.lnk"
Type: files; Name: "{userdesktop}\Anveshana.lnk"
Type: files; Name: "{commonprograms}\Anveshana.lnk"
Type: files; Name: "{commondesktop}\Anveshana.lnk"

[Code]
const
  OldKey = 'Software\Microsoft\Windows\CurrentVersion\Uninstall\{55825A17-B296-4ED6-A66E-84FB1F5A100C}_is1';

{ 0.12.0 and before installed under the id shared with Bhojana, Udyoga and
  Vidya, often into another app's folder. Remove only what is Graha
  Anveshana's: its old exe, and the old uninstall entry when it still names
  this app (its uninstaller would delete the whole shared folder). Other
  apps' files are left alone. }
procedure RemoveOld(Root: Integer);
var
  Name, Dir: String;
begin
  if RegQueryStringValue(Root, OldKey, 'DisplayName', Name) and (Name = 'Graha Anveshana') then
  begin
    if RegQueryStringValue(Root, OldKey, 'InstallLocation', Dir) then
      DeleteFile(AddBackslash(Dir) + 'anveshana.exe');
    RegDeleteKeyIncludingSubkeys(Root, OldKey);
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssInstall then
  begin
    RemoveOld(HKCU);
    if IsAdminInstallMode then RemoveOld(HKLM);
  end;
end;

[Run]
Filename: "{app}\anveshana.exe"; Description: "{cm:LaunchProgram,Graha Anveshana}"; Flags: nowait postinstall skipifsilent
