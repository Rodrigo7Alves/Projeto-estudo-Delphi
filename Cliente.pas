unit Cliente;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Data.DB, Vcl.Grids,
  Vcl.DBGrids, Vcl.Imaging.pngimage, Vcl.ExtCtrls, Vcl.Imaging.jpeg;

type
  TfrmCliente = class(TForm)
    Label1: TLabel;
    edtNome: TEdit;
    btnSalvar: Tbutton;
    btnExcluir: Tbutton;
    btnAtualizar: Tbutton;
    dbCliente: TDBGrid;
    Image1: TImage;
    procedure btnSalvarClick(Sender: TObject);
    procedure btnAtualizarClick(Sender: TObject);
    procedure btnExcluirClick(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmCliente: TfrmCliente;

implementation

{$R *.dfm}

uses dmDados;

procedure TfrmCliente.btnAtualizarClick(Sender: TObject);
begin

  if Application.MessageBox('Deseja Atualizar?', 'Atenção', 4 + MB_ICONEXCLAMATION)= IDYES  then
  Begin
  with dm.stAtualizaCliente do
  begin
    close;
    parambyname('@id').Value := dbCliente.Fields[0].Value;
    parambyname('@nome').Value:= dbCliente.Fields[1].Value;
    ExecProc;
  end;

    with dm.qryClienets do
    begin
      close;
      open;
    end;
  end
  else
    Application.MessageBox('Ação Cancelada', 'Atenção', MB_ICONEXCLAMATION);

end;

procedure TfrmCliente.btnExcluirClick(Sender: TObject);
begin
  if Application.MessageBox('Deseja Excluir','Atenção',
  4 + MB_ICONEXCLAMATION)= IDYES then

begin
  with dm.stExcluiCliente do
  begin
    close;
    parambyname('@id').Value := dbCliente.Fields[0].Value;
    ExecProc;
  end;

  with dm.qryClienets do
  begin
    close;
    open;
  end;

end
else
  Application.MessageBox('Ação cancelada', 'Atenção' , MB_ICONEXCLAMATION );

end;

procedure TfrmCliente.btnSalvarClick(Sender: TObject);
begin
  if Application.MessageBox('Deseja Salavar', 'Atenção', 4 + MB_ICONEXCLAMATION)= IDYES  then
  begin

  with dm.stInsereCliente do
  begin
    close;
    parambyname('@nome').Value := edtnome.Text;
    ExecProc;
  end;

  with dm.qryClienets do
  begin
    close;
    open;
  end;

  edtNome.Clear; // Apaga os dados da edtNome
  end
  else
    Application.MessageBox('Ação Cancelada', 'Atenção', MB_ICONEXCLAMATION);


end;

end.
