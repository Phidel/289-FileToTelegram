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
    function GetMainUrl: string;
    function GetAddressUrl: string;
    function GetBaseUrl: string;
  public
    AppName: string; // название приложения и версия
    Site: Integer;
    fs: TFormatSettings;
    Channel: Integer; // канал телеграм
    Delay: Integer; // задержка между запросами
    RepeatEvery: Integer; // повторять запросы на декомпилятор в случае таймаута
    RepeatTimes: Integer; // сколько раз, через сколько минут
    Scroll: Boolean;
    constructor Create;
    function AsJson: string; // править при добавлении свойств
    property MainUrl: string read GetMainUrl;
    property AddressUrl: string read GetAddressUrl;
    property BaseUrl: string read GetBaseUrl;
  end;

const
  S_ETHER = 0;
  S_BSC = 1;

  _MainUrl: array [0 .. 1] of string = (
    'https://etherscan.io/tokentxns?a=0x0000000000000000000000000000000000000000',
    'https://bscscan.com/tokentxns?a=0x0000000000000000000000000000000000000000');


  _AddressUrl: array [0 .. 1] of string = (
    'https://etherscan.io/address/',
    'https://bscscan.com/address/');

  _BaseUrl: array [0 .. 1] of string = (
    'https://etherscan.io',
    'https://bscscan.com');

implementation

uses dea.Tools;

function ApplicationName: string;
begin
  Result := 'FileToTelegram, ' + FormatFloat('0.0#', BuildNo);
end;

constructor TAppParams.Create;
begin
  AppName := ApplicationName;
  Channel := 0;

  fs := TFormatSettings.Create('en-US');
  fs.DecimalSeparator := '.';
  fs.ThousandSeparator := ',';
  fs.ShortTimeFormat := 'hh:nn:ss';
  fs.ShortDateFormat := 'yyyy-mm-dd';
end;

function TAppParams.AsJson: string;
begin
  Result := '{' +
    '"channel":' + Channel.ToString + ',' + CR +
    '"Site":' + Site.ToString + ',' + CR +
    '"Delay":' + Delay.ToString + ',' + CR +
    '"RepeatEvery":' + RepeatEvery.ToString + ',' + CR +
    '"RepeatTimes":' + RepeatTimes.ToString + ',' + CR +
    '"Scroll":' + BoolToStr(Scroll, true).ToLower + CR +
    '}';

end;

function TAppParams.GetMainUrl: string;
begin
  Result := _MainUrl[Site];
end;

function TAppParams.GetAddressUrl: string;
begin
  Result := _AddressUrl[Site];
end;

function TAppParams.GetBaseUrl: string;
begin
  Result := _BaseUrl[Site];
end;


end.