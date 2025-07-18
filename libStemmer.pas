unit libStemmer;
/// <summary>
/// Delphi bindings for the Snowball stemming library, enabling text normalization through stemming algorithms. 
/// </summary>
{.$define USE_LIBSTEMMER_DLL} // uncomment to use libstemmer.dll
interface

uses Types, SysUtils;

type
  /// <summary>
  /// Represents character encoding schemes supported by the snowball stemmer library
  /// </summary>
  /// <remarks>
  /// This enumeration defines specific character encodings used for text processing.
  /// Each value corresponds to a standard character encoding scheme.
  /// </remarks>
  stemmer_encoding_t = (
    /// <summary>
    /// Unknown or unsupported encoding (default value)
    /// </summary>
    ENC_UNKNOWN = 0,

    /// <summary>
    /// ISO/IEC 8859-1 (Latin-1) encoding
    /// </summary>
    /// <remarks>
    /// Covers most Western European languages
    /// </remarks>
    ENC_ISO_8859_1,

    /// <summary>
    /// ISO/IEC 8859-2 (Latin-2) encoding
    /// </summary>
    /// <remarks>
    /// Supports Central and Eastern European languages
    /// </remarks>
    ENC_ISO_8859_2,

    /// <summary>
    /// KOI8-R Cyrillic encoding (Russian)
    /// </summary>
    /// <remarks>
    /// Standard encoding for Russian language in Unix systems
    /// </remarks>
    ENC_KOI8_R,

    /// <summary>
    /// UTF-8 Unicode encoding
    /// </summary>
    /// <remarks>
    /// Variable-width Unicode encoding supporting all languages
    /// </remarks>
    ENC_UTF_8
  );

  /// <summary>
  /// Returns an array of the canonical names of the available stemming algorithms.
  /// </summary>
  function sb_stemmer_list(): TStringDynArray;
  /// <summary>
  ///   Create a new stemmer object, using the specified algorithm, for the
  ///   specified character encoding.
  /// </summary>
  /// <param name="algorithm">
  ///   The algorithm name. see <see cref="libStemmer|sb_stemmer_list" />
  /// </param>
  /// <param name="encoding">
  ///   The character encoding. if ENC_UNKNOWN will be passed UTF-8 encoding
  ///   will be assumed.
  /// </param>
  /// <returns>
  ///   Pointer to a newly created stemmer for the requested algorithm or nil
  ///   if the specified algorithm is not recognised, or the algorithm is not
  ///   available for the requested encoding. The returned pointer must be
  ///   deleted by calling <see cref="libStemmer|sb_stemmer_delete" />().
  /// </returns>
  /// <remarks>
  ///   All algorithms will usually be available in UTF-8, but may also be
  ///   available in other character encodings.
  /// </remarks>
  function sb_stemmer_new(const algorithm: string; encoding: stemmer_encoding_t = ENC_UTF_8): Pointer;
  /// <summary>
  ///   Delete a stemmer object. After calling this function, the supplied
  ///   stemmer may no longer be used in any way.
  /// </summary>
  /// <remarks>
  ///   It is safe to pass a null pointer to this function - this will have no
  ///   effect.
  /// </remarks>
  procedure sb_stemmer_delete(var stemmer: Pointer);
  /// <summary>
  ///   Stem a word. The stemming algorithms generally expect the input text to
  ///   use composed accents (Unicode NFC or NFKC) and to have been folded to
  ///   lower case already. <br />
  /// </summary>
  /// <param name="stemmer">
  ///   stemmer
  /// </param>
  /// <param name="word">
  ///   word
  /// </param>
  /// <param name="word">
  ///   character encoding of the stemmer
  /// </param>
  /// <returns>
  ///   If an out-of-memory error occurs, this will return NULL.
  /// </returns>
  function sb_stemmer_stem(const stemmer: Pointer; const word: string; encoding: stemmer_encoding_t = ENC_UTF_8): string; overload;
  /// <summary>
  ///   length of the last stemmed word for desired stremmer
  /// </summary>
  /// <param name="stemmer">
  ///   stremmer
  /// </param>
  ///  <remarks>
  ///  should not be called before <cref="libStemmer|sb_stemmer_stem" />() has been called.
  ///  </remarks>
  function sb_stemmer_length(stemmer: Pointer): Integer;

implementation

{$ifndef USE_LIBSTEMMER_DLL}
uses crtl;
{$endif}

const
  STEMMER_LIST_MAX = MaxInt div SizeOf(Pointer)-1;
{$ifndef USE_LIBSTEMMER_DLL}
{$ifdef UNDERSCOREIMPORTNAME}
  STEMMER_METHOD_PREFIX = '_';
{$ELSE}
  STEMMER_METHOD_PREFIX = '';
{$endif}
{$else}
  STEMMER_DLL = {$ifdef win64}'libstemmer64.dll'{$else}'libstemmer.dll'{$endif};
  STEMMER_METHOD_PREFIX = '';
{$endif}
type
  Psb_stemmer = ^Tsb_stemmer;
  Tsb_stemmer = record end;
  sb_symbol = Byte;
  Psb_symbol = ^sb_symbol;

  MarshaledAStringArray = array[0..STEMMER_LIST_MAX] of MarshaledAString;
  PMarshaledAStringArray = ^MarshaledAStringArray;

  stemmer_encoding = record
    Name: PAnsiChar;
    Enc: stemmer_encoding_t;
  end;

  stemmer_module = record
    Name: PAnsiChar;
    Enc: stemmer_encoding_t;
  end;

const
  stemmer_encodings: array[stemmer_encoding_t] of stemmer_encoding = (
    (Name: 'ISO_8859_1'; Enc: ENC_ISO_8859_1),
    (Name: 'ISO_8859_2'; Enc: ENC_ISO_8859_2),
    (Name: 'KOI8_R'; Enc: ENC_KOI8_R),
    (Name: 'UTF_8'; Enc: ENC_UTF_8),
    (Name: nil; Enc: ENC_UNKNOWN)
  );

function libStemmer_stemmer_list: PMarshaledAStringArray; cdecl; external {$ifdef USE_LIBSTEMMER_DLL}STEMMER_DLL{$endif} name STEMMER_METHOD_PREFIX +'sb_stemmer_list';
function libStemmer_stemmer_new(algorithm: MarshaledAString; charenc: MarshaledAString): Psb_stemmer; cdecl; external {$ifdef USE_LIBSTEMMER_DLL}STEMMER_DLL{$endif} name STEMMER_METHOD_PREFIX+'sb_stemmer_new';
procedure libStemmer_stemmer_delete(stemmer: Psb_stemmer); cdecl; external {$ifdef USE_LIBSTEMMER_DLL}STEMMER_DLL{$endif} name STEMMER_METHOD_PREFIX+'sb_stemmer_delete';
function libStemmer_stemmer_stem(stemmer: Psb_stemmer; word: Psb_symbol; size: Integer): Psb_symbol; cdecl; external {$ifdef USE_LIBSTEMMER_DLL}STEMMER_DLL{$endif} name STEMMER_METHOD_PREFIX + 'sb_stemmer_stem';
function libStemmer_stemmer_length(stemmer: Psb_stemmer): Integer; cdecl; external {$ifdef USE_LIBSTEMMER_DLL}STEMMER_DLL{$endif} name STEMMER_METHOD_PREFIX+'sb_stemmer_length';

{$ifndef USE_LIBSTEMMER_DLL}

{$ifdef WIN64}
{$link libstemmer.o}
{$else}
{$link libstemmer.obj}
{$endif}

function {$IFDEF WIN32}_calloc{$ELSE}calloc{$ENDIF}(nelem, size: NativeUint): Pointer; cdecl;
begin
  // zero-size or memory overflow
  if (nelem = 0) or (size = 0) or ((size > 0) and (nelem > High(NativeUInt) div size)) then
    Result := nil
  else
    Result := AllocMem(nelem * size);
end;
{$endif}


//function StrLen(const s: MarshaledAString): NativeUint;
//begin
//  Result := 0;
//  if not Assigned(s) then Exit;
//
//  while s[Result] <> #0 do
//    Inc(Result);
//end;

function StrLen(const s: MarshaledAString): NativeUint;
var
  p: MarshaledAString;
begin
  if not Assigned(s) then Exit(0);
  p := s;
  // 4-byte-alighn
  while (UIntPtr(p) and 3 <> 0) do
  begin
    if p[0] = #0 then Exit(p - s);
    Inc(p);
  end;

  // 4 bytes Block processing
  repeat
    if (PLongWord(p)^ and $FF = 0) then Exit(p - s);
    if (PLongWord(p)^ and $FF00 = 0) then Exit(p - s + 1);
    if (PLongWord(p)^ and $FF0000 = 0) then Exit(p - s + 2);
    if (PLongWord(p)^ and $FF000000 = 0) then Exit(p - s + 3);
    Inc(p, 4);
  until False;
end;

function sb_stemmer_list(): TStringDynArray;
var p: PMarshaledAStringArray; i: integer;
begin
  Result := nil;
  p := libStemmer_stemmer_list;
  if Assigned(p) then
  begin
    for i := 0 to STEMMER_LIST_MAX do
    begin
      if p[i] = nil then
        Exit;
      SetLength(Result,1+i);
      Result[i] := TMarshal.ReadStringAsAnsi(TPtrWrapper.Create(p[i]));
    end;
  end;
end;

function sb_stemmer_new(const algorithm: string; encoding: stemmer_encoding_t): Pointer;
var
  p: TPtrWrapper;
begin
  if encoding = ENC_UNKNOWN then encoding := ENC_UTF_8;
  p := TMarshal.AllocStringAsUtf8(algorithm.ToLower);
  Result := libStemmer_stemmer_new(p.ToPointer,stemmer_encodings[encoding].Name);
end;

procedure sb_stemmer_delete(var stemmer: Pointer);
begin
  if stemmer <> nil then
  begin
    libStemmer_stemmer_delete(stemmer);
    stemmer := nil;
  end;
end;

function sb_stemmer_stem(const stemmer: Pointer; const word: string; encoding: stemmer_encoding_t): string;
var pWord: TPtrWrapper; pResult: Psb_symbol;
begin
  Result := Word;
  if (stemmer = nil) or (word = '') then
    Exit;

  if encoding = ENC_UTF_8 then
    pWord := TMarshal.AllocStringAsUtf8(word)
  else
    pWord := TMarshal.AllocStringAsAnsi(word);

  pResult := libStemmer_stemmer_stem(stemmer,pWord.ToPointer,StrLen(MarshaledAString(pWord.ToPointer)));

  if encoding = ENC_UTF_8 then
    Result := TMarshal.ReadStringAsUtf8(TPtrWrapper.Create(pResult))
  else
    Result := TMarshal.ReadStringAsAnsi(TPtrWrapper.Create(pResult));
end;

function sb_stemmer_length(stemmer: Pointer): Integer;
begin
  if stemmer <> nil then
    Result := libStemmer_stemmer_length(stemmer)
  else
    Result := 0
end;


end.
