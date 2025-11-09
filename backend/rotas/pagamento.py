from datetime import datetime
from flask import Blueprint, jsonify, request
from serviços.pagamento import PagamentoDatabase

pagamento_blueprint = Blueprint("pagamento", __name__)

@pagamento_blueprint.route("/pagamento/cadastro", methods=["POST"])
def cadastra_pagamento(): #insere um pagamento referente a um contrato
    json = request.get_json()
    código_c = json.get("codigo_contrato")
    n_pagamento = json.get("n_pagamento")
    data_vencimento_str = json.get("data_vencimento")
    data_pagamento_str = json.get("data_pagamento")
    valor = json.get("valor")
    status = json.get("status")
    forma_pagamento = json.get("forma_pagamento")
    tipo = json.get("tipo")
 

    if not all([código_c, n_pagamento, data_vencimento_str, valor, status, forma_pagamento]):
        return jsonify("Ha campos obrigatorios faltando."), 400
    
    try:
        data_vencimento = datetime.strptime(data_vencimento_str, '%Y-%m-%d').date()
        data_pagamento = datetime.strptime(data_pagamento_str, '%Y-%m-%d').date()
    except (ValueError, TypeError):
        return jsonify({"erro": "Formato de data invalido. Use YYYY-MM-DD"}), 400

    registro=PagamentoDatabase().insere_pagamento(
        código_c,
        n_pagamento,
        data_vencimento,
        data_pagamento,
        valor,
        status,
        forma_pagamento,
        tipo
    )

    if not registro:
        return jsonify("Nao foi possivel criar pagamento."), 400

    return jsonify("Pagamento inserido corretamente."), 200

@pagamento_blueprint.route("/pagamento/status", methods=["GET"])
def verifica_status_pagamento(): #pega o status de um pagamento (se tiver passado a data de vencimento já muda para atrasado)
    código_c = request.args.get("codigo_contrato", "")
    n_pagamento = request.args.get("n_pagamento", "")

    if not all([código_c, n_pagamento]):
        return jsonify("Ha campos obrigatorios faltando."), 400

    status=PagamentoDatabase().get_status_pagamento(
        código_c,
        n_pagamento
    )

    if status is None:
        return jsonify("Pagamento nao encontrado."), 404

    return jsonify(status), 200

@pagamento_blueprint.route("/pagamento/atualiza_status", methods=["PUT"])
def atualiza_status_pagamento():  #muda o status de um pagamento de um contrato
    json = request.get_json()
    código_c = json.get("codigo_contrato")
    n_pagamento = json.get("n_pagamento")
    status = json.get("status")

    if not all([código_c, n_pagamento, status]):
        return jsonify("Ha campos obrigatorios faltando."), 400

    registro=PagamentoDatabase().atualiza_status_pagamento(
        código_c,
        n_pagamento,
        status
    )

    if not registro:
        return jsonify("Nao foi possivel atualizar o status do pagamento."), 400

    return jsonify("Status do pagamento atualizado corretamente."), 200

@pagamento_blueprint.route("/pagamento/extrato-imovel", methods=["GET"])
def get_extrato_pagamento_imóvel(): #obtem o extrato financeiro por contrato (quantos e quais pagamentos já foram realizados)
    matrícula_imóvel=request.args.get("matricula","")
    return jsonify(PagamentoDatabase().get_extrato_pagamento_contrato(
        matrícula_imóvel)),200
    
@pagamento_blueprint.route("/pagamento/extrato-adquirente", methods=["GET"])
def get_extrato_pagamento_adquirente(): #obtem o extrato financeiro por adquirente
    CPF_adq=request.args.get("cpf_adq","")
    return jsonify(PagamentoDatabase().get_extrato_pagamento_adquirente(
        CPF_adq)),200