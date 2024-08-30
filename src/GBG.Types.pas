unit GBG.Types;

{$SCOPEDENUMS ON}

interface

type


  TGeneratorType = (
    Binary,
    PrintableASCII,
    ASCII
  );

  TExistingFileAction = (
    Prompt,
    Error,
    Overwrite
  );

  TLargeFileAction = (
    Prompt,
    Error,
    Allow
  );

implementation

end.
