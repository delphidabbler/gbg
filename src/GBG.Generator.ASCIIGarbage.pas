unit GBG.Generator.ASCIIGarbage;

interface

uses
  System.SysUtils,
  GBG.Generator.Base;

type
  TPrintableASCIIGarbageGenerator = class sealed(TBaseGenerator)
  public
    procedure FillBuffer(var Buffer: TBytes); override;
  end;

  TASCIIGarbageGenerator = class sealed(TBaseGenerator)
  public
    procedure FillBuffer(var Buffer: TBytes); override;
  end;

implementation

uses
  System.Math;

{ TPrintableASCIIGarbageGenerator }

procedure TPrintableASCIIGarbageGenerator.FillBuffer(var Buffer: TBytes);
begin
  Randomize;
  for var Idx: UInt64 := 0 to Pred(Length(Buffer)) do
    // Get ASCII code in range $20..$7E (SPACE..'~')
    // (2nd param of RandomRange is exclusive, hence use of Succ())
    Buffer[Idx] := Byte(RandomRange($20, Succ($7E)));
end;

{ TASCIIGarbageGenerator }

procedure TASCIIGarbageGenerator.FillBuffer(var Buffer: TBytes);
begin
  Randomize;
  for var Idx: UInt64 := 0 to Pred(Length(Buffer)) do
    // Get ASCII code in range 0..127
    Buffer[Idx] := Random(128);
end;

end.

