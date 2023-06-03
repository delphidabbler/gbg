unit GBG.Generator.Base;

interface

uses
  System.SysUtils;

type
  TBaseGenerator = class abstract
  public
    procedure FillBuffer(var Buffer: TBytes); virtual; abstract;
  end;

  TGeneratorFactory = class sealed
  public
    class function CreateBinaryGarbage: TBaseGenerator;
  end;

implementation

uses
  GBG.Generator.BinaryGarbage;

{ TGeneratorFactory }

class function TGeneratorFactory.CreateBinaryGarbage: TBaseGenerator;
begin
  Result := TBinaryGarbageGenerator.Create;
end;

end.
