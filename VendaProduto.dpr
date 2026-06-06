program VendaProduto;

uses
  Vcl.Forms,
  Main in 'Main.pas' {frmMain},
  dmDados in 'dmDados.pas' {dm: TDataModule},
  Cliente in 'Cliente.pas' {frmCliente},
  Produtos in 'Produtos.pas' {frmProdutos},
  Vendas in 'Vendas.pas' {frmVendas};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(Tdm, dm);
  Application.CreateForm(TfrmCliente, frmCliente);
  Application.CreateForm(TfrmProdutos, frmProdutos);
  Application.CreateForm(TfrmVendas, frmVendas);
  Application.Run;
end.
