program GBG;

{$APPTYPE CONSOLE}

{$R *.res}
{$R Version.res}

uses
  System.SysUtils,
  GBG.Main in 'GBG.Main.pas',
  GBG.Generator.Base in 'GBG.Generator.Base.pas',
  GBG.Generator.BinaryGarbage in 'GBG.Generator.BinaryGarbage.pas';

begin
  {$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := True;
  {$ENDIF}
  try

    TMain.Run;

    {$IF Defined(DEBUG) and Defined(MSWINDOWS)}
    {$WARN SYMBOL_PLATFORM OFF}
    if DebugHook <> 0 then
    begin
      Writeln;
      Writeln('Press enter to end the program');
      Readln;
    end;
    {$WARN SYMBOL_PLATFORM ON}
    {$ENDIF}
  except
    on E: Exception do
    begin
      Writeln('Uncaught exception:');
      Writeln(E.ClassName + ': ' + E.Message);
    end;
  end;
end.

