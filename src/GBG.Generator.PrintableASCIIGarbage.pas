unit GBG.Generator.PrintableASCIIGarbage;

interface

uses
  System.SysUtils,
  GBG.Generator.Base;

type
  TPrintableASCIIGarbageGenerator = class sealed(TBaseGenerator)
  public
    procedure FillBuffer(var Buffer: TBytes); override;
  end;

implementation

uses
  System.Math;

{ TPrintableASCIIGarbageGenerator }

procedure TPrintableASCIIGarbageGenerator.FillBuffer(var Buffer: TBytes);
const
  LF = 10;
  SPACE = 32;
  DEL = 127;
begin
  Randomize;
  for var Idx: UInt64 := 0 to Pred(Length(Buffer)) do
  begin
    // Get ASCII code in range 32..127 (SPACE..DEL)
    // (2nd param of RandomRange is exclusive)
    var B := Byte(RandomRange($20, Succ($7E)));
    Buffer[Idx] := B;
  end;
end;

end.