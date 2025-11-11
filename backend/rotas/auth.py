from flask import Blueprint, jsonify, request, current_app
from serviços.auth import AuthDatabase


auth_blueprint = Blueprint("auth", __name__, url_prefix="/auth")

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
        "user": usuario, #contem prenome, sobrenome, email, cpf, etc.
        "access_token": access_token,
        "refresh_token": refresh_token
    }), 200


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
    try:
        from rotas.usuário import cria_usuário_completo
        return cria_usuário_completo()
    except Exception as e:
        return jsonify({"error": f"Erro ao processar registro: {e}"}), 500