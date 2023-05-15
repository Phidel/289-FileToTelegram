unit fMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  PropFilerEh, PropStorageEh, sSkinManager, sSkinProvider,
  System.UITypes, Cromis.SimpleLog, System.StrUtils,
  uConst, uParams, dea.Status,
  Vcl.StdCtrls, sButton, Vcl.ExtCtrls, sPanel, Vcl.ComCtrls, sStatusBar, acProgressBar,
  System.Actions, Vcl.ActnList, sPageControl, sComboBox, Vcl.Mask, sMaskEdit, sCustomComboEdit;

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
    tsMain: TsTabSheet;
    TelegramNoComboBox: TsComboBox;
    TestTelegramButton: TsButton;
    SendLogsToTelegramButton: TsButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure StartButtonClick(Sender: TObject);
    procedure StopButtonClick(Sender: TObject);
    procedure OnChangeControls(Sender: TObject);
    procedure SendLogsToTelegramButtonClick(Sender: TObject);
    procedure TestTelegramButtonClick(Sender: TObject);
  protected
    AppParam: TAppParams;
  private
    AlreadyRun: Boolean;
    procedure EnableButtons(AEnable: Boolean);
    procedure DoWork;
    procedure UpdateParams;
  public
  end;

var
  MainForm: TMainForm;

implementation

uses
  dea.Tools, dea.debug
    , dea.cl
    , dea.TelegramHelper;

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
  AlreadyRun := False;

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
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  Log('finish');
  AppParam.Free;
end;

procedure TMainForm.StartButtonClick(Sender: TObject);
begin
  Status.Stopped := False;
  EnableButtons(False);
  StopButton.Visible := true;
  ProgressBar2.Position := 0;
  ProgressBar2.Visible := true;
  try
    UpdateParams;
    log('AppParam = ' + AppParam.AsJson);
    DoWork;
  finally
    Status.Update('ok');
    ProgressBar2.Visible := False;
    StopButton.Visible := False;
    EnableButtons(true);
  end;
end;

procedure TMainForm.StopButtonClick(Sender: TObject);
begin
  Status.Stopped := true;
  StopButton.Visible := False;
  Log('Прервано пользователем');
end;

procedure TMainForm.DoWork;
begin
  if AlreadyRun then
    exit;
  AlreadyRun := true;
  Screen.Cursor := crHourGlass;
  try

  finally
    AlreadyRun := False;
    Screen.Cursor := crDefault;
  end;
end;

procedure TMainForm.OnChangeControls(Sender: TObject);
begin
  UpdateParams;
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  RunTelegramHelper;
end;

procedure TMainForm.SendLogsToTelegramButtonClick(Sender: TObject);
begin
  TelegramHelperSendLogs(AppParam.AppName, TelegramGroupCrypto);
end;

procedure TMainForm.TestTelegramButtonClick(Sender: TObject);
begin
  TestTelegramHelper(AppParam.AppName, TelegramNoComboBox.ItemIndex);
end;

procedure TMainForm.UpdateParams;
begin
  AppParam.Channel := TelegramNoComboBox.ItemIndex;
end;


initialization

SetDefStorage;

end.
