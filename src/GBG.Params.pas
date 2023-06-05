unit GBG.Params;

interface

type

  TParams = class
  strict private
    const
      OptionStartChars = ['-', '/'];
    var
      fFileName: string;
      fFileSize: UInt64;
      fIsFileSizeSet: Boolean;
      fMaxFileSize: UInt64;
    procedure ParseCommandLine;
  public
    constructor Create(const AMaxFileSize: UInt64);
    property FileName: string read fFileName;
    property FileSize: UInt64 read fFileSize;
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
  fIsFileSizeSet := False;
  ParseCommandLine;
end;

procedure TParams.ParseCommandLine;
begin
  if ParamCount = 0 then
    raise ESilent.Create('');
  for var I := 1 to ParamCount do
  begin
    var Cmd := ParamStr(I);
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
  if (fFileName = '') or not fIsFileSizeSet then
    raise EUsageError.Create('A file name and a file size are required');
end;

end.
