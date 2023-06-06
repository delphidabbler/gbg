unit GBG.Main;

interface

uses
  System.SysUtils,
  GBG.Params;

type

  TExitCode = record
  public
    const
      None = 0;
      Execuction = 1;
      Usage = 2;
      Cancellation = 3;
      Unknown = 9;
  end;

  TMain = class
  strict private
    const
      TwoPower10 = UInt64(1_024);
      OneThousand = UInt64(1_000);
      kB = OneThousand;
      MB = OneThousand * kB;
      KiB = TwoPower10;
      MiB = TwoPower10 * KiB;
      GiB = TwoPower10 * MiB;
      BufSize = 10 * MiB;
      MaxUnchallengedFileSize = 500 * MB;   // 500,000,000 bytes
      MaxSupportedFileSize = 20 * GiB;      // 21,474,836,480 bytes
    class var
      fParams: TParams;
    class procedure FillBufferWithGarbage(var Bytes: TBytes);
    class procedure CreateBuffer(out Buffer: TBytes);
    class function GetConfirmation(const Question: string;
      const TrueResponse: Char): Boolean;
    class procedure CheckUserPermissions;
    class procedure HandleProgramException(const E: Exception);
    class procedure HandleExecutionException(const E: Exception);
    class function FreeSpaceOnFileDrive: UInt64;
    class procedure Usage;
    class procedure Version;
    class procedure Initialise;
    class procedure Execute;
  public
    class procedure Run;
    class destructor Destroy;
  end;

implementation

uses
  System.IOUtils,
  System.Classes,
  System.Math,
  System.Character,
  GBG.AppInfo,
  GBG.Exceptions,
  GBG.Generator.Base,
  GBG.Generator.BinaryGarbage,
  GBG.NumberFmt;

{ TMain }

class procedure TMain.CheckUserPermissions;
begin
  if fParams.FileSize > MaxUnchallengedFileSize  then
  begin
    if not GetConfirmation(
      Format(
        'Requested size is greater than %s bytes. Continue? [y/N]',
        [TNumberFmt.Create(MaxUnchallengedFileSize).ToString]
      ),
      'Y'
    ) then
      raise ECancellation.Create('Operation cancelled');
  end;
  if TFile.Exists(fParams.FileName) then
  begin
    if not GetConfirmation('File already exists. Overwrite? [y/N]', 'Y') then
      raise ECancellation.Create('Operation cancelled');
  end;
end;

class procedure TMain.CreateBuffer(out Buffer: TBytes);
begin
  SetLength(Buffer, Min(BufSize, fParams.FileSize));
  if Length(Buffer) > 0 then
    FillBufferWithGarbage(Buffer);
end;

class destructor TMain.Destroy;
begin
  fParams.Free;
end;

class procedure TMain.Execute;
begin
  try
    var FS := TFileStream.Create(fParams.FileName, fmCreate);
    try
      if fParams.FileSize = 0 then
        Exit;

      var Buffer: TBytes;
      CreateBuffer(Buffer);

      var BytesRemaining := fParams.FileSize;
      while BytesRemaining > 0 do
      begin
        var BytesToWrite: UInt64 := Min(BytesRemaining, UInt64(Length(Buffer)));
        FS.WriteBuffer(Pointer(Buffer)^, BytesToWrite);
        Dec(BytesRemaining, BytesToWrite);
      end;

    finally
      FS.Free;
    end;

  except
    on E: Exception do
      HandleExecutionException(E);
  end;
end;

class procedure TMain.FillBufferWithGarbage(var Bytes: TBytes);
begin
  Assert(Length(Bytes) > 0);
  var Generator := TGeneratorFactory.CreateInstance(fParams.GeneratorType);
  try
    Generator.FillBuffer(Bytes);
  finally
    Generator.Free;
  end;
end;

class function TMain.FreeSpaceOnFileDrive: UInt64;
begin
  var FreeAvailable, Total, FreeTotal: Int64;
  var Drive := TDirectory.GetDirectoryRoot(fParams.FileName);
  if not GetDiskFreeSpaceEx(PChar(Drive), FreeAvailable, Total, @FreeTotal) then
    raise EExecutionError.Create('Drive ' + Drive + ' not found');
  Result := UInt64(FreeAvailable)
end;

class function TMain.GetConfirmation(const Question: string;
  const TrueResponse: Char): Boolean;
begin
  Write(Question);
  var Response: Char;
  Readln(Response);
  Result := Response.ToUpper = TrueResponse;
end;

class procedure TMain.HandleExecutionException(const E: Exception);
begin
  try
    if TFile.Exists(fParams.FileName) then
      TFile.Delete(fParams.FileName);
  except
    // swallow exception: not relevant to main program operation
  end;

  ExitCode := 1;
  if E is EFCreateError then
    raise EExecutionError.Create('Can''t create file')
  else if E is EWriteError then
    raise EExecutionError.Create('Failure while writing file')
  else
    raise E;
end;

class procedure TMain.HandleProgramException(const E: Exception);
begin
  ExitCode := TExitCode.None;;
  if E is EUsageError then
  begin
    Writeln('Usage Error: ' + E.Message);
    Usage;
    ExitCode := TExitCode.Usage;
  end
  else if E is ECancellation then
  begin
    Writeln(E.Message);
    ExitCode := TExitCode.Cancellation;
  end
  else if E is EExecutionError then
  begin
    Writeln('Error: ' + E.Message);
    ExitCode := TExitCode.Execuction;
  end
  else if E is ESilent then
  begin
    Usage;
    ExitCode := TExitCode.None;
  end
  else
  begin
    // Unexpected exception: re-raise
    ExitCode := TExitCode.Unknown;
    raise E;
  end;
end;

class procedure TMain.Initialise;
begin

  CheckUserPermissions; // raises exceptions if user denies permissions

  if fParams.FileSize > FreeSpaceOnFileDrive then
    raise EExecutionError.Create(
      'Requested file size is larger than free space on drive '
      + TDirectory.GetDirectoryRoot(fParams.FileName)
    );
end;

class procedure TMain.Run;
begin
  try
    fParams := TParams.Create(MaxSupportedFileSize);
    if fParams.ShowVersion then
      Version
    else
    begin
      Initialise;
      Execute;
    end;
    ExitCode := TExitCode.None;
  except
    on E: Exception do
      HandleProgramException(E);
  end;
end;

class procedure TMain.Usage;
begin
  Writeln('Usage:');
  Writeln;
  Writeln('  gbg filename size [options]');
  Writeln('  gbg -V');
  Writeln('  gbg');
  Writeln;
  Writeln('  Where:');
  Writeln('    filename = name of file to create');
  Writeln(
    Format(
      '    size = size of file to create (0..%s)',
      [TNumberFmt.Create(MaxSupportedFileSize).ToString]
    )
  );
  WriteLn('    options = zero or more of:');
  WriteLn('      -a -> generate printable ASCII characters (code 32..126)');
  WriteLn('      -A -> generate all ASCII characters (code 0..127)');
  WriteLn;
  WriteLn('    -V = display version information and halt');
  WriteLn;
  WriteLn('    no parameters = display this information and halt');
  WriteLn;
  WriteLn('  Note: /x is equivalent to -x');
end;

class procedure TMain.Version;
begin
  WriteLn(
    Format('%s %s ', [TAppInfo.ProgramVersion, TAppInfo.ProgramExeDate])
  );
end;

end.

