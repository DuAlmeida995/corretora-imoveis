from datetime import datetime
from flask import Blueprint, jsonify, request
from serviços.usuário import UsuárioDatabase

usuário_blueprint = Blueprint("usuário", __name__)

@usuário_blueprint.route("/usuário/cadastro", methods=["POST"])
def cria_usuário_completo(): #cadastra um usuário, seus eventuais tipos e seus eventuais números de telefone(aqui vc passa uma lista separada por vírgula)
    json = request.get_json()
    cpf = json.get("cpf")
    prenome = json.get("prenome")
    sobrenome = json.get("sobrenome")
    data_nasc_str = json.get("data_nasc")
    email = json.get("email")
    tel_usuario = json.get("telefones") #aqui vc passa uma lista separada por vírgula
    proprietario = json.get("proprietário")  #opcional, só se for proprietário
    adquirente = json.get("adquirente")  #opcional, só se for adquirente
    corretor = json.get("corretor")  #opcional, só se for corretor
    pontuacao_credito = json.get("pontuacao_credito")  #opcional, só se for adquirente
    especialidade = json.get("especialidade")  #opcional, só se for corretor
    creci = json.get("creci")  #opcional, só se for corretor
    regiao_atuação = json.get("regiao_atuação")  #opcional, só se for corretor

    if not all([cpf, prenome, sobrenome, data_nasc_str,email,tel_usuario]):
        return jsonify("Os campos (cpf, prenome, sobrenome, data_nasc,email, telefones) são obrigatórios"), 400
    
    if proprietario is False and adquirente is False and corretor is False:
        return jsonify("É necessário selecionar ao menos um tipo de usuário (proprietário, adquirente ou corretor)."), 400
    
    try:
        data_nasc_obj = datetime.strptime(data_nasc_str, '%Y-%m-%d').date() # Converte a string "YYYY-MM-DD" em um objeto 'date'
    except (ValueError, TypeError):
        return jsonify({"erro": "Formato de data inválido. Use YYYY-MM-DD"}), 400
    
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
        return jsonify("Não foi possível criar usuário."), 400

    try:
        db_service.insere_lista_tel_usuário(
            cpf,
            tel_usuario
        )

    except Exception as e_telefone:
        try:
            db_service.deleta_usuário(cpf)
            return jsonify("Problema: não foi possível inserir o telefone, cadastro de usuário desfeito."), 400
        except Exception as e_deleção:  
            return jsonify("Problema: não foi possível inserir o telefone e também não foi possível deletar o usuário."), 400
        
    try:
        if proprietario:
            registro1=db_service.insere_proprietário(cpf)
            if not registro1:
                return jsonify("Não foi possível cadastrar como proprietário."), 400
        if adquirente:
            registro2 = db_service.insere_adquirente(cpf, pontuacao_credito)
            if not registro2:
                return jsonify("Não foi possível cadastrar como adquirente."), 400
        if corretor:
            if not creci:
                return jsonify("Creci é obrigatório para cadastramento como corretor."), 400
            registro3 = db_service.insere_corretor(cpf, especialidade, creci, regiao_atuação)
            if not registro3:
                return jsonify("Não foi possível cadastrar como corretor."), 400
        return jsonify("Cadastro realizado com sucesso."), 200
    except Exception as e_tipo:
        try:
            db_service.deleta_usuário(cpf)
            return jsonify("Problema: não foi possível inserir o tipo, cadastro de usuário desfeito."), 400
        except Exception as e_deleção2:  
            return jsonify("Problema: não foi possível inserir o tipo de usuário e também não foi possível deletar o usuário."), 400
  

@usuário_blueprint.route("/usuário/telefones", methods=["POST"])
def adiciona_telefones_usuário(): #insere os telefones de um usuário (aqui vc passa uma lista separada por vírgula)
    json = request.get_json()
    cpf =  json.get("cpf")
    tel_usuario = json.get("telefones") #aqui vc passa uma lista separada por vírgula

    if not all([cpf, tel_usuario]):
        return jsonify("Todos os campos (cpf, telefones) são obrigatórios"), 400

    registro_tel=UsuárioDatabase().insere_lista_tel_usuário(
        cpf,
        tel_usuario
    )

    if not registro_tel:

        return jsonify("Não foi possível efetuar esse cadastro."), 400

    return jsonify("Cadastaro realizado com sucesso."), 200

@usuário_blueprint.route("/usuário/telefones", methods=["DELETE"])
def remove_telefones_usuário():  # remove os telefones de um usuário (aqui vc passa uma lista separada por vírgula)
    json = request.get_json()
    cpf =  json.get("cpf")
    tel_usuario = json.get("telefones") #aqui vc passa uma lista separada por vírgula

    if not all([cpf, tel_usuario]):
        return jsonify("Todos os campos (cpf, telefones) são obrigatórios"), 400
    

    registro_tel=UsuárioDatabase().deleta_tel_usuário(
        cpf,
        tel_usuario
    )

    if not registro_tel:
        return jsonify("Não foi possível remover os telefones."), 400

    return jsonify("Telefones removidos com sucesso."), 200

@usuário_blueprint.route("/usuário/deleta", methods=["DELETE"])
def deleta_usuário(): #deleta um usuário (e consequentemente seus telefones, por ter o on delete cascade no bd)
    json = request.get_json()
    cpf =  json.get("cpf")

    if not cpf:
        return jsonify("Campo cpf é obrigatório"), 400
    

    registro=UsuárioDatabase().deleta_usuário(
        cpf
    )

    if not registro:
        return jsonify("Não foi possível deletar o usuário."), 400

    return jsonify("Usuário deletado com sucesso."), 200

@usuário_blueprint.route("/usuário/perfis-imóveis", methods=["GET"])
def get_perfil_imóvel_adquirente():  #obtém o perfil de imóveis de um adquirente
    cpf = request.args.get("cpf", "")

    return jsonify(UsuárioDatabase().get_perfil_imóvel_adquirente(
        cpf)),200

@usuário_blueprint.route("/usuário/imóveis-proprietário", methods=["GET"])
def get_info_imóvel_proprietário(): #obtém os imóveis de um proprietário, fornecendo status sobre eles
    CPF_prop=request.args.get("cpf_proprietário", "")

    return jsonify(UsuárioDatabase().get_info_imóvel_proprietário(
        CPF_prop)),200

