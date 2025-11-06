from datetime import datetime
from flask import Blueprint, jsonify, request
from serviços.usuário import UsuárioDatabase

usuário_blueprint = Blueprint("usuário", __name__)

@usuário_blueprint.route("/usuário/cadastro", methods=["POST"])
def cria_usuário_completo(): #cadastra um usuário e seus eventuais número de telefone(aqui vc passa uma lista separada por vírgula)(sem ainda colocar de qual/quais tipos ele é)
    json = request.get_json()
    cpf = json.get("cpf")
    prenome = json.get("prenome")
    sobrenome = json.get("sobrenome")
    data_nasc_str = json.get("data_nasc")
    tel_usuario = json.get("telefones") #aqui vc passa uma lista separada por vírgula

    if not all([cpf, prenome, sobrenome, data_nasc_str,tel_usuario]):
        return jsonify("Os campos (cpf, prenome, sobrenome, data_nasc,telefones) são obrigatórios"), 400
    
    try:
        data_nasc_obj = datetime.strptime(data_nasc_str, '%Y-%m-%d').date() # Converte a string "YYYY-MM-DD" em um objeto 'date'
    except (ValueError, TypeError):
        return jsonify({"erro": "Formato de data inválido. Use YYYY-MM-DD"}), 400
    try:
        UsuárioDatabase().insere_usuário(
            cpf,   
            prenome,
            sobrenome, 
            data_nasc_obj
        )
    except Exception as e_usuário:
        return jsonify("Não foi possível criar usuário."), 400

    try:
        if tel_usuario:
            UsuárioDatabase().insere_lista_tel_usuário(
                cpf,
                tel_usuario
            )

            return jsonify("Usuário e telefones inseridos corretamente."), 200
    except Exception as e_telefone:
        try:
            UsuárioDatabase().deleta_usuário(cpf)
        except Exception as e_deleção:  
            return jsonify("Problema: não foi possível inserir o telefone e também não foi possível deletar o usuário."), 400
  

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