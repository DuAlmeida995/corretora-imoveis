from datetime import datetime
from flask import Blueprint, jsonify, request, url_for
from serviços.usuário import UsuárioDatabase
from utils.hash import gerar_hash_senha 
from utils.token_middleware import token_obrigatorio
from werkzeug.utils import secure_filename
import os

usuário_blueprint = Blueprint("usuario", __name__)

@usuário_blueprint.route("/usuario/cadastro", methods=["POST"])
def cria_usuário_completo(): #cadastra um usuário, seus eventuais tipos e seus eventuais números de telefone(aqui vc passa uma lista separada por vírgula)
    json = request.get_json()
    cpf = json.get("cpf")
    prenome = json.get("prenome")
    sobrenome = json.get("sobrenome")
    data_nasc_str = json.get("data_nasc")
    email = json.get("email")
    senha = json.get("senha") 
    tel_usuario = json.get("telefones") #aqui vc passa uma lista separada por vírgula
    proprietario = json.get("proprietario")  #opcional, só se for proprietário
    adquirente = json.get("adquirente")  #opcional, só se for adquirente
    corretor = json.get("corretor")  #opcional, só se for corretor
    pontuacao_credito = json.get("pontuacao_credito")  #opcional, só se for adquirente
    especialidade = json.get("especialidade")  #opcional, só se for corretor
    creci = json.get("creci")  #opcional, só se for corretor
    regiao_atuação = json.get("regiao_atuacao")  #opcional, só se for corretor

    if not all([cpf, prenome, sobrenome, data_nasc_str, email, senha, tel_usuario]):
        return jsonify("Todos os campos (cpf, prenome, sobrenome, data_nasc, email, senha, telefones) sao obrigatorios"), 400
    
    if len(senha) < 6:
        return jsonify("A senha deve ter pelo menos 6 dígitos."), 400
    
    if proprietario is False and adquirente is False and corretor is False:
        return jsonify("E necessario selecionar ao menos um tipo de usuario (proprietario, adquirente ou corretor)."), 400
    
    try:
        data_nasc_obj = datetime.strptime(data_nasc_str, '%Y-%m-%d').date() # Converte a string "YYYY-MM-DD" em um objeto 'date'
    except (ValueError, TypeError):
        return jsonify({"erro": "Formato de data invalido. Use YYYY-MM-DD"}), 400
    
    db_service = UsuárioDatabase()

    try:
        db_service.insere_usuário(
            cpf,
            prenome,
            sobrenome, 
            data_nasc_obj,
            email
        )
    except Exception as e_usuário:
        return jsonify("Nao foi possivel criar usuario."), 400
    
    try:
        hash_da_senha = gerar_hash_senha(senha)  #gera o hash da senha
        db_service.insere_login(cpf, hash_da_senha) #salva o hash no banco de dados
    except Exception as e_login:
        db_service.deleta_usuário(cpf) #se der erro ao criar o login, desfaz o cadastro do usuário
        return jsonify(f"Nao foi possivel criar o login (verifique se o 'ALTER TABLE' foi feito). Cadastro desfeito. Erro: {e_login}"), 400

    try:
        db_service.insere_lista_tel_usuário(
            cpf,
            tel_usuario
        )

    except Exception as e_telefone:
        try:
            db_service.deleta_usuário(cpf)
            return jsonify("Problema: nao foi possivel inserir o telefone, cadastro de usuario desfeito."), 400
        except Exception as e_deleção:  
            return jsonify("Problema: nao foi possivel inserir o telefone e tambem nao foi possivel deletar o usuario."), 400
        
    try:
        if proprietario:
            registro1=db_service.insere_proprietário(cpf)
            if not registro1:
                return jsonify("Nao foi possivel cadastrar como proprietario."), 400
        if adquirente:
            registro2 = db_service.insere_adquirente(cpf, pontuacao_credito)
            if not registro2:
                return jsonify("Nao foi possivel cadastrar como adquirente."), 400
        if corretor:
            if not creci:
                return jsonify("Creci e obrigatorio para cadastramento como corretor."), 400
            registro3 = db_service.insere_corretor(cpf, especialidade, creci, regiao_atuação)
            if not registro3:
                return jsonify("Nao foi possivel cadastrar como corretor."), 400
        return jsonify({"message": "Cadastro realizado com sucesso."}), 200
    except Exception as e_tipo:
        try:
            db_service.deleta_usuário(cpf)
            return jsonify("Problema: nao foi possivel inserir o tipo, cadastro de usuario desfeito."), 400
        except Exception as e_deleção2:  
            return jsonify("Problema: nao foi possivel inserir o tipo de usuario e tambem nao foi possivel deletar o usuario."), 400

@usuário_blueprint.route("/usuario/cadastro-cliente", methods=["POST"])
@token_obrigatorio
def cadastra_cliente_pelo_corretor():
    json = request.get_json()
    
    cpf = json.get("cpf")
    prenome = json.get("prenome")
    sobrenome = json.get("sobrenome")
    data_nasc_str = json.get("data_nasc")
    email = json.get("email")
    tel_usuario = json.get("telefones")
    
    proprietario = json.get("proprietario", False)
    adquirente = json.get("adquirente", False)
    
    pontuacao_credito = json.get("pontuacao_credito") 
    
    if not all([cpf, prenome, sobrenome, data_nasc_str, email, tel_usuario]):
        return jsonify({"error": "Todos os campos (cpf, nome, nascimento, email, telefone) são obrigatórios."}), 400
    
    if not proprietario and not adquirente:
        return jsonify({"error": "O cadastro deve ser classificado como Proprietário, Adquirente ou ambos."}), 400

    if json.get("corretor") is True:
        return jsonify({"error": "Esta rota é exclusiva para clientes. Para cadastrar corretores, use a rota de registro principal."}), 403

    try:
        data_nasc_obj = datetime.strptime(data_nasc_str, '%Y-%m-%d').date()
    except (ValueError, TypeError):
        return jsonify({"error": "Formato de data inválido. Use YYYY-MM-DD"}), 400
    
    db_service = UsuárioDatabase()

    try:
        db_service.insere_usuário(cpf, prenome, sobrenome, data_nasc_obj, email)
    except Exception as e:
        return jsonify({"error": f"Erro ao criar usuário (CPF pode já estar cadastrado): {str(e)}"}), 400
    
    try:
        sucesso_tel = db_service.insere_lista_tel_usuário(cpf, tel_usuario)
        if not sucesso_tel:
             raise Exception("Falha na validação ou inserção dos telefones.")
    except Exception as e:
        db_service.deleta_usuário(cpf) # Rollback manual se falhar telefone
        return jsonify({"error": f"Erro ao cadastrar telefones: {str(e)}"}), 400

    try:
        if proprietario:
            db_service.insere_proprietário(cpf)
            
        if adquirente:
            score = pontuacao_credito if pontuacao_credito else 0
            db_service.insere_adquirente(cpf, score)
            
        return jsonify({
            "message": "Cliente cadastrado com sucesso.",
        }), 200
        
    except Exception as e:
        db_service.deleta_usuário(cpf)
        return jsonify({"error": f"Erro ao definir tipo do cliente: {str(e)}"}), 500

@usuário_blueprint.route("/usuario/telefones", methods=["POST"])
@token_obrigatorio
def adiciona_telefones_usuário(): #insere os telefones de um usuário (aqui vc passa uma lista separada por vírgula)
    cpf_logado = request.cpf_usuario  #usar o cpf do token para maior segurança
    json = request.get_json()
    tel_usuario = json.get("telefones") #aqui vc passa uma lista separada por vírgula

    if not all([cpf_logado, tel_usuario]):
        return jsonify("Todos os campos (cpf, telefones) sao obrigatorios"), 400

    registro_tel=UsuárioDatabase().insere_lista_tel_usuário(
        cpf_logado, #usar o cpf do token para maior segurança
        tel_usuario
    )

    if not registro_tel:
        return jsonify({"message": "Nao foi possivel criar usuario."}), 400

    return jsonify({"message": "Cadastro realizado com sucesso."}), 200

@usuário_blueprint.route("/usuario/telefones", methods=["DELETE"])
@token_obrigatorio
def remove_telefones_usuário():  # remove os telefones de um usuário (aqui vc passa uma lista separada por vírgula)
    cpf_logado = request.cpf_usuario  #usar o cpf do token para maior segurança
    json = request.get_json()
    tel_usuario = json.get("telefones") #aqui vc passa uma lista separada por vírgula

    if not all([cpf_logado, tel_usuario]):
        return jsonify("Todos os campos (cpf, telefones) sao obrigatorios"), 400
    

    registro_tel=UsuárioDatabase().deleta_tel_usuário(
        cpf_logado, #usar o cpf do token para maior segurança
        tel_usuario
    )

    if not registro_tel:
        return jsonify("Nao foi possivel remover os telefones."), 400

    return jsonify("Telefones removidos com sucesso."), 200

@usuário_blueprint.route("/usuario/perfil/update", methods=["PUT"])
@token_obrigatorio
def update_usuario_perfil():
    cpf_logado = request.cpf_usuario 
    data = request.get_json()

    prenome = data.get("prenome")
    sobrenome = data.get("sobrenome")
    email = data.get("email")
    tel_usuario = data.get("telefone")
    profile_image_url = data.get("profile_image_url")

    if not all([cpf_logado, prenome, sobrenome, email, tel_usuario, profile_image_url]):
        return jsonify({"error": "Dados de perfil incompletos."}), 400

    db_service = UsuárioDatabase()

    try:
        db_service.atualiza_usuario_perfil(
            cpf_logado,
            prenome,
            sobrenome,
            email,
            tel_usuario,
            profile_image_url
        )

        return jsonify({"message": "Perfil atualizado com sucesso."}), 200

    except Exception as e:
        print(f"Erro na rota update_usuario_perfil: {e}")
        return jsonify({"error": "Não foi possível atualizar o perfil. Verifique os dados."}), 500

@usuário_blueprint.route("/usuario/deleta", methods=["DELETE"])
@token_obrigatorio
def deleta_usuário(): #deleta um usuário (e consequentemente seus telefones, por ter o on delete cascade no bd)
    cpf_logado = request.cpf_usuario  #usar o cpf do token para maior segurança
    json = request.get_json()

    if not cpf_logado:
        return jsonify("Campo cpf e obrigatorio"), 400
    

    registro=UsuárioDatabase().deleta_usuário(
        cpf_logado #usar o cpf do token para maior segurança
    )

    if not registro:
        return jsonify("Nao foi possivel deletar o usuario."), 400

    return jsonify("Usuario deletado com sucesso."), 200

@usuário_blueprint.route("/usuario/perfis-imoveis", methods=["GET"])
@token_obrigatorio
def get_perfil_imóvel_adquirente():  #obtém o perfil de imóveis de um adquirente
    cpf_logado = request.cpf_usuario

    try:
        perfil = UsuárioDatabase().get_perfil_imóvel_adquirente(
            cpf_logado #usa o CPF seguro
        )
        return jsonify(perfil), 200
    except Exception as e:
        return jsonify(f"Nao foi possivel obter o perfil do adquirente. Erro: {e}"), 400


@usuário_blueprint.route("/usuario/imoveis-proprietario", methods=["GET"])
@token_obrigatorio
def get_info_imóvel_proprietário(): #obtém os imóveis de um proprietário, fornecendo status sobre eles
    cpf_logado = request.cpf_usuario
    
    try:
        info = UsuárioDatabase().get_info_imóvel_proprietário(
            cpf_logado #usa o CPF seguro
        )
        return jsonify(info), 200
    except Exception as e:
        return jsonify(f"Nao foi possivel obter as informacoes do proprietario. Erro: {e}"), 400


UPLOAD_FOLDER = os.path.join(os.getcwd(), 'static', 'uploads')
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg'}

def allowed_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

@usuário_blueprint.route("/usuario/upload_foto_perfil", methods=["POST"])
@token_obrigatorio
def upload_foto_perfil():
    cpf = request.cpf_usuario
    
    if 'profile_image_url' not in request.files:
        return jsonify({"error": "Nenhum arquivo 'foto' encontrado."}), 400
    
    file = request.files['profile_image_url']

    # Limite de 5MB para imagem de perfil
    MAX_FILE_SIZE = 5 * 1024 * 1024 
    file.seek(0, os.SEEK_END)
    file_size = file.tell()
    file.seek(0)

    if file_size > MAX_FILE_SIZE:
        return jsonify({"error": "Arquivo é muito grande (Máx. 5MB)."}), 413
    
    if file.filename == '':
        return jsonify({"error": "Nome do arquivo vazio."}), 400
    
    if file and allowed_file(file.filename):
        ext = file.filename.rsplit('.', 1)[1].lower()
        filename = f"{cpf}_profile.{ext}"
        
        if not os.path.exists(UPLOAD_FOLDER):
            os.makedirs(UPLOAD_FOLDER)
            
        file_path = os.path.join(UPLOAD_FOLDER, filename)
        file.save(file_path)        
        local_url = url_for('static', filename=f'uploads/{filename}', _external=True)

        return jsonify({
            "message": "Upload realizado com sucesso.",
            "url": local_url
        }), 200
    
    return jsonify({"error": "Tipo de arquivo não permitido."}), 400