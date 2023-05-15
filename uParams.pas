unit uParams;

interface

uses
  Windows, Classes, SysUtils, StrUtils, Cromis.SimpleLog;

const
  BuildNo = {$I BuildNo.inc};

function ApplicationName: string;

type
  TAppParams = class
  private
  public
    AppName: string; // название приложения и версия
    fs: TFormatSettings;
    Channel: string; // канал телеграм
    Folder: string;
    constructor Create;
    function AsJson: string; // править при добавлении свойств
 //   property MainUrl: string read GetMainUrl;
  end;


implementation

uses dea.Tools;

function ApplicationName: string;
begin
  Result := 'FileToTelegram, ' + FormatFloat('0.0#', BuildNo);
end;

constructor TAppParams.Create;
begin
  AppName := ApplicationName;
  Channel := '-1001735526780'; // Signature Sniper ETH
  Folder := '.\OUT\';
  fs := TFormatSettings.Create('en-US');
  fs.DecimalSeparator := '.';
  fs.ThousandSeparator := ',';
  fs.ShortTimeFormat := 'hh:nn:ss';
  fs.ShortDateFormat := 'yyyy-mm-dd';
end;

function TAppParams.AsJson: string;
begin
  Result := '{' +
    '"channel":' + Channel + ',' + CR +
    '"folder":' + Folder + ',' + CR +
  //  '"Site":' + Site.ToString + ',' + CR +
  //  '"Delay":' + Delay.ToString + ',' + CR +
  //  '"RepeatEvery":' + RepeatEvery.ToString + ',' + CR +
 //   '"RepeatTimes":' + RepeatTimes.ToString + ',' + CR +
 //   '"Scroll":' + BoolToStr(Scroll, true).ToLower + CR +
    '}';

end;

end.
