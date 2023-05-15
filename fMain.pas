unit fMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  PropFilerEh, PropStorageEh, sSkinManager, sSkinProvider,
  System.UITypes, Cromis.SimpleLog, System.StrUtils,
  uConst, uParams, dea.Status,
  TelegaPi.Types.Enums,
  Vcl.StdCtrls, sButton, Vcl.ExtCtrls, sPanel, Vcl.ComCtrls, sStatusBar, acProgressBar,
  System.Actions, Vcl.ActnList, sPageControl, sComboBox, Vcl.Mask, sMaskEdit, sCustomComboEdit,
  sEdit, sToolEdit, CloudAPI.BaseComponent, TelegaPi.Bot,
  Cromis.DirectoryWatch, sMemo;

type
  TMainForm = class(TForm)
    sSkinProvider1: TsSkinProvider;
    sSkinManager1: TsSkinManager;
    PropStorageEh1: TPropStorageEh;
    TopPanel: TsPanel;
    StartButton: TsButton;
    StopButton: TsButton;
    ProgressBar2: TsProgressBar;
    StatusBar1: TsStatusBar;
    ActionList1: TActionList;
    sPageControl: TsPageControl;
    tsSettings: TsTabSheet;
    tsLog: TsTabSheet;
    TestTelegramButton: TsButton;
    ChannelEdit: TsEdit;
    DirectoryEdit: TsDirectoryEdit;
    TelegramBot1: TTelegramBot;
    LogMemo: TsMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure StartButtonClick(Sender: TObject);
    procedure StopButtonClick(Sender: TObject);
    procedure OnChangeControls(Sender: TObject);
    procedure TestTelegramButtonClick(Sender: TObject);
  protected
    AppParam: TAppParams;
  private
    DirectoryWatch: TDirectoryWatch;
    procedure EnableButtons(AEnable: Boolean);
    procedure UpdateParams;
    procedure OnError(const Sender: TObject; const ErrorCode: Integer;
      const ErrorMessage: string);
    procedure OnNotify(const Sender: TObject; const Action: TWatchAction;
      const FileName: string);

  public
    function TelegramMessage(aText: string; Group: string; toLog: Boolean = False;
      PhotoLink: string = ''): Boolean;
  end;

var
  MainForm: TMainForm;

implementation

uses
  dea.Tools, dea.debug, dea.cl;

{$R *.dfm}


procedure TMainForm.EnableButtons(AEnable: Boolean);
begin
  StartButton.Enabled := AEnable;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  Application.UpdateFormatSettings := False;
  FormatSettings.DecimalSeparator := '.';
  utc_offset := OffsetUTC2;

  AppParam := TAppParams.Create;

  MainForm.Caption := AppParam.AppName;

  SimpleLog.RegisterLog('log', WorkingPath + main_log, 2000, 5, [lpTimestamp, lpType]);
  SimpleLog.LockType := ltProcess; // ltMachine, ltNone;
  Log('start ' + AppParam.AppName + ' - - - - - - - - - - - - - - - - -');

  StopButton.Visible := False;
  ProgressBar2.Position := 0;
  ProgressBar2.Step := 1;
  Status.Bind(StatusBar1, StopButton, 1);
  Status.Bind(StatusBar1, ProgressBar2, 2);
{$WARN SYMBOL_PLATFORM OFF}
  // SaveStringOn := DebugHook <> 0;
{$WARN SYMBOL_PLATFORM ON}
  DirectoryWatch := TDirectoryWatch.Create;
  DirectoryWatch.WatchSubTree := False;
  DirectoryWatch.OnNotify := OnNotify;
  DirectoryWatch.OnError := OnError;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  Log('finish');
  AppParam.Free;
  FreeAndNil(DirectoryWatch);
end;

procedure xLog(const s: string); overload;
begin
  if MainForm.LogMemo.Lines.Count > 5000 then
    MainForm.LogMemo.Lines.Clear;
  MainForm.LogMemo.Lines.Add(FormatDateTime('hh:nn:ss', Now) + ' ' + s);
  Log(s);
end;

procedure TMainForm.StartButtonClick(Sender: TObject);
begin
  Status.Stopped := False;
  EnableButtons(False);
  StopButton.Visible := true;
  try
    UpdateParams;
    Log('AppParam = ' + AppParam.AsJson);
    sPageControl.ActivePage := tsLog;
    DirectoryWatch.Start;
  finally
  //  Status.Update('ok');
  //  StopButton.Visible := False;
  //  EnableButtons(true);
  end;
end;

procedure TMainForm.StopButtonClick(Sender: TObject);
begin
  EnableButtons(true);
  Status.Stopped := true;
  StopButton.Visible := False;

  DirectoryWatch.Stop;
end;

procedure TMainForm.OnChangeControls(Sender: TObject);
begin
  UpdateParams;
end;

procedure TMainForm.TestTelegramButtonClick(Sender: TObject);
begin
  TelegramMessage(AppParam.AppName, AppParam.Channel, true);
  // TestTelegramHelper(AppParam.AppName, TelegramNoComboBox.ItemIndex);
end;

procedure TMainForm.UpdateParams;
begin
  AppParam.Channel := Trim(ChannelEdit.Text);
  AppParam.Folder := NormalDir(Trim(DirectoryEdit.Text));
  DirectoryWatch.Directory := AppParam.Folder;
end;

// обработка ошибок
procedure TMainForm.OnError(const Sender: TObject; const ErrorCode: Integer;
  const ErrorMessage: string);
begin
  Log(Format('Error %d : %s', [ErrorCode, ErrorMessage]));
end;

// событие и им€ файла/папки
procedure TMainForm.OnNotify(const Sender: TObject; const Action: TWatchAction;
  const FileName: string);
begin
  if Action <> waAdded then
    exit;
  xLog(FileName);
  if TelegramMessage(FileName + CR + AppParam.AppName,
    AppParam.Channel, true) then
    DeleteFile(AppParam.Folder + FileName);
end;

// бот CryptoCompare2 Tracker должен быть добавлен в канал
function TMainForm.TelegramMessage(aText: string; Group: string; toLog: Boolean = False;
  PhotoLink: string = ''): Boolean;
var
  s: string;
  TelegramBot1: TTelegramBot;
begin
  if toLog then begin
    Log('<-- Telegram --> ch. ' + Group + CR + { HTMLStrip( } aText + CR + ' ХХХ');
  end;

  TelegramBot1 := TTelegramBot.Create('741395383:AAGWbxzSEcjbfav2QHZkR6fZMV_6hQ70j3w');
  try
    try
      s := iif(aText = '', ExtractFileName(PhotoLink), HTMLStrip(copy(aText, 1, 200)));
      Status.Update('~> ' + s);
      if PhotoLink <> '' then
        TelegramBot1.SendPhoto(Group.ToInt64, PhotoLink, aText, TtgParseMode.Html, true)
      else
        TelegramBot1.SendMessage(Group.ToInt64, aText, TtgParseMode.Html,
          true { запрет на вставку фрагмента сайта по указанной ссылке } );
      Status.Update('-> ' + s);

      Result := true;
    except
      on E: Exception do begin
        Result := False;
        Log('ошибка отправки в телеграм ' + Group + ': ' + E.Message);
        Status.Update('ошибка telegram: ' + E.Message);
      end;
    end;
  finally
    TelegramBot1.Free;
  end;
end;

initialization

SetDefStorage;

end.
