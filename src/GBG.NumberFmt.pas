unit GBG.NumberFmt;

interface

uses
  System.SysUtils,
  System.Generics.Collections;

type

  TNumberFmt = record
  strict private
    var
      fValue: UInt64;
    class var
      fIECMap: TDictionary<string,UInt64>;
  public
    class constructor Create;
    class destructor Destroy;
    constructor Create(const AValue: UInt64);
    property Value: UInt64 read fValue write fValue;
    function ToString: string;
    function TryParse(ANumStr: string): Boolean; overload;
    class function TryParse(ANumStr: string; out AValue: UInt64): Boolean;
      overload; static;
  end;

  ENumberFmt = class(Exception);

implementation

uses
  System.Character,
  System.Hash,
  System.Generics.Defaults,
  GBG.Types;

{ TNumberFmt }

constructor TNumberFmt.Create(const AValue: UInt64);
begin
  fValue := AValue;
end;

class destructor TNumberFmt.Destroy;
begin
  fIECMap.Free;
end;

class constructor TNumberFmt.Create;
begin
  fIECMap := TDictionary<string,UInt64>.Create(
    TDelegatedEqualityComparer<string>.Create(
      function (const Left, Right: string): Boolean
      begin
        Result := string.Compare(Left, Right, True) = 0;
      end,
      function (const Value: string): Integer
      begin
        Result := THashBobJenkins.GetHashValue(
          string.UpperCase(Value, TLocaleOptions.loUserLocale)
        );
      end
    )
  );
  fIECMap.Add('Kb',  TMemUnits.OneKB);    // kilobyte
  fIECMap.Add('KiB', TMemUnits.OneKiB);   // kibibyte
  fIECMap.Add('MB',  TMemUnits.OneMB);	  // megabyte
  fIECMap.Add('MiB', TMemUnits.OneMiB);   // mebibyte
  fIECMap.Add('GB',  TMemUnits.OneGB);    // gigabyte
  fIECMap.Add('GiB', TMemUnits.OneGiB);   // gibibyte
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

  // Check the validity of the parts of number split by decimal separator
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
  // Format is number, optionally with thousands separator, optionally ending in
  // a IEC symbol

  // get format settings for current locale to get correct decimal separator
  var Fmt := TFormatSettings.Create;

  // split string at decimal separators
  var Parts := ANumStr.Split([Fmt.ThousandSeparator]);

  // split out any IEC symbol from last part of split string
  var LastPart := Parts[High(Parts)];
  if LastPart.IsEmpty then
    Exit(False);  // means number ended in decimal separator
  // collect digits from LastPart
  var ChIdx: Integer := 1;
  var Digits := string.Empty;
  while (ChIdx <= Length(LastPart)) and (LastPart[ChIdx].IsDigit) do
  begin
    Digits := Digits + LastPart[ChIdx];
    Inc(ChIdx);
  end;
  // replace last part with only digits
  Parts[High(Parts)] := Digits;
  // collect any characters that make up IEC symbol
  var Symbol := string.Empty;
  while ChIdx <= Length(LastPart) do
  begin
    Symbol := Symbol + LastPart[ChIdx];
    Inc(ChIdx);
  end;

  // check the number parts if more than 1
  if (Length(Parts) > 1) and not CheckNumParts(Parts) then
    Exit(False);

  // recombine and parse the number
  var NumStr := string.Join('', Parts);
  var ParsedNumber: UInt64;
  if not TryStrToUInt64(NumStr, ParsedNumber) then
    Exit(False);

  // get the bytes multiplier from IEC symbol
  var Multiplier: UInt64;
  if Symbol.IsEmpty then
    Multiplier := 1
  else if not fIECMap.TryGetValue(Symbol, Multiplier) then
    Exit(False);

  // calculate number of bytes after applying multiplier
  if High(UInt64) div Multiplier < ParsedNumber then
    Exit(False);  // Multiplier * ParsedNumber to big for UInt64!
  fValue := Multiplier * ParsedNumber;
  Result := True;
end;

end.
