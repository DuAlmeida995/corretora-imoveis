from flask import Blueprint, jsonify, request, current_app
from serviços.auth import AuthDatabase
from serviços.email_service import EmailService


auth_blueprint = Blueprint("auth", __name__, url_prefix="/auth")

#faz o login do usuario no sistema, verifica CPF, senha, e retorna tokens de acesso
@auth_blueprint.route("/login", methods=["POST"])
def login():
    data = request.get_json()
    cpf = data.get("cpf")
    senha = data.get("password") 

    if not all([cpf, senha]):
        return jsonify({"error": "CPF e password são obrigatórios"}), 400

    auth_service = AuthDatabase()
    usuario = auth_service.validar_login(cpf, senha)

    if not usuario:
        return jsonify({"error": "Credenciais inválidas"}), 401

    try:
        secret_key = current_app.config['SECRET_KEY']
        access_token, refresh_token = auth_service.criar_tokens(
            cpf=usuario['cpf'],
            secret_key=secret_key
        )
    except Exception as e:
        return jsonify({"error": f"Erro ao gerar tokens: {e}"}), 500

    data_nasc = usuario.get('data_nasc')
    if data_nasc:
        usuario['dataNascimento'] = str(data_nasc) 
        del usuario['data_nasc'] 
    return jsonify({
        "user": usuario,
        "access_token": access_token,
        "refresh_token": refresh_token
    }), 200

#renova os tokens de acesso usando o refresh token quando o access token expira
@auth_blueprint.route("/refresh", methods=["POST"])
def refresh_token():
    data = request.get_json()
    token = data.get("refresh_token")

    if not token:
        return jsonify({"error": "Refresh token ausente"}), 401

    auth_service = AuthDatabase()
    secret_key = current_app.config['SECRET_KEY']

    novo_par = auth_service.renovar_tokens(token, secret_key)

    if not novo_par:
        return jsonify({"error": "Refresh token inválido ou expirado"}), 401

    access_token, refresh_token = novo_par

    return jsonify({
        "access_token": access_token,
        "refresh_token": refresh_token
    }), 200

#esta rota é a /auth/register 
#ela simplesmente reutiliza a lógica de criação de usuário já existente
@auth_blueprint.route("/register", methods=["POST"])
def register():
    print("\n--- INÍCIO LOG DE REGISTRO FLUTTER ---")
        
    data = request.get_json(silent=True) 
    
    if data is None:
            print("ERRO: Corpo da Requisição VAZIO ou NÃO É JSON válido.")
            print(f"Headers Recebidos: {request.headers}")
            return jsonify({"error": "Dados de registro ausentes ou inválidos."}), 400
    
    print(f"JSON RECEBIDO (DATA): {data}")
    print(f"CPF (Unmasked): {data.get('cpf')}")
    print(f"Telefones (Raw): {data.get('telefones')}")
    print(f"Tipo Proprietário: {data.get('proprietario')}")
    print("--- FIM LOG DE REGISTRO FLUTTER ---\n")
    
    try:
        from rotas.usuário import cria_usuário_completo
        return cria_usuário_completo()
    except Exception as e:
        return jsonify({"error": f"Erro ao processar registro: {e}"}), 500

#cria uma nova conta de usuario no sistema, reutiliza a lógica de criacao de usuario
@auth_blueprint.route("/request-otp", methods=["POST"])
def request_otp():
    """ Envia um código OTP para o email associado ao CPF. """
    data = request.get_json()
    cpf = data.get("cpf")

    if not cpf:
        return jsonify({"error": "CPF é obrigatório para solicitar o código."}), 400

    auth_service = AuthDatabase()
    email_service = EmailService()
    
    usuario_info = auth_service.get_user_email(cpf) 

    if not usuario_info or not usuario_info.get('email'):
        return jsonify({"message": "Solicitação processada. Verifique seu email."}), 200

    recipient_email = usuario_info.get('email')

    try:
        success = email_service.send_otp_email(cpf, recipient_email)

        if success:
            return jsonify({
                "message": "Código OTP enviado com sucesso para o email cadastrado.",
                "status": "sent"
            }), 200
        else:
            return jsonify({"error": "Falha ao enviar o código OTP. Tente mais tarde."}), 500
            
    except Exception as e:
        print(f"Erro ao enviar email/salvar OTP: {e}")
        return jsonify({"error": "Erro de servidor ao processar a solicitação de OTP."}), 500

#envia um codigo de verificacao por email para o usuario que esqueceu a senha
@auth_blueprint.route("/verify-otp", methods=["POST"])
def verify_otp():
    """ Verifica o código OTP recebido pelo usuário. """
    data = request.get_json()
    cpf = data.get("cpf")
    otp_code = data.get("otp_code")
    
    if not all([cpf, otp_code]):
        return jsonify({"error": "CPF e código OTP são obrigatórios."}), 400

    auth_service = AuthDatabase()
    is_valid = auth_service.validate_otp_code(cpf, otp_code) 

    if is_valid:
        return jsonify({
            "message": "Código OTP validado com sucesso.",
            "access_allowed": True
        }), 200
    else:
        return jsonify({"error": "Código OTP inválido ou expirado."}), 401

#verifica se o codigo OTP que o usuario recebeu esta correto e valido
@auth_blueprint.route("/reset-password", methods=["POST"])
def reset_password():
    """ Redefinição final da senha após a verificação do OTP. """
    data = request.get_json()
    cpf = data.get("cpf")
    otp_code = data.get("otp_code")
    new_password = data.get("new_password")
    
    if not all([cpf, otp_code, new_password]):
        return jsonify({"error": "Dados de redefinição incompletos."}), 400

    auth_service = AuthDatabase()
    
    is_valid = auth_service.validate_otp_code(cpf, otp_code) 
    
    if not is_valid:
        return jsonify({"error": "Sessão de redefinição inválida ou expirada."}), 401

    from utils.hash import gerar_hash_senha 
    new_password_hash = gerar_hash_senha(new_password)

    success = auth_service.update_user_password(cpf, new_password_hash) 

    if success:
        return jsonify({"message": "Senha redefinida com sucesso. Faça o login."}), 200
    else:
        return jsonify({"error": "Falha ao atualizar a senha no banco de dados."}), 500