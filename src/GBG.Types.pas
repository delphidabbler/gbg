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

  TMemUnits = record
  public
    const
      OneKB = UInt64(1_000);
      OneMB = UInt64(1_000_000);
      OneGB = UInt64(1_000_000_000);
      OneKiB = UInt64(1_024);
      OneMiB = UInt64(1_048_576);
      OneGiB = UInt64(1_073_741_824);
  end;

implementation

end.
