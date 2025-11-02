from flask import Blueprint, jsonify, request
from serviços.contrato import ContratoDatabase
from datetime import datetime

contrato_blueprint = Blueprint("contrato", __name__)

@contrato_blueprint.route("/contratos/prazo", methods=["GET"])
def contratos_prazo():  
    return jsonify(ContratoDatabase().get_prazo_contrato()), 200

@contrato_blueprint.route("/contratos/cadastro", methods=["POST"])
def cadastra_contrato():
    json = request.get_json()
    código = json.get("código")
    valor = json.get("valor")
    status = json.get("status")
    data_início_str = json.get("data_início")
    data_fim_str = json.get("data_fim")
    tipo = json.get("tipo")
    matrícula_imóvel = json.get("matrícula_imóvel")
    CPF_prop = json.get("CPF_prop")
    CPF_corretor = json.get("CPF_corretor")

    CPF_adq = json.get("CPF_adq")

    if not all([código, valor, status, data_início_str, data_fim_str, tipo, matrícula_imóvel, CPF_prop, CPF_corretor,CPF_adq]):
        return jsonify("Todos os campos (código, valor, status, data_início, data_fim, tipo, matrícula_imóvel, CPF_prop, CPF_corretor) são obrigatórios"), 400
    
    try:
        data_início = datetime.strptime(data_início_str, '%Y-%m-%d').date()
        data_fim = datetime.strptime(data_fim_str, '%Y-%m-%d').date()
    except (ValueError, TypeError):
        return jsonify({"erro": "Formato de data inválido. Use YYYY-MM-DD"}), 400

    registro=ContratoDatabase().insere_contrato(
        código,
        valor,
        status,
        data_início,
        data_fim,
        tipo,
        matrícula_imóvel,
        CPF_prop,
        CPF_corretor
    )

    registro2=ContratoDatabase().completa_adquirente(
        CPF_adq,
        código
    )

    if registro:
        if registro2:
            return jsonify("Contrato inserido corretamente."), 200
        else:
            ContratoDatabase().deleta_contrato(código) #para garantir que o contrato não vai ficar sem preencher a tabela assina
            return jsonify("Não foi possível criar contrato."), 400

    return jsonify("Não foi possível criar contrato."), 400


@contrato_blueprint.route("/contratos/deleta", methods=["DELETE"])
def deleta_contrato():
    json = request.get_json()
    código = json.get("código")

    if not código:
        return jsonify("O campo código é obrigatório"), 400

    registro=ContratoDatabase().deleta_contrato(
        código
    )

    if not registro:
        return jsonify("Não foi possível deletar contrato."), 400

    return jsonify("Contrato deletado corretamente."), 200

@contrato_blueprint.route("/contratos/alterar-status", methods=["PUT"])
def alterar_status_contrato():
    json = request.get_json()
    código = json.get("código")
    status = json.get("status")

    if not all([código, status]):
        return jsonify("Todos os campos (código, status) são obrigatórios"), 400

    registro=ContratoDatabase().altera_status_contrato(
        código,
        status
    )

    if not registro:
        return jsonify("Não foi possível alterar o status do contrato."), 400

    return jsonify("Status do contrato alterado corretamente."), 200

@contrato_blueprint.route("/contratos/obter-aluguel",  methods=["GET"])
def get_periodo_alugueis_imovel():
    matrícula = request.args.get("matrícula", "")

    registro=ContratoDatabase().get_período_aluguéis_imóvel(
        matrícula
    )

    return jsonify(registro),200


