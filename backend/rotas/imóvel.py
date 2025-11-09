from flask import Blueprint, jsonify, request
from serviços.imóvel import ImóvelDatabase

imovel_blueprint = Blueprint("imovel", __name__)

@imovel_blueprint.route("/imoveis/filtro", methods=["GET"])
def filtra_imóveis(): #filtra imóveis de acordo com uma série de características (vc ecolhe quantas e quais)
    valor_venal_min = request.args.get("valor_venal_min", type=float)
    valor_venal_max = request.args.get("valor_venal_max", type=float)
    logradouro = request.args.get("logradouro", "")
    número = request.args.get("numero", "")
    cep = request.args.get("cep", "")
    cidade = request.args.get("cidade", "")
    metragem_min = request.args.get("metragem_min", type=float)
    metragem_max = request.args.get("metragem_max", type=float)
    finalidade = request.args.get("finalidade", "")
    tipo = request.args.get("tipo", "")
    n_quartos = request.args.get("n_quartos", type=int)
    n_reformas = request.args.get("n_reformas", type=int)
    possui_garagem = request.args.get("possui_garagem", type=lambda v: v.lower() == 'true' if v else None)
    mobiliado = request.args.get("mobiliado", type=lambda v: v.lower() == 'true' if v else None)
    cpf_prop= request.args.get("cpf", "")
    matrícula= request.args.get("matricula", "")
    comodidade= request.args.get("comodidade", "")

    return jsonify(ImóvelDatabase().filtra_imoveis(
        valor_venal_min,
        valor_venal_max,
        logradouro,
        número,
        cep,
        cidade,
        metragem_min,
        metragem_max,
        finalidade,
        tipo,
        n_quartos,
        n_reformas,
        possui_garagem,
        mobiliado,
        cpf_prop,
        matrícula,
        comodidade
    )), 200

@imovel_blueprint.route("/imoveis/status", methods=["GET"])
def verifica_status_imóveis(): #obtém os status de um imóvel (se a data de fim de um contrato tiver passado, altera o status do contrato para finalizado e o status do imóvel para disponível)
    matrícula = request.args.get("matricula", "")
    return jsonify(ImóvelDatabase().get_status_imovel(
        matrícula
    )), 200

@imovel_blueprint.route("/imoveis/cadastro", methods=["POST"])
def cadastrar_imóvel(): #cadastra um novo imóvel
    json = request.get_json()
    cpf_prop = json.get("cpf_prop")
    logradouro = json.get("logradouro")
    complemento = json.get("complemento")
    número = json.get("numero")
    CEP = json.get("cep")
    cidade = json.get("cidade")
    metragem = json.get("metragem")
    finalidade = json.get("finalidade")
    tipo = json.get("tipo")
    n_quartos = json.get("n_quartos")
    n_reformas = json.get("n_reformas")
    possui_garagem = json.get("possui_garagem")
    mobiliado = json.get("mobiliado")
    valor_venal = json.get("valor_venal")
    matrícula = json.get("matricula")

    if not all([cpf_prop, logradouro, número, CEP, cidade, matrícula]):
        return jsonify("Ha campos obrigatorios nao preenchidos"), 400

    registro = ImóvelDatabase().cadastra_imóvel(
        matrícula,
        n_quartos,
        valor_venal,
        metragem,
        tipo,
        mobiliado,
        possui_garagem,
        n_reformas,
        finalidade,
        logradouro,
        complemento,
        número, 
        CEP,
        cidade, 
        cpf_prop
    )

    if not registro:
        return jsonify("Nao foi possivel cadastrar o imovel."), 400

    return jsonify("Imovel cadastrado com sucesso."), 200

@imovel_blueprint.route("/imoveis/alteracao", methods=["PUT"])
def alterar_imóvel(): #altera alguma carcterística de um imóvel (as comodidades são tratadas em método separado)
    json = request.get_json()
    matrícula = json.get("matricula")
    n_quartos = json.get("n_quartos")
    valor_venal = json.get("valor_venal")
    metragem = json.get("metragem")
    tipo = json.get("tipo")
    mobiliado = json.get("mobiliado")
    possui_garagem = json.get("possui_garagem")
    n_reformas = json.get("n_reformas")
    finalidade = json.get("finalidade")

    if not matrícula:
        return jsonify("Matricula e um campo obrigatorio"), 400

    registro = ImóvelDatabase().altera_imóvel(
        matrícula,
        n_quartos,
        valor_venal,
        metragem,
        tipo,
        mobiliado,
        possui_garagem,
        n_reformas,
        finalidade,
    )

    if not registro:
        return jsonify("Nao foi possivel alterar o imovel."), 400

    return jsonify("Imovel alterado com sucesso."), 200

@imovel_blueprint.route("/imoveis/alteracao/proprietario", methods=["PUT"])
def alterar_proprietario_imóvel(): #altera o proprietário de um imóvel
    json = request.get_json()
    matrícula = json.get("matricula")
    cpf_prop = json.get("cpf_novo_prop")

    if not all([matrícula, cpf_prop]):
        return jsonify("Matricula e CPF do novo proprietario sao campos obrigatorios"), 400

    registro = ImóvelDatabase().altera_proprietario_imóvel(
        matrícula,
        cpf_prop
    )

    if not registro:
        return jsonify("Nao foi possivel alterar o proprietario do imovel."), 400

    return jsonify("Proprietario do imovel alterado com sucesso."), 200

@imovel_blueprint.route("/imoveis/comodidades", methods=["POST"])
def adiciona_comodidades_imóvel(): #adiciona comodidades a um imóvel
    json = request.get_json()
    matrícula = json.get("matricula")
    comodidades = json.get("comodidades")  # aqui você passa uma lista separada por vírgula

    if not all([matrícula, comodidades]):
        return jsonify("Matricula e comodidades sao campos obrigatorios"), 400

    registro = ImóvelDatabase().adiciona_comodidades_imóvel(
        matrícula,
        comodidades
    )

    if not registro:
        return jsonify("Nao foi possivel adicionar as comodidades."), 400

    return jsonify("Comodidades adicionadas com sucesso."), 200

@imovel_blueprint.route("/imoveis/comodidades", methods=["DELETE"])
def remove_comodidades_imóvel(): #remove as comodiades de um imóvel (através desse e do adicionar que alteramos as comodidades de um imóvel)
    json = request.get_json()
    matrícula = json.get("matricula")
    comodidades = json.get("comodidades")  # aqui você passa uma lista separada por vírgula

    if not all([matrícula, comodidades]):
        return jsonify("Matricula e comodidades sao campos obrigatorios"), 400

    registro = ImóvelDatabase().remove_comodidades_imóvel(
        matrícula,
        comodidades
    )

    if not registro:
        return jsonify("Nao foi possivel remover as comodidades."), 400

    return jsonify("Comodidades removidas com sucesso."), 200

@imovel_blueprint.route("/imoveis/deleta", methods=["DELETE"])
def deleta_imóvel(): #deleta um imóvel
    json = request.get_json()
    matrícula = json.get("matricula")

    if not matrícula:
        return jsonify("Matricula e um campo obrigatorio"), 400

    registro = ImóvelDatabase().deleta_imóvel(
        matrícula
    )

    if not registro:
        return jsonify("Nao foi possivel deletar o imovel."), 400

    return jsonify("Imovel deletado com sucesso."), 200