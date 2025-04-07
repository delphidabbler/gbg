unit GBG.DataWriter;

interface

uses
  System.SysUtils,
  System.Classes,
  GBG.Generator.Base;

type

  TDataWriter = class
  strict private
    type
      TBufferCallback = reference to procedure (const ABytesRemaining: UInt64;
        out ABuffer: TBytes);
    var
      fStream: TStream;
      fGenerator: TBaseGenerator;
    procedure DoWrite(const AByteCount: UInt64;
      const ANextBuffer: TBufferCallback);
    procedure FillBuffer(const ABufferSize: UInt64; out ABuffer: TBytes);
  public
    constructor Create(const AStream: TStream;
      const AGenerator: TBaseGenerator);
    procedure WriteDuplicatedChunks(const ADataSize, AChunkSize: UInt64);
    procedure WriteUniqueData(const ADataSize, AChunkSize: UInt64);
  end;

implementation

uses
  System.Math;

{ TDataWriter }

constructor TDataWriter.Create(const AStream: TStream;
  const AGenerator: TBaseGenerator);
begin
  inherited Create;
  Assert(Assigned(AStream));
  Assert(Assigned(AGenerator));
  fStream := AStream;
  fGenerator := AGenerator;
end;

procedure TDataWriter.DoWrite(const AByteCount: UInt64;
  const ANextBuffer: TBufferCallback);
var
  Buffer: TBytes;
begin
  var BytesRemaining := AByteCount;
  while BytesRemaining > 0 do
  begin
    ANextBuffer(BytesRemaining, Buffer);
    var BytesToWrite: UInt64 := Min(BytesRemaining, UInt64(Length(Buffer)));
    fStream.WriteBuffer(Pointer(Buffer)^, BytesToWrite);
    Dec(BytesRemaining, BytesToWrite);
  end;
end;

procedure TDataWriter.FillBuffer(const ABufferSize: UInt64; out ABuffer: TBytes);
begin
  Assert(ABufferSize > 0);
  SetLength(ABuffer, ABufferSize);
  fGenerator.FillBuffer(ABuffer);
end;

procedure TDataWriter.WriteDuplicatedChunks(const ADataSize, AChunkSize: UInt64);
begin
  Assert(ADataSize > 0);
  Assert(AChunkSize > 0);
  // Create and fill buffer
  var GarbageBuffer: TBytes;
  FillBuffer(Min(AChunkSize, ADataSize), GarbageBuffer);
  // Write same buffer data as often as required
  DoWrite(
    ADataSize,
    procedure (const ABytesRemaining: UInt64; out ABuffer: TBytes)
    begin
      ABuffer := GarbageBuffer;
    end
  );
end;

procedure TDataWriter.WriteUniqueData(const ADataSize, AChunkSize: UInt64);
begin
  Assert(ADataSize > 0);
  // Write data using as many blocks of unique random data as necessary
  DoWrite(
    ADataSize,
    procedure (const ABytesRemaining: UInt64; out ABuffer: TBytes)
    begin
      FillBuffer(Min(AChunkSize, ABytesRemaining), ABuffer);
    end
  );
end;

end.
