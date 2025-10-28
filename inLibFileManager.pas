unit inLibFileManager;

interface

uses
  inLibLog,
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  System.DateUtils,
  System.Types,
  System.Generics.Collections,
  System.Generics.Defaults;

type
  TFileInformation = record
    FileName: string;
    CreationTime: TDateTime;
    delCan:Boolean;
  end;

  TFolderInformation = class
    FolderPath:string;
    MinF:Integer;
    CountF:Integer;
    CountDel:Integer;
    //FDList:TList<string>;
    LowDT:TDateTime;
    HighDT:TDateTime;
    dFechMin:TDateTime;
    FileList:TList<TFileInformation>;
    constructor Create(sFolder:String; aiMin:Integer; adFechMin:TDateTime);
    destructor Destroy; override;
    procedure GetFilesSortedByCreation(ADirectory:String);
  end;

  TComparerPorFecha = class(TInterfacedObject, IComparer<TFileInformation>)
  public
    function Compare(const Left, Right:TFileInformation):Integer;
  end;

  TFileManager = class
  private
    FFolderList:TList<TFolderInformation>;
    FDeleteList:TList<string>;
    Simular:Boolean;
  public
    constructor Create(const ADirectory: string;
                       const aiMin:Integer;
                       const adFechMin:TDateTime;
                       const aSimular:Boolean);
    destructor Destroy; override;
    function DelFile(const AFileName:String): Boolean;
    procedure ProcessCandidates;
    procedure DeleteFiles;
  end;

implementation

constructor TFileManager.Create(const ADirectory: string;
                                const aiMin:Integer;
                                const adFechMin:TDateTime;
                                const aSimular:boolean);
var
  lTempFolder:TArray<String>;
  sFolder:string;
  fFolder:TFolderInformation;
  i:Integer;
begin
  Simular:= aSimular;
    // *** DEPURACIÓN: Ver qué llega ***
  Log.LogInfo('=== DEPURACIÓN TFileManager.Create ===');
  Log.LogInfo('ADirectory recibido: [' + ADirectory + ']');
  Log.LogInfo('Longitud de ADirectory: ' + IntToStr(Length(ADirectory)));

  lTempFolder := ADirectory.Split([';']);

  // *** DEPURACIÓN: Ver el resultado del Split ***
  Log.LogInfo('Número de elementos después del Split: ' + IntToStr(Length(lTempFolder)));
  for i := 0 to High(lTempFolder) do
    Log.LogInfo('Elemento[' + IntToStr(i) + ']: [' + lTempFolder[i] + ']');
//  lTempFolder := ADirectory.Split([';']);
  FFolderList := TList<TFolderInformation>.Create;
  for sFolder in lTempFolder do
  begin
    if not TDirectory.Exists(sFolder) then
      Log.LogError('El directorio no existe: ' + sFolder)
    else
    begin
      fFolder := TFolderInformation.Create(sFolder, aiMin, adFechMin);
      FFolderList.Add(fFolder);
    end;
  end;
  //FDirectory := ADirectory;
end;

function TFileManager.DelFile(const AFileName:String): Boolean;
var
  FilePath: string;
begin
  Result := False;
  FilePath := AFileName;
  try
    if TFile.Exists(FilePath) then
    begin
      try
        TFile.Delete(FilePath);
        Log.LogInfo('Se ha borrado ' + FilePath);
        Result := True;
      except
        on E: Exception do
        begin
          Log.LogError('Error al borrar el fichero [' + FilePath + ']: ' + E.Message);
          Result := False;
        end;
      end;
    end
    else
    begin
      Log.LogError('El fichero a borrar no existe: '+ FilePath);
      Result := False;
    end;
  except
    on E: Exception do
    begin
      Log.LogError('Excepción inesperada en DelFile [' + FilePath + ']: ' + E.Message);
      Result := False;
    end;
  end;
end;

destructor TFileManager.Destroy;
var
  fFolder: TFolderInformation;
begin
  // Liberar todos los objetos TFolderInformation de la lista
  if Assigned(FFolderList) then
  begin
    for fFolder in FFolderList do
      fFolder.Free;
    FFolderList.Free;
  end;
  // Liberar la lista de archivos a borrar
  if Assigned(FDeleteList) then
    FDeleteList.Free;
  inherited;
end;

procedure TFileManager.DeleteFiles;
var
  sFile: string;
  iDeleted, iFailed: Integer;
begin
  iDeleted := 0;
  iFailed := 0;
  if (FDeleteList <> nil) and (FDeleteList.Count > 0) then
  begin
    Log.LogInfo('Iniciando borrado de ' + IntToStr(FDeleteList.Count) + ' ficheros...');

    for sFile in FDeleteList do
    begin
      try
        if (Simular) then
        begin
          Log.LogInfo('MODO SIMULACIÓN: Se borraría el fichero: ' + sFile);
          Inc(iDeleted);
        end
        else
        begin
          if DelFile(sFile) then
            Inc(iDeleted)
          else
            Inc(iFailed);
        end;
      except
        on E: Exception do
        begin
          Log.LogError('Excepción al procesar fichero [' + sFile + ']: ' + E.Message);
          Inc(iFailed);
        end;
      end;
    end;
    Log.LogInfo('Proceso completado. Borrados: ' + IntToStr(iDeleted) +
                ', Fallidos: ' + IntToStr(iFailed));
  end
  else
    Log.LogInfo('No hay candidatos a borrar');
end;

procedure TFileManager.ProcessCandidates;
var
  fFolder:TFolderInformation;
  bDelete:Boolean;
  iFilesDel:Integer;
  fFile:TFileInformation;
begin
  for fFolder in FFolderList do
  begin
    if (FDeleteList = nil) then
      FDeleteList := TList<string>.Create;
    bDelete := False;
    Log.LogInfo('Carpeta: ' + fFolder.FolderPath );
    if (fFolder.CountDel = 0) then
    Log.LogWarning('La carpeta ' +
                   ' no tiene ficheros que cumplan fecha para borrar')
    else
      begin
        Log.LogInfo('Hay ' + IntToStr(fFolder.CountDel) +
                    ' ficheros que cumplen la fecha mínima para borrar.');
        If (fFolder.CountDel < fFolder.MinF) then
          Log.LogWarning('El número de ficheros a borrar es inferior al ' +
                    'número de mínimo de ficheros antiguos a conservar.' +
                    ' La carpeta no se procesará.')
        else
        begin
           Log.LogInfo('Hay ' + IntToStr(fFolder.CountDel - fFolder.MinF)  +
                    ' ficheros candidatos efectivos para borrar.');
          bDelete := True;
        end;
      end;
    if bDelete then
    begin
      iFilesDel := fFolder.CountDel - fFolder.MinF;
      for fFile in fFolder.FileList do
      begin
        if (iFilesDel > 0) then
        begin
          if (fFile.delCan = True) then
          begin
            FDeleteList.Add(fFolder.FolderPath +'\'+ fFile.FileName);
            iFilesDel := iFilesDel - 1;
            log.LogWarning(fFolder.FolderPath +'\' + fFile.FileName + ' se borrará' +
                           ' Fecha Modificación: ' +
                           DateTimeToStr(fFile.CreationTime) );
          end;
        end
        else
          Break;
      end;
    end;
  end;
end;

destructor TFolderInformation.Destroy;
begin
  if Assigned(FileList) then
    FileList.Free;
  inherited;
end;

procedure TFolderInformation.GetFilesSortedByCreation(ADirectory:String);
var
  aFiles: TArray<string>;
  FileInfo: TFileInformation;
  FileDetailList: TList<TFileInformation>;
  FileCreationTime: TDateTime;
  Comparer : TComparerPorFecha;
  sFileName:string;
  iCount:Integer;
begin
  iCount:= 0;
  aFiles := TDirectory.GetFiles(ADirectory);
  FileDetailList := TList<TFileInformation>.Create;
  Comparer := TComparerPorFecha.Create;
  try
    for sFileName in aFiles do
    begin
      Inc(iCount);
      FileCreationTime := TFile.GetLastWriteTime(sFileName);
      FileInfo.FileName := TPath.GetFileName(sFileName);
      FileInfo.CreationTime := FileCreationTime;
      if CompareDateTime(dFechMin, FileCreationTime) = GreaterThanValue  then
      begin
        FileInfo.delCan := True;
        //FDList.Add(sFileName);
        Inc(CountDel);
      end
      else
        FileInfo.delCan := False;
      if CompareDateTime(LowDt, FileCreationTime) = GreaterThanValue  then
        LowDT := FileCreationTime;
      if CompareDateTime(HighDT, FileCreationTime) = LessThanValue  then
        HighDT := FileCreationTime;
      FileDetailList.Add(FileInfo);
    end;
    // Ordenar por fecha de creación
    FileDetailList.Sort(Comparer);
    FileList := FileDetailList;
    CountF := iCount;
    //Result := FileDetailList.ToArray;
  finally
    //FileDetailList.Free;
  end;
end;

{ TComparerPorFecha }

function TComparerPorFecha.Compare(const Left,
  Right: TFileInformation): Integer;
begin
  Result := CompareDateTime(Left.CreationTime, Right.CreationTime);
end;

{ TFolderInformation }

constructor TFolderInformation.Create(sFolder: String;
                                      aiMin:Integer;
                                      adFechMin:TDateTime);
begin
    FolderPath := sFolder;
    MinF       := aiMin;
    dFechMin   := adFechMin;
    CountF     := 0;
    CountDel   := 0;
    LowDT      := MaxDateTime;
    HighDT     := MinDateTime;
    //FDList     := TList<string>.Create;
    GetFilesSortedByCreation(FolderPath);
end;

end.

