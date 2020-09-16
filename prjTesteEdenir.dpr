program prjTesteEdenir;

uses
  System.StartUpCopy,
  FMX.Forms,
  view.Principal in 'view\view.Principal.pas' {ViewPrincipal},
  model.Cliente in 'model\model.Cliente.pas',
  model.Endereco in 'model\model.Endereco.pas',
  model.ViaCep in 'model\model.ViaCep.pas',
  Controller.Cadastro in 'controller\Controller.Cadastro.pas',
  Datamodule.Cadastro in 'Dao\Datamodule.Cadastro.pas' {DmCadastro: TDataModule},
  model.XML.Cliente in 'model\model.XML.Cliente.pas',
  model.Email in 'model\model.Email.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TViewPrincipal, ViewPrincipal);
  Application.CreateForm(TDmCadastro, DmCadastro);
  Application.Run;
end.
