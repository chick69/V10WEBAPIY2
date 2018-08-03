unit tThreadDevis;

interface

uses
  Classes
  , UtilBTPVerdon
  , ConstServices
  {$IFDEF MSWINDOWS}
  , Windows
  {$ENDIF}
  ;

type
  ThreadDevis = class(TThread)
  public
    DevisValues  : T_DevisValues;
    LogValues    : T_WSLogValues;
    FolderValues : T_FolderValues;

    constructor Create(CreateSuspended : boolean);
    destructor Destroy; override;

  private
    lTn : T_TablesName;
//    procedure SetName;
  protected
    procedure Execute; override;
  end;

implementation

{ Important : les m�thodes et propri�t�s des objets de la VCL peuvent uniquement �tre
  utilis�s dans une m�thode appel�e en utilisant Synchronize, comme : 

      Synchronize(UpdateCaption);

  o� UpdateCaption serait de la forme

    procedure ThreadDevis.UpdateCaption;
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

{ ThreadDevis }

(*
procedure ThreadDevis.SetName;
{$IFDEF MSWINDOWS}
var
  ThreadNameInfo: TThreadNameInfo;
{$ENDIF}
begin
{$IFDEF MSWINDOWS}
  ThreadNameInfo.FType := $1000;
  ThreadNameInfo.FName := 'ThreadNameDevis';
  ThreadNameInfo.FThreadID := $FFFFFFFF;
  ThreadNameInfo.FFlags := 0;

  try
    RaiseException( $406D1388, 0, sizeof(ThreadNameInfo) div sizeof(LongWord), @ThreadNameInfo );
  except
  end;
{$ENDIF}
end;
*)

constructor ThreadDevis.Create(CreateSuspended: boolean);
begin
  inherited Create(CreateSuspended);
  FreeOnTerminate := True;
  Priority        := tpNormal;
  lTn             := tnDevis;
end;

destructor ThreadDevis.Destroy;
begin
  inherited;
  TUtilBTPVerdon.AddLog(lTn, TUtilBTPVerdon.GetMsgStartEnd(lTn, False, DevisValues.LastSynchro), LogValues, 0);
end;

procedure ThreadDevis.Execute;
begin
//  SetName;
  try
    TUtilBTPVerdon.AddLog(lTn, TUtilBTPVerdon.GetMsgStartEnd(lTn, True, DevisValues.LastSynchro), LogValues, 0);
    TUtilBTPVerdon.SetLastSynchro(lTn);
  except
  end;
end;

end.
