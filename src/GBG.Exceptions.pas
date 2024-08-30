unit GBG.Exceptions;

interface

uses
  System.SysUtils;

type

  EUsageError = class(Exception);

  ECancellation = class(Exception);

  EFileExists = class(Exception);

  EExecutionError = class(Exception);

  ESilent = class(Exception);

implementation

end.
