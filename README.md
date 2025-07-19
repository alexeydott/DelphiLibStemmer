### DelphiLibStemmer

#### Overview
The `libStemmer` unit provides Delphi bindings for the Snowball stemming library, enabling text normalization through stemming algorithms. It supports multiple character encodings and can be used either with a DLL or via static linking.

#### Key Features
1. **Multi-encoding support**:
   - ISO-8859-1 (Latin-1)
   - ISO-8859-2 (Latin-2)
   - KOI8-R (Cyrillic)
   - UTF-8 (Unicode)

2. **Stemming Operations**:
   - List available algorithms
   - Create/destroy stemmer objects
   - Stem words using specified algorithms
   - Get last stemmed word length

3. **Flexible Integration**:
   - Use `libstemmer.dll` via `USE_LIBSTEMMER_DLL` directive
   - Static linking with provided object files (default)

#### Usage Example
```delphi
uses libStemmer;

var
  stemmer: Pointer;
  stemmedWord: string;
begin
  // Create English stemmer
  stemmer := sb_stemmer_new('english', ENC_UTF_8);
  
  // Stem a word
  stemmedWord := sb_stemmer_stem(stemmer, 'running');
  // stemmedWord = 'run'
  
  // Clean up
  sb_stemmer_delete(stemmer);
end;
```

#### API Reference

##### `sb_stemmer_list`
```delphi
function sb_stemmer_list(): TStringDynArray;
```
- **Description**: Returns available stemming algorithms (e.g., `['english', 'russian', 'spanish']`)
- **Returns**: Dynamic string array of algorithm names

##### `sb_stemmer_new`
```delphi
function sb_stemmer_new(const algorithm: string; 
                       encoding: stemmer_encoding_t = ENC_UTF_8): Pointer;
```
- **Parameters**:
  - `algorithm`: Name from `sb_stemmer_list`
  - `encoding`: Text encoding (default: UTF-8)
- **Returns**: Opaque stemmer pointer
- **Notes**: Returns `nil` for invalid algorithms/encodings

##### `sb_stemmer_stem`
```delphi
function sb_stemmer_stem(const stemmer: Pointer; 
                        const word: string; 
                        encoding: stemmer_encoding_t = ENC_UTF_8): string;
```
- **Parameters**:
  - `stemmer`: Pointer from `sb_stemmer_new`
  - `word`: Input word to stem
  - `encoding`: Text encoding (should match stemmer's encoding)
- **Returns**: Stemmed version of input word

##### `sb_stemmer_delete`
```delphi
procedure sb_stemmer_delete(var stemmer: Pointer);
```
- **Description**: Releases stemmer resources
- **Parameters**: Stemmer pointer (set to `nil` after deletion)

##### `sb_stemmer_length`
```delphi
function sb_stemmer_length(stemmer: Pointer): Integer;
```
- **Description**: Gets length of last stemmed word
- **Requires**: Must be called after `sb_stemmer_stem`

#### Build Configuration
```delphi
{.$define USE_LIBSTEMMER_DLL} // Uncomment for DLL usage
```
- **Static Linking (default)**: Links `libstemmer.obj` (Win32) or `libstemmer.o` (Win64)
- **DLL Usage**: Uses `libstemmer.dll` when defined

#### Character Encoding Notes
- UTF-8 is the default encoding
- Input strings are automatically converted to stemmer's encoding
- Use composed accents (NFC/NFKC) and lowercase for best results

#### Requirements
- Delphi 2009 or newer (Unicode support)
- Windows 32-bit or 64-bit
- `libstemmer.dll` (if using DLL mode)

#### Repository Integration
Include this unit with either:
1. Precompiled `libstemmer.dll` in output folder, or
2. Precompiled (witn C++ Builder 12.3) оbject files (`libstemmer.obj`/`libstemmer.o`) in source directory.
   For custom dll/obj builds see *.h/.c sources in c_src directory. The source files presented in this repository are taken from the latest (at 07.2025) release of the snowball stemmer (Snowball 3.0.1).
   
For building libstemmer from sources see https://github.com/user3486788/snowball/

For full Snowball algorithm documentation, visit: https://snowballstem.org/
