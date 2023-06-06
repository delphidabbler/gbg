unit GBG.NumberFmt;

interface

uses
  System.SysUtils;

type
  TNumberFmt = record
  strict private
    var
      fValue: UInt64;
  public
    constructor Create(const AValue: UInt64);
    property Value: UInt64 read fValue write fValue;
    function ToString: string;
    function TryParse(ANumStr: string): Boolean; overload;
    class function TryParse(ANumStr: string; out AValue: UInt64): Boolean;
      overload; static;
  end;

  ENumberFmt = class(Exception);

implementation

{ TNumberFmt }

constructor TNumberFmt.Create(const AValue: UInt64);
begin
  fValue := AValue;
end;

function TNumberFmt.ToString: string;
begin
  Result := Format('%.0n', [Extended(fValue)], TFormatSettings.Create);
end;

class function TNumberFmt.TryParse(ANumStr: string;
  out AValue: UInt64): Boolean;
begin
  var NF: TNumberFmt;
  Result := NF.TryParse(ANumStr);
  if Result then
    AValue := NF.Value;
end;

function TNumberFmt.TryParse(ANumStr: string): Boolean;

  function CheckNumParts(const Parts: array of string): Boolean;
  begin
    if Length(Parts) = 0 then
      Exit(False);
    if not (Length(Parts[0]) in [1..3]) then
      Exit(False);
    for var Idx := 1 to Pred(Length(Parts)) do
    begin
      if Length(Parts[Idx]) <> 3 then
        Exit(False);
    end;
    Result := True;
  end;

begin
  var Fmt := TFormatSettings.Create;
  if ANumStr.Contains(Fmt.ThousandSeparator) then
  begin
    // Number has thousands separate, check format and strip separators
    var NumStrParts := ANumStr.Split([Fmt.ThousandSeparator]);
    if not CheckNumParts(NumStrParts) then
      Exit(False);
    ANumStr := string.Join('', NumStrParts);
  end;
  Result := TryStrToUInt64(ANumStr, fValue);
end;

end.
