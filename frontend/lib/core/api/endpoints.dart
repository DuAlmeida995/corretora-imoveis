// lib/core/api/endpoints.dart

class Endpoints {
  // Rotas de Autenticação
  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String authRequestOtp = '/auth/request-otp';
  static const String authVerifyOtp = '/auth/verify-otp';
  static const String authResetPassword = '/auth/reset-password';
  static const String authRefreshToken = '/auth/refresh';

  // Rotas de Gestão de Imóveis
  static const String imoveisList = '/imoveis';
  static const String imoveisRegister = '/imoveis/cadastro';
  static const String imoveisUploadFotos = '/imoveis/upload_fotos';
  static const String imoveisGetDetail = '/imoveis/';
  static const String imoveisUpdate = '/imoveis/update';
  static const String imoveisFilters = '/imoveis/filtro';

  // Rotas de Proprietários
  static const String proprietariosList = '/proprietarios';
  static const String proprietarioUpdate = '/proprietarios/update';

  // Rotas de Adquirentes
  static const String adquirentesList = '/adquirentes';
  static const String adquirentesUpdate = '/adquirentes/update';

  // Rotas de Usuário
  static const String usuarioCadastro = '/usuario/cadastro';
  static const String usuarioCadastroCliente = '/usuario/cadastro-cliente';
  static const String usuarioTelefone = '/usuario/telefones';
  static const String usuarioDeleta = '/usuario/deleta';
  static const String usuarioPerfisImoveis = '/usuario/perfis-imoveis';
  static const String usuarioImoveisProprietario =
      '/usuario/imoveis-proprietario';
  static const String userUpdateProfile = '/usuario/perfil/update';
  static const String userUploadPicture = '/usuario/upload_foto_perfil';

  // Rotas de Pagamentos
  static const String pagamentosCadastro = '/pagamento/cadastro';
  static const String pagamentosStatus = '/pagamento/status';
  static const String pagamentosAtualizaStatus = '/pagamento/atualiza_status';
  static const String pagamentosExtratoImovel = '/pagamento/extrato-imovel';
  static const String pagamentosExtratoAdquirente =
      '/pagamento/extrato-adquirente';

  // Rotas de Contrato
  static const String contratoPrazo = '/contratos/prazo';
  static const String contratoCadastro = '/contratos/cadastro';
  static const String contratoDeletar = '/contratos/deleta';
  static const String contratoAlterarStatus = '/contratos/alterar-status';
  static const String contratoObterPeriodoAluguel =
      '/contratos/obter-periodo-aluguel';

  // Contrato de Consulta de Contrato
  static const String contratosAtivos = '/contratos/ativos';
  static const String contratosVencendo = '/contratos/vencendo';
  static const String contratosAtrasados = '/contratos/atrasados';
  static const String contratosList = '/contratos';
  static const String contratosDashboard = '/contratos/dashboard';
  static const String contratoValoresImovel = '/contratos/obter-valores-imovel';
  static const String contratoMaisAlugados = '/contratos/obter-mais-alugados';
  static const String contratoPessoasImovel = '/contratos/obter-pessoas-imovel';
}
