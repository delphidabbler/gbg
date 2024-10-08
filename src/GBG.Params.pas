unit GBG.Params;

interface

uses
  GBG.Types;

type

  TParams = class
  strict private
    const
      OptionStartChars = ['-', '/'];
    var
      fFileName: string;
      fFileSize: UInt64;
      fGeneratorType: TGeneratorType;
      fExistingFileAction: TExistingFileAction;
      fLargeFileAction: TLargeFileAction;
      fShowVersion: Boolean;
      fIsFileSizeSet: Boolean;
      fMaxFileSize: UInt64;
    function IsOption(const S: string): Boolean;
    procedure ParseCommandLine;
  public
    constructor Create(const AMaxFileSize: UInt64);
    property FileName: string read fFileName;
    property FileSize: UInt64 read fFileSize;
    property GeneratorType: TGeneratorType read fGeneratorType;
    property ExistingFileAction: TExistingFileAction read fExistingFileAction;
    property LargeFileAction: TLargeFileAction read fLargeFileAction;
    property ShowVersion: Boolean read fShowVersion;
  end;

implementation

uses
  System.SysUtils,
  System.Character,

  GBG.Exceptions,
  GBG.NumberFmt;

{ TParams }

constructor TParams.Create(const AMaxFileSize: UInt64);
begin
  inherited Create;
  fMaxFileSize := AMaxFileSize;
  fFileName := '';
  fFileSize := 0;
  fGeneratorType := TGeneratorType.Binary;
  fExistingFileAction := TExistingFileAction.Prompt;
  fLargeFileAction := TLargeFileAction.Prompt;
  fShowVersion := False;
  fIsFileSizeSet := False;
  ParseCommandLine;
end;

function TParams.IsOption(const S: string): Boolean;
begin
  Result := (S.Length >= 2) and CharInSet(S[1], OptionStartChars);
end;

procedure TParams.ParseCommandLine;
begin
  if ParamCount = 0 then
    raise ESilent.Create('');
  for var I := 1 to ParamCount do
  begin
    var Cmd := ParamStr(I);
    if IsOption(Cmd) then
    begin
      if (Length(Cmd) = 2) and (Cmd[2] = 'a') then
      begin
        fGeneratorType := TGeneratorType.PrintableASCII;
      end
      else if (Length(Cmd) = 2) and (Cmd[2] = 'A') then
      begin
        fGeneratorType := TGeneratorType.ASCII;
      end
      else if (Length(Cmd) = 2) and (Cmd[2] = 'o') then
      begin
        fExistingFileAction := TExistingFileAction.Error;
      end
      else if (Length(Cmd) = 2) and (Cmd[2] = 'O') then
      begin
        fExistingFileAction := TExistingFileAction.Overwrite;
      end
      else if (Length(Cmd) = 2) and (Cmd[2] = 'l') then
      begin
        fLargeFileAction := TLargeFileAction.Error;
      end
      else if (Length(Cmd) = 2) and (Cmd[2] = 'L') then
      begin
        fLargeFileAction := TLargeFileAction.Allow;
      end
      else if (Length(Cmd) = 2) and (Cmd[2] = 'V') then
        fShowVersion := True
      else
        raise EUsageError.CreateFmt('Option not valid: "%s"', [Cmd]);
    end
    else
    begin
      if fFileName = '' then
        fFileName := Cmd
      else if not fIsFileSizeSet then
      begin
        if not TNumberFmt.TryParse(Cmd, fFileSize) then
          raise EUsageError.CreateFmt(
            'Invalid file size. Must be a whole number in range 0 to %s',
            [TNumberFmt.Create(fMaxFileSize).ToString]
          );
        fIsFileSizeSet := True;
      end
      else
        raise EUsageError.Create('Too many parameters');
    end;
  end;
  if fShowVersion then
  begin
    if ParamCount <> 1 then
      raise EUsageError.Create('-V must be the only parameter');
  end
  else if (fFileName = '') or not fIsFileSizeSet then
    raise EUsageError.Create('A file name and a file size are required');
end;

end.
