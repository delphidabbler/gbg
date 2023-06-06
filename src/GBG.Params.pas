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
      fIsFileSizeSet: Boolean;
      fMaxFileSize: UInt64;
    function IsOption(const S: string): Boolean;
    procedure ParseCommandLine;
  public
    constructor Create(const AMaxFileSize: UInt64);
    property FileName: string read fFileName;
    property FileSize: UInt64 read fFileSize;
    property GeneratorType: TGeneratorType read fGeneratorType;
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
  if (fFileName = '') or not fIsFileSizeSet then
    raise EUsageError.Create('A file name and a file size are required');
end;

end.
