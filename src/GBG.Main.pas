unit GBG.Main;

interface

uses
  System.SysUtils;

type

  EUsageError = class(Exception);

  ECancellation = class(Exception);

  EExecutionError = class(Exception);

  ESilent = class(Exception);

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
      fFileName: string;
      fFileSize: UInt64;
    class procedure FillBufferWithGarbage(var Bytes: TBytes);
    class procedure CreateBuffer(out Buffer: TBytes);
    class function GetConfirmation(const Question: string;
      const TrueResponse: Char): Boolean;
    class procedure CheckUserPermissions;
    class procedure HandleProgramException(const E: Exception);
    class procedure HandleExecutionException(const E: Exception);
    class function FreeSpaceOnFileDrive: UInt64;
    class procedure ParseAndCheckParams;
    class function ParseNumberStr(ANumStr: string): UInt64;
    class procedure Usage;
    class procedure Initialise;
    class procedure Execute;
  public
    class procedure Run;
  end;

implementation

uses
  System.IOUtils,
  System.Classes,
  System.Math,
  System.Character,
  GBG.Generator.Base,
  GBG.Generator.BinaryGarbage,
  GBG.NumberFmt;

{ TMain }

class procedure TMain.CheckUserPermissions;
begin
  if fFileSize > MaxUnchallengedFileSize  then
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
  if TFile.Exists(fFileName) then
  begin
    if not GetConfirmation('File already exists. Overwrite? [y/N]', 'Y') then
      raise ECancellation.Create('Operation cancelled');
  end;
end;

class procedure TMain.CreateBuffer(out Buffer: TBytes);
begin
  SetLength(Buffer, Min(BufSize, fFileSize));
  if Length(Buffer) > 0 then
    FillBufferWithGarbage(Buffer);
end;

class procedure TMain.Execute;
begin
  try
    var FS := TFileStream.Create(fFileName, fmCreate);
    try
      if fFileSize = 0 then
        Exit;

      var Buffer: TBytes;
      CreateBuffer(Buffer);

      var BytesRemaining := fFileSize;
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
  var Generator := TGeneratorFactory.CreateBinaryGarbage;
  try
    Generator.FillBuffer(Bytes);
  finally
    Generator.Free;
  end;
end;

class function TMain.FreeSpaceOnFileDrive: UInt64;
begin
  var FreeAvailable, Total, FreeTotal: Int64;
  var Drive := TDirectory.GetDirectoryRoot(fFileName);
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
    if TFile.Exists(fFileName) then
      TFile.Delete(fFileName);
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

  if ParamCount = 0 then
    raise ESilent.Create('');

  ParseAndCheckParams;

  CheckUserPermissions; // raises exceptions if user denies permissions

  if fFileSize > FreeSpaceOnFileDrive then
    raise EExecutionError.Create(
      'Requested file size is larger than free space on drive '
      + TDirectory.GetDirectoryRoot(fFileName)
    );
end;

class procedure TMain.ParseAndCheckParams;
begin
  fFileName := ParamStr(1);
  var FileSizeStr: string := ParamStr(2);

  if FileSizeStr = '' then
    raise EUsageError.Create('A file size is required');

  fFileSize := ParseNumberStr(FileSizeStr);
end;

class function TMain.ParseNumberStr(ANumStr: string): UInt64;
begin
  var NumFmt: TNumberFmt;
  if not NumFmt.TryParse(ANumStr) then
    raise EUsageError.CreateFmt(
      'Invalid file size. Must be a whole number in range 0 to %s',
      [TNumberFmt.Create(MaxSupportedFileSize).ToString]
    );
  Result := NumFmt.Value;
end;

class procedure TMain.Run;
begin
  try
    Initialise;
    Execute;
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
  Writeln('  gbg filename size');
  Writeln;
  Writeln('  where:');
  Writeln('    filename = name of file to create');
  Writeln(
    Format(
      '    size = size of file to generate (0..%s)',
      [TNumberFmt.Create(MaxSupportedFileSize).ToString]
    )
  );
end;

end.
