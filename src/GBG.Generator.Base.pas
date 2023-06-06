unit GBG.Generator.Base;

interface

uses
  System.SysUtils,
  GBG.Types;

type
  TBaseGenerator = class abstract
  public
    procedure FillBuffer(var Buffer: TBytes); virtual; abstract;
  end;

  TGeneratorFactory = class sealed
  public
    class function CreateInstance(const AGenType: TGeneratorType):
      TBaseGenerator;
  end;

implementation

uses
  GBG.Generator.BinaryGarbage,
  GBG.Generator.PrintableASCIIGarbage;

type
  TGeneratorClass = class of TBaseGenerator;

{ TGeneratorFactory }

class function TGeneratorFactory.CreateInstance(
  const AGenType: TGeneratorType): TBaseGenerator;
const
  GenClasses: array[TGeneratorType] of TGeneratorClass = (
    TBinaryGarbageGenerator, TPrintableASCIIGarbageGenerator
  );
begin
  Result := GenClasses[AGenType].Create;
end;

end.
