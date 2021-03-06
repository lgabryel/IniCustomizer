program AppCustomizer;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, SysUtils, CustApp, IniFiles
  { you can add units after this };

type

  { TAppCustomizer }

  TAppCustomizer = class(TCustomApplication)
  private
    patternApp: TINIFile;
    overrideApp: TINIFile;
    destinationApp : TINIFile;
    procedure CopyIniFile(source : TINIFile; dest : TINIFile);
    procedure CheckOptionsAndExitOnError(shortParam : String; longParam : String);
  protected
    procedure DoRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure WriteHelp; virtual;
  end;

{ TAppCustomizer }

procedure TAppCustomizer.DoRun;
var
  sourcePath, destPath, overridePath : String;
begin
{  CheckOptionsAndExitOnError('s','source');
  CheckOptionsAndExitOnError('o','override');
  CheckOptionsAndExitOnError('d','destination');  }

  // parse parameters
  if HasOption('h', 'help') then begin
    WriteHelp;
    Terminate;
    Exit;
  end;

  sourcePath := GetOptionValue('s', 'source');
  destPath := GetOptionValue('d', 'destination');
  overridePath := GetOptionValue('o', 'override');

  { add your program here }
  patternApp :=  TINIFile.Create(sourcePath);
  overrideApp := TINIFile.Create(overridePath);
  destinationApp := TINIFile.Create(destPath);

  CopyIniFile(patternApp,destinationApp);
  CopyIniFile(overrideApp,destinationApp);


  // stop program loop
  Terminate;
end;

procedure TAppCustomizer.CheckOptionsAndExitOnError(shortParam : String; longParam : String);
var
  ErrorMsg: String;
begin
  // quick check parameters
  ErrorMsg:=CheckOptions(shortParam, longParam);
  if ErrorMsg<>'' then begin
    ShowException(Exception.Create(ErrorMsg));
    Terminate;
    Exit;
  end;
end;

constructor TAppCustomizer.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  StopOnException:=True;
end;

destructor TAppCustomizer.Destroy;
begin
  patternApp.Destroy;
  overrideApp.Destroy;
  destinationApp.Destroy;

  inherited Destroy;
end;

procedure TAppCustomizer.WriteHelp;
begin
  { add your help code here }
  writeln('Usage: ', ExeName, ' -h');
end;

procedure TAppCustomizer.CopyIniFile(source : TINIFile; dest : TINIFILE);
var
  sourceSections: TStringList;
  keyValues: TStringList;
  section: String;
  keyValue: String;
  parsedKeyValue: TStringArray;
const
  ASSIGN_SIGN = '=';
begin
  sourceSections := TStringList.Create;
  source.ReadSections(sourceSections);

  for section in sourceSections do
  begin
    keyValues := TStringList.Create;
    source.ReadSectionValues(section, keyValues);
    for keyValue in keyValues do
    begin
      parsedKeyValue := keyValue.Split(ASSIGN_SIGN);
      dest.WriteString(section,parsedKeyValue[0], parsedKeyValue[1]) ;
    end;
  end;
end;

var
  Application: TAppCustomizer;
begin
  Application:=TAppCustomizer.Create(nil);
  Application.Title:='APPCustomizer';
  Application.Run;
  Application.Free;
end.

