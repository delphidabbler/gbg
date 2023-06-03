unit GBG.Generator.BinaryGarbage;

interface

uses
  System.SysUtils,
  GBG.Generator.Base;

type
  TBinaryGarbageGenerator = class sealed(TBaseGenerator)
  public
    procedure FillBuffer(var Buffer: TBytes); override;
  end;

implementation

{ TBinaryGarbageGenerator }

procedure TBinaryGarbageGenerator.FillBuffer(var Buffer: TBytes);
begin
  Randomize;
  for var Idx: UInt64 := 0 to Pred(Length(Buffer)) do
    Buffer[Idx] := Random(High(Byte));
end;

end.
