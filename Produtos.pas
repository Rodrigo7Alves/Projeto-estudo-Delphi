unit Produtos;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.Grids, Vcl.DBGrids,
  Vcl.Samples.Spin, Vcl.StdCtrls, Vcl.Imaging.pngimage, Vcl.ExtCtrls,
  Vcl.Imaging.jpeg;

type
  TfrmProdutos = class(TForm)
    btnExcluir: TButton;
    btnAtualizar: TButton;
    btnSalvar: TButton;
    lblNomeProduto: TLabel;
    edtNome: TEdit;
    lblQuantidade: TLabel;
    lblValor: TLabel;
    edtQtd: TSpinEdit;
    edtValor: TEdit;
    dbProdutos: TDBGrid;
    Image1: TImage;
    procedure btnSalvarClick(Sender: TObject);
    procedure btnAtualizarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnExcluirClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmProdutos: TfrmProdutos;

implementation

{$R *.dfm}

uses dmDados;

procedure TfrmProdutos.btnAtualizarClick(Sender: TObject);
begin
    if Application.MessageBox('Deseja Atualizar', 'Atenção',
     4 + MB_ICONEXCLAMATION)= IDYES  then
  begin

    with dm,stAtualizaProduto do
    begin
      Close;
      paramByName('@id').Value := dbProdutos.Fields[0].Value;
      paramByName('@nome').Value := dbProdutos.Fields[1].Value;
      paramByName('@qtd').Value := dbProdutos.Fields[2].Value;
      paramByName('@vl').Value := dbProdutos.Fields[3].Value;
      execProc;
    end;

    with dm.qryProdutos do
    begin
      Close;
      Open;
    end;


    edtNome.Clear;
    edtQtd.Clear;
    edtValor.Clear; // Apaga os dados da edtNome
  end
  else
    Application.MessageBox('Ação Cancelada', 'Atenção', MB_ICONEXCLAMATION);
end;

procedure TfrmProdutos.btnExcluirClick(Sender: TObject);
begin
  if Application.MessageBox('Deseja Excluir Produto?', 'Atenção',
     4 + MB_ICONEXCLAMATION)= IDYES  then
  begin

    with dm,stExcluiProduto do
    begin
      Close;
      paramByName('@id').Value := dbProdutos.Fields[0].Value;
      execProc;
    end;

    with dm.qryProdutos do
    begin
      Close;
      Open;
    end;
  end
  else
    Application.MessageBox('Ação Cancelada', 'Atenção', MB_ICONEXCLAMATION);

end;

procedure TfrmProdutos.btnSalvarClick(Sender: TObject);
begin
    if Application.MessageBox('Deseja Salavar', 'Atenção',
     4 + MB_ICONEXCLAMATION)= IDYES  then
  begin

    with dm,stInsereProduto do
    begin
      Close;
      paramByName('@nome').Value :=edtNome.Text;
      paramByName('@qtd').Value :=edtQtd.Text;
      paramByName('@vl').Value :=edtValor.Text;
      execProc;
    end;

    with dm.qryProdutos do
    begin
      Close;
      Open;
    end;


    edtNome.Clear;
    edtQtd.Clear;
    edtValor.Clear; // Apaga os dados da edtNome
  end
  else
    Application.MessageBox('Ação Cancelada', 'Atenção', MB_ICONEXCLAMATION);

end;

procedure TfrmProdutos.FormShow(Sender: TObject);
begin
  with dm.qryProdutos do
  begin
    close;
    open;
  end;
end;

end.
