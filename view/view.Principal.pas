unit view.Principal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants, System.threading, System.generics.collections,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.Edit, FMX.StdCtrls, FMX.Layouts,
  FMX.ListBox, Controller.Cadastro, IdSMTP, FMX.Objects, FMX.ListView.Types,
  FMX.ListView.Appearances,
  FMX.ListView.Adapters.Base, FMX.ListView, FMX.Effects, FMX.Ani;

type
  TViewPrincipal = class(TForm)
    LayoutPrincipal: TLayout;
    LayoutTop: TLayout;
    LayoutBottom: TLayout;
    LayoutCenter: TLayout;
    GroupDados: TGroupBox;
    edtNome: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    edtIdentidade: TEdit;
    edtCPF: TEdit;
    edtTelefone: TEdit;
    edtEmail: TEdit;
    GroupEndereco: TGroupBox;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    edtCep: TEdit;
    edtLogradouro: TEdit;
    edtNumero: TEdit;
    edtComplemento: TEdit;
    edtBairro: TEdit;
    edtCidade: TEdit;
    edtEstado: TEdit;
    LayoutContentAll: TLayout;
    LayoutRight: TLayout;
    edtPais: TEdit;
    Rectangle1: TRectangle;
    Text1: TText;
    Rectangle2: TRectangle;
    Text2: TText;
    ListView1: TListView;
    ShadowEffect1: TShadowEffect;
    procedure edtCepChangeTracking(Sender: TObject);
    procedure Text1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FListaClientes: TObjectList<TCliente>;
    procedure validar;
    procedure Cadastrar;
    procedure LimparCampos;
    procedure BuscarCep;
    procedure EnviarEmail(pDestinatario: string);
    procedure RecebeEndereco(pEndereco: TEndereco);
    procedure updateListview;
  public
    { Public declarations }
  end;

var
  ViewPrincipal: TViewPrincipal;

implementation

{$R *.fmx}
{ TViewPrincipal }

procedure TViewPrincipal.BuscarCep;

begin
  TThread.CreateAnonymousThread(
    procedure
    var
      ControllerCadastro: iControllerCadastro;
    begin
      ControllerCadastro := TControllerCadastro.create;
      ControllerCadastro.ConsultarCep(strToInt(edtCep.Text), RecebeEndereco);
    end).Start;

end;

procedure TViewPrincipal.Cadastrar;
var
  LCliente: TCliente;
  LControllerCadastro: iControllerCadastro;
begin
  LCliente := TCliente.create;
  LControllerCadastro := TControllerCadastro.create;
  try
    LCliente.Nome := edtNome.Text;
    LCliente.Identidade := edtIdentidade.Text.ToInteger;
    LCliente.CPF := edtCPF.Text;
    LCliente.Telefone := edtTelefone.Text;
    LCliente.Email := edtEmail.Text;
    LCliente.Endereco.Cep := edtCep.Text;
    LCliente.Endereco.Logradouro := edtLogradouro.Text;
    LCliente.Endereco.Numero := edtNumero.Text.ToInteger;
    LCliente.Endereco.Complemento := edtComplemento.Text;
    LCliente.Endereco.Bairro := edtBairro.Text;
    LCliente.Endereco.Localidade := edtCidade.Text;
    LCliente.Endereco.UF := edtEstado.Text;
    LCliente.Endereco.Pais := edtPais.Text;
    LControllerCadastro.CriarXML(LCliente);
    EnviarEmail(edtEmail.Text);
    FListaClientes.Add(LCliente);
    updateListview;
  finally
    LimparCampos;
  end;
end;

procedure TViewPrincipal.edtCepChangeTracking(Sender: TObject);
begin
  if Length((Sender as TEdit).Text) = 8 then
    BuscarCep;
end;

procedure TViewPrincipal.EnviarEmail(pDestinatario: string);
var
  LControllerCadastro: iControllerCadastro;
begin
  LControllerCadastro := TControllerCadastro.create;
  LControllerCadastro.Email.setHost(satDefault, 465, 'smtp.gmail.com',
    
    'user@gmailcom', 'passgmail').setMessage('edenirpm@gmail.com',
    'Edenir P. Martins', pDestinatario, 'Dados do cliente cadastrado em Anexo')
    .send('Segue em anexo os dados do cliente cadastrado.', 'teste.xml');
end;

procedure TViewPrincipal.FormCreate(Sender: TObject);
begin
  FListaClientes := TObjectList<TCliente>.create;
end;

procedure TViewPrincipal.FormDestroy(Sender: TObject);
begin
  FListaClientes.DisposeOf;
end;

procedure TViewPrincipal.FormShow(Sender: TObject);
begin
  edtNome.SetFocus;
end;

procedure TViewPrincipal.LimparCampos;
var
  I: Integer;
begin
  for I := 0 to ComponentCount - 1 do
  begin
    if Components[I] is TEdit then
      TEdit(Components[I]).Text := EmptyStr;
  end;
  edtNome.SetFocus;
end;

procedure TViewPrincipal.RecebeEndereco(pEndereco: TEndereco);
begin
  TThread.Synchronize(nil,
    procedure
    begin
      edtLogradouro.Text := pEndereco.Logradouro;
      edtNumero.Text := pEndereco.Numero.ToString;
      edtComplemento.Text := pEndereco.Complemento;
      edtBairro.Text := pEndereco.Bairro;
      edtCidade.Text := pEndereco.Localidade;
      edtEstado.Text := pEndereco.UF;
      edtPais.Text := 'Brasil';
      edtNumero.SetFocus;
      pEndereco.DisposeOf;
    end);

end;

procedure TViewPrincipal.Text1Click(Sender: TObject);
begin
  validar;
  Cadastrar;
end;

procedure TViewPrincipal.updateListview;
var
  LCli: TCliente;
begin
  ListView1.Items.Clear;
  for LCli in FListaClientes do
  begin
    with ListView1.Items.Add do
    begin
      Data['Name'] := LCli.Nome;
      Data['Email'] := LCli.Email;
    end;
  end;
end;

procedure TViewPrincipal.validar;
begin
  if edtIdentidade.Text = EmptyStr then
    edtIdentidade.Text := '0';
  if edtCPF.Text = EmptyStr then
    edtCPF.Text := '0';
  if edtNumero.Text = EmptyStr then
    edtNumero.Text := '0';
end;

end.
