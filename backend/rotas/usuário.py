from flask import Blueprint, jsonify, request
from serviços.usuário import UsuárioDatabase

usuário_blueprint = Blueprint("usuário", __name__)

@usuário_blueprint.route("/usuário", methods=["POST"])
def cria_usuário():
    json = request.get_json()
    cpf = json.get("cpf")
    prenome = json.get("prenome")
    sobrenome = json.get("sobrenome")
    data_nasc_str = json.get("data_nasc")

    if not all([cpf, prenome, sobrenome, data_nasc_str]):
        return jsonify("Todos os campos (cpf, prenome, sobrenome, data_nasc) são obrigatórios"), 400
    
    try:
        data_nasc_obj = datetime.strptime(data_nasc_str, '%Y-%m-%d').date() # Converte a string "YYYY-MM-DD" em um objeto 'date'
    except (ValueError, TypeError):
        return jsonify({"erro": "Formato de data inválido. Use YYYY-MM-DD"}), 400
    
    registro=UsuárioDatabase().insere_usuário(
        cpf,   
        prenome,
        sobrenome, 
        data_nasc_obj
    )

    if not registro:
        return jsonify("Não foi possível criar usuário."), 400

    return jsonify("Usuário inserido corretamente."), 200


@usuário_blueprint.route("/usuário/telefones", methods=["POST"])
def adiciona_telefones_usuário():
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