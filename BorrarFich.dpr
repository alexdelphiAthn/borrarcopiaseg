program BorrarFich;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  IniFiles,
  System.DateUtils,
  system.classes,
  inLibWin in 'inLibWin.pas',
  inLibFileManager in 'inLibFileManager.pas',
  inLibDir in 'inLibDir.pas',
  inLibLog in 'inLibLog.pas';

procedure DeleteOldFiles(const IniFilePath: string);
var
//  IniFile: TIniFile;
  Folders: string;
  Days, Months, Years, MinFich: Integer;
  CutOffDate: TDateTime;
  Fileman:TFileManager;
  bSimular:Boolean;
  i:Integer;
begin
  bSimular := False;
  Folders := leCadINIDir('Settings', 'Folders', '', IniFilePath);
  Days := STrToIntDef(leCadINIDir('Settings', 'Days', '0',IniFilePath), 0);
  Months := STrToIntDef(leCadINIDir('Settings', 'Months', '0',IniFilePath), 0);
  Years := STrToIntDef(leCadINIDir('Settings', 'Years', '0', IniFilePath), 0);
  MinFich := STrToIntDef(
                    leCadINIDir('Settings', 'MinFiles', '0', IniFilePath), 10);
  bSimular := StrToBool(leCadINIDir('Settings',
                                    'Simulate',
                                    'True',
                                    IniFilePath));
  for i := 1 to ParamCount do
  begin
    if UpperCase(ParamStr(i)) = UpperCase('/simulate') then
      bSimular := True
    else if UpperCase(ParamStr(i)) = UpperCase('/verboselog') then
      Log.VerboseModeOn
    else if UpperCase(ParamStr(i)) = UpperCase('/Folders') then
      Folders := ParamStr(i + 1)
    else if UpperCase(ParamStr(i)) = UpperCase('/days') then
      Days := STrToIntDef((ParamStr(i + 1)), 0)
    else if UpperCase(ParamStr(i)) = UpperCase('/months') then
      Months := StrToIntDef(ParamStr(i + 1), 0)
    else if UpperCase(ParamStr(i)) = UpperCase('/years') then
      Years := StrToIntDef(ParamStr(i + 1), 0)
    else if UpperCase(ParamStr(i)) = UpperCase('/minfich') then
      MinFich := StrToInt(ParamStr(i + 1));
  end;
  CutOffDate := IncMonth(Now, Months*-1);
  CutOffDate := IncDay(CutOffDate, Days*-1);
  CutOffDate := IncYear(CutOffDate, Years*-1);
  Log.LogInfo('La fecha mínima a conservar es: ' +
                              FormatDateTime('dd/mm/yyyy hh:nn:ss', CutoffDate));
  Log.LogInfo('Las fechas más antiguas serán eliminadas');
  Log.LogInfo('El número mínimo de ficheros antiguos a conservar es de ' +
              IntToStr(MinFich));
  Fileman := TFileManager.Create(Folders, MinFich, CutOffDate, bSimular);
  Fileman.ProcessCandidates;
  Fileman.DeleteFiles;
end;

begin
  try
    try
      DeleteOldFiles(GetUserFolder + '\config.ini');
    except
      on E: Exception do
      begin
        Log.LogError('ERROR CRÍTICO: ' + E.ClassName + ' - ' + E.Message);
        // NO usar WriteLn ni ReadLn aquí
      end;
    end;
  finally
    // Asegurarse de que el log se cierra correctamente
    if Assigned(Log) then
      Log.LogInfo('Programa finalizado');
  end;

  // Si es una aplicación de consola y quieres ver el resultado:
  // Writeln('Presione Enter para salir...');
  // Readln;
end.

