unit tThreadLignesBR;

interface

uses
  Classes
  , UtilBTPVerdon
  , ConstServices
  , uTob
  , CbpMCD
  {$IFDEF MSWINDOWS}
  , Windows
  {$ENDIF}
  ;

type
  ThreadLignesBR = class(TThread)
  public
    LignesBRValues : T_LignesBRValues;
    LogValues      : T_WSLogValues;
    FolderValues   : T_FolderValues;

    constructor Create(CreateSuspended : boolean);
    destructor Destroy; override;
  private
    lTn : T_TablesName;
//    procedure SetName;
  protected
    procedure Execute; override;
  end;

implementation

uses
  CommonTools
  , SysUtils
  , hCtrls
  , hEnt1
  , StrUtils
  ;

{ Important : les m�thodes et propri�t�s des objets de la VCL peuvent uniquement �tre
  utilis�s dans une m�thode appel�e en utilisant Synchronize, comme : 

      Synchronize(UpdateCaption);

  o� UpdateCaption serait de la forme

    procedure ThreadLignesBR.UpdateCaption;
    begin
      Form1.Caption := 'Mis � jour dans un thread';
    end; }

{$IFDEF MSWINDOWS}
type
  TThreadNameInfo = record
    FType: LongWord;     // doit �tre 0x1000
    FName: PChar;        // pointeur sur le nom (dans l'espace d'adresse de l'utilisateur)
    FThreadID: LongWord; // ID de thread (-1=thread de l'appelant)
    FFlags: LongWord;    // r�serv� pour une future utilisation, doit �tre z�ro
  end;
{$ENDIF}

{ ThreadLignesBR }

(*
procedure ThreadLignesBR.SetName;
{$IFDEF MSWINDOWS}
var
  ThreadNameInfo: TThreadNameInfo;
{$ENDIF}
begin
{$IFDEF MSWINDOWS}
  ThreadNameInfo.FType := $1000;
  ThreadNameInfo.FName := 'ThreadNameLignesBR';
  ThreadNameInfo.FThreadID := $FFFFFFFF;
  ThreadNameInfo.FFlags := 0;

  try
    RaiseException( $406D1388, 0, sizeof(ThreadNameInfo) div sizeof(LongWord), @ThreadNameInfo );
  except
  end;
{$ENDIF}
end;
*)

constructor ThreadLignesBR.Create(CreateSuspended: boolean);
begin
  inherited Create(CreateSuspended);
  FreeOnTerminate := True;
  Priority        := tpNormal;
  lTn             := tnLignesBR;
end;

destructor ThreadLignesBR.Destroy;
begin
  inherited;
  TUtilBTPVerdon.AddLog(lTn, TUtilBTPVerdon.GetMsgStartEnd(lTn, False, LignesBRValues.LastSynchro), LogValues, 0);
end;

procedure ThreadLignesBR.Execute;
var
  TobT      : TOB;
  TobQry    : TOB;
  AdoQryL   : AdoQry;
  Treatment : TTnTreatment;
begin
//  SetName;
  TUtilBTPVerdon.AddLog(lTn, '', LogValues, 0);
  TUtilBTPVerdon.AddLog(lTn, DupeString('*', 50), LogValues, 0);
  if (LogValues.DebugEvents > 0) then
    TUtilBTPVerdon.AddLog(lTn, Format('%sThreadTiers.Execute / BTPSrv=%s, BTPFolder=%s, TMPSrv=%s, TMPFolder=%s', [WSCDS_DebugMsg, FolderValues.BTPServer, FolderValues.BTPDataBase, FolderValues.TMPServer, FolderValues.TMPDataBase]), LogValues, 0);
  TUtilBTPVerdon.AddLog(lTn, TUtilBTPVerdon.GetMsgStartEnd(lTn, True, LignesBRValues.LastSynchro), LogValues, 0);
  TobQry := TOB.Create('_QRY', nil, -1);
  try
    TobT := TOB.Create('_DEVIS', nil, -1);
    try
      AdoQryL := AdoQry.Create;
      try
        AdoQryL.ServerName  := FolderValues.TMPServer;
        AdoQryL.DBName      := FolderValues.TMPDataBase;
        AdoQryL.PgiDB       := '-';
        Treatment := TTnTreatment.Create;
        try
          Treatment.Tn           := lTn;
          Treatment.FolderValues := FolderValues;
          Treatment.LogValues    := LogValues;
          Treatment.LastSynchro  := LignesBRValues.LastSynchro;
          Treatment.TnTreatment(TobT, TobQry, AdoQryL);
        finally
          Treatment.Free;
        end;
      finally
        AdoQryL.free;
      end;
    finally
      FreeAndNil(TobT);
    end;
  finally    
    FreeAndNil(TobQry);
  end;
end;

end.
