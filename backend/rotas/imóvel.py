from flask import Blueprint, jsonify, request
from serviços.imóvel import ImóvelDatabase

imovel_blueprint = Blueprint("imóvel", __name__)

@imovel_blueprint.route("/imóveis", methods=["GET"])
def filtra_imóveis():
    valor_venal = request.args.get("valor_venal", type=float)
    logradouro = request.args.get("logradouro", "")
    número = request.args.get("número", "")
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
    matrícula= request.args.get("matrícula", "")
    comodidade= request.args.get("comodidade", "")

    return jsonify(ImóvelDatabase().filtra_imoveis(
        valor_venal,
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

@imovel_blueprint.route("/imóveis/status", methods=["GET"])
def verifica_status_imóveis():
    matrícula = request.args.get("matrícula", "")
    return jsonify(ImóvelDatabase().get_status_imovel(
        matrícula
    )), 200