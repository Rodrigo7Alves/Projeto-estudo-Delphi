unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Imaging.pngimage, Vcl.ExtCtrls,
  Vcl.Imaging.jpeg, Vcl.StdCtrls, Vcl.Menus, Vcl.ComCtrls;

type
  TfrmMain = class(TForm)
    Image1: TImage;
    imgProdutos: TImage;
    lblCadCliente: TLabel;
    lblCadProdutos: TLabel;
    imgVendas: TImage;
    lblVenda: TLabel;
    MainMenu1: TMainMenu;
    StatusBar1: TStatusBar;
    Cliente1: TMenuItem;
    Produtos1: TMenuItem;
    Venda1: TMenuItem;
    Cadastro1: TMenuItem;
    Cadastro2: TMenuItem;
    Image2: TImage;
    procedure Image1Click(Sender: TObject);
    procedure imgProdutosClick(Sender: TObject);
    procedure imgVendasClick(Sender: TObject);
    procedure Cliente1Click(Sender: TObject);
    procedure Produtos1Click(Sender: TObject);
    procedure Venda1Click(Sender: TObject);
    procedure Cadastro1Click(Sender: TObject);
    procedure Cadastro2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

uses Cliente, Produtos, Vendas;

procedure TfrmMain.Cadastro1Click(Sender: TObject);
begin
  frmCliente.ShowModal;
end;

procedure TfrmMain.Cadastro2Click(Sender: TObject);
begin
  frmProdutos.ShowModal;
end;

procedure TfrmMain.Cliente1Click(Sender: TObject);
begin
  //frmCliente.ShowModal;
end;

procedure TfrmMain.FormShow(Sender: TObject);
begin
    StatusBar1.Panels[1].Text := 'Data: ' + DatetoStr(Date);
    StatusBar1.Panels[2].Text := 'Hora: ' + TimetoStr(Time);
end;

procedure TfrmMain.Image1Click(Sender: TObject);
begin
  frmCliente.ShowModal;
end;

procedure TfrmMain.imgProdutosClick(Sender: TObject);
begin
  frmProdutos.ShowModal;
end;

procedure TfrmMain.imgVendasClick(Sender: TObject);
begin
  frmVendas.ShowModal;
end;

procedure TfrmMain.Produtos1Click(Sender: TObject);
begin
   //frmProdutos.ShowModal;
end;

procedure TfrmMain.Venda1Click(Sender: TObject);
begin
   frmVendas.ShowModal;
end;

end.
