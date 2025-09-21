unit inLibWin;

interface

uses
   Classes,
   Windows,

   sysutils, //jpeg,
   System.StrUtils,
   System.IniFiles,
   System.Win.Registry,
   Winapi.Messages,
   System.IOUtils;

  function GetComputerName: string;
  function GetProgramPath: string;
  function GetWindowsUserName: string;
  function GetWindowsVersion: string;
  function leCadINIDir (clave, cadena : string;
                        defecto : string;
                        sPath:string) : string;
procedure esCadINIDir (clave, cadena, valor, sPath : string);
implementation


procedure esCadINIDir (clave, cadena, valor, sPath : string);
begin
  with tinifile.create (sPath) do
  try
    writeString (clave, cadena, valor);
  finally
    free;
  end;
end;

function leCadINIDir (clave,
                      cadena,
                      defecto,
                      sPath:string) : string;
begin
  with tinifile.create (sPath) do
  try
    result := readString (clave, cadena, defecto);
    if result = defecto then
      esCadINIDir(clave, cadena, defecto, sPath);
  finally
    free;
  end;
end;

function GetComputerName: string;
var
  Buffer: array[0..MAX_COMPUTERNAME_LENGTH] of Char;
  Size: DWORD;
begin
  Size := MAX_COMPUTERNAME_LENGTH + 1;
  if Winapi.Windows.GetComputerName(Buffer, Size) then
    Result := Buffer
  else
    Result := 'Unknown';
end;

function GetWindowsUserName: string;
var
  Buffer: array[0..255] of Char;
  Size: DWORD;
begin
  Size := 256;
  if Winapi.Windows.GetUserName(Buffer, Size) then
    Result := Buffer
  else
    Result := 'Unknown';
end;

function GetProgramPath: string;
begin
  Result := ExtractFilePath(ParamStr(0));
end;

function GetWindowsVersion: string;
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create(KEY_READ);
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKey('SOFTWARE\Microsoft\Windows NT\CurrentVersion', False) then
    begin
      Result := Reg.ReadString('ProductName');
      if Reg.ValueExists('DisplayVersion') then
        Result := Result + ' ' + Reg.ReadString('DisplayVersion')
      else if Reg.ValueExists('ReleaseId') then
        Result := Result + ' ' + Reg.ReadString('ReleaseId');
    end
    else
      Result := 'Unknown';
  finally
    Reg.Free;
  end;
end;


//function sMD5(const texto:string):string;
//var
//  idmd5 : TIdHashMessageDigest5;
//begin
//  idmd5 := TIdHashMessageDigest5.Create;
//  try
//    Result := idmd5.HashStringAsHex(String(UTF8Encode(texto)));
//  finally
//    idmd5.Free;
//  end;
//end;

//procedure ExecuteAndWait(const aCommando: string);
//var
//  tmpStartupInfo: TStartupInfo;
//  tmpProcessInformation: TProcessInformation;
//  tmpProgram: String;
//begin
//  tmpProgram := trim(aCommando);
//  FillChar(tmpStartupInfo, SizeOf(tmpStartupInfo), 0);
//  with tmpStartupInfo do
//  begin
//    cb := SizeOf(TStartupInfo);
//    wShowWindow := SW_HIDE;
//  end;
//  if CreateProcess(nil, pchar(tmpProgram), nil, nil, true, CREATE_NO_WINDOW,
//    nil, nil, tmpStartupInfo, tmpProcessInformation) then
//  begin
//    // loop every 10 ms
//    while WaitForSingleObject(tmpProcessInformation.hProcess, 10) > 0 do
//    begin
//      Application.ProcessMessages;
//    end;
//    CloseHandle(tmpProcessInformation.hProcess);
//    CloseHandle(tmpProcessInformation.hThread);
//  end
//  else
//  begin
//    RaiseLastOSError;
//  end;
//end;

function GetVolumeID(DriveChar: Char): String;
var
   MaxFileNameLength, VolFlags, SerNum: DWord;
begin
   if GetVolumeInformation(PChar(DriveChar + ':\'), nil, 0,
      @SerNum, MaxFileNameLength, VolFlags, nil, 0)
   then
   begin
     Result := IntToHex(SerNum,8);
     Insert('-', Result, 5);
   end
   else
       Result := '';
end;

end.

