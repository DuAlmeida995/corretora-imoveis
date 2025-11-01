from datetime import datetime
from flask import Blueprint, jsonify, request
from serviços.pagamento import PagamentoDatabase

pagamento_blueprint = Blueprint("pagamento", __name__)

@pagamento_blueprint.route("/pagamento/cadastro", methods=["POST"])
def cadastra_pagamento():
    json = request.get_json()
    código_c = json.get("código_contrato")
    n_pagamento = json.get("n_pagamento")
    data_vencimento_str = json.get("data_vencimento")
    data_pagamento_str = json.get("data_pagamento")
    valor = json.get("valor")
    status = json.get("status")
    forma_pagamento = json.get("forma_pagamento")
    tipo = json.get("tipo")
 

    if not all([código_c, n_pagamento, data_vencimento_str, valor, status, forma_pagamento]):
        return jsonify("Há campos obrigatórios faltando."), 400
    
    try:
        data_vencimento = datetime.strptime(data_vencimento_str, '%Y-%m-%d').date()
        data_pagamento = datetime.strptime(data_pagamento_str, '%Y-%m-%d').date()
    except (ValueError, TypeError):
        return jsonify({"erro": "Formato de data inválido. Use YYYY-MM-DD"}), 400

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
        return jsonify("Não foi possível criar pagamento."), 400

    return jsonify("Pagamento inserido corretamente."), 200

@pagamento_blueprint.route("/pagamento/status", methods=["GET"])
def verifica_status_pagamento():
    código_c = request.args.get("código_contrato", "")
    n_pagamento = request.args.get("n_pagamento", "")

    if not all([código_c, n_pagamento]):
        return jsonify("Há campos obrigatórios faltando."), 400

    status=PagamentoDatabase().get_status_pagamento(
        código_c,
        n_pagamento
    )

    if status is None:
        return jsonify("Pagamento não encontrado."), 404

    return jsonify(status), 200

@pagamento_blueprint.route("/pagamento/atualiza_status", methods=["PUT"])
def atualiza_status_pagamento():
    json = request.get_json()
    código_c = json.get("código_contrato")
    n_pagamento = json.get("n_pagamento")
    status = json.get("status")

    if not all([código_c, n_pagamento, status]):
        return jsonify("Há campos obrigatórios faltando."), 400

    registro=PagamentoDatabase().atualiza_status_pagamento(
        código_c,
        n_pagamento,
        status
    )

    if not registro:
        return jsonify("Não foi possível atualizar o status do pagamento."), 400

    return jsonify("Status do pagamento atualizado corretamente."), 200