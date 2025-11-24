from datetime import datetime
from flask import Blueprint, jsonify, request
from serviços.pagamento import PagamentoDatabase
from utils.token_middleware import token_obrigatorio

pagamento_blueprint = Blueprint("pagamento", __name__)

@pagamento_blueprint.route("/pagamento/cadastro", methods=["POST"])
@token_obrigatorio
def cadastra_pagamento(): 
    '''Cria um novo pagamento vinculado a um contrato específico'''
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

    return jsonify({"message": "Pagamento inserido corretamente."}), 200

@pagamento_blueprint.route("/pagamento/status", methods=["GET"])
@token_obrigatorio
def verifica_status_pagamento():
    '''Obtém o status de um pagamento específico e atualiza para atrasado, se necessário''' 
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
@token_obrigatorio
def atualiza_status_pagamento(): 
    '''Atualiza o status de um pagamento específico'''
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
        return jsonify({"error": "Nao foi possivel atualizar o status do pagamento."}), 400

    return jsonify({"message": "Status do pagamento atualizado corretamente."}), 200

@pagamento_blueprint.route("/pagamento/extrato-imovel", methods=["GET"])
@token_obrigatorio
def get_extrato_pagamento_imóvel():
    '''Obtém o extrato financeiro do imóvel logado''' 
    matrícula_imóvel=request.args.get("matricula","")
    return jsonify(PagamentoDatabase().get_extrato_pagamento_contrato(
        matrícula_imóvel)),200
  
@pagamento_blueprint.route("/pagamento/extrato-adquirente", methods=["GET"])
@token_obrigatorio
def get_extrato_pagamento_adquirente():
    '''Obtém o extrato financeiro do adquirente logado''' 
    cpf_logado = request.cpf_usuario 
    return jsonify(PagamentoDatabase().get_extrato_pagamento_adquirente(
        cpf_logado)),200