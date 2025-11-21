from flask import Blueprint, jsonify, request
from serviços.contrato import ContratoDatabase
from datetime import datetime
from utils.token_middleware import token_obrigatorio

contrato_blueprint = Blueprint("contrato", __name__)

@contrato_blueprint.route("/contratos/prazo", methods=["GET"])
@token_obrigatorio
def contratos_prazo():  #obtém contratos perto de vencer (em até 30 dias)
    return jsonify(ContratoDatabase().get_prazo_contrato()), 200

@contrato_blueprint.route("/contratos/cadastro", methods=["POST"])
@token_obrigatorio
def cadastra_contrato(): #insere um novo contrato e já preenche a tabela assina (liga o contrato ao adquirente)
    json = request.get_json()
    valor = json.get("valor")
    status = json.get("status")
    data_início_str = json.get("data_inicio")
    data_fim_str = json.get("data_fim")
    tipo = json.get("tipo")
    matrícula_imóvel = json.get("matricula_imovel")
    CPF_prop = json.get("CPF_prop")
    CPF_logado_corretor = request.cpf_usuario  #usar o cpf do token para maior segurança
    CPF_adq = json.get("CPF_adq")

    db_service = ContratoDatabase()

    if not all([valor, status, data_início_str, data_fim_str, tipo, matrícula_imóvel, CPF_prop, CPF_logado_corretor, CPF_adq]):
        return jsonify({"error": "Todos os campos obrigatórios não foram preenchidos (exceto código)."}), 400
    
    try:
        data_início = datetime.strptime(data_início_str, '%Y-%m-%d').date()
        data_fim = datetime.strptime(data_fim_str, '%Y-%m-%d').date()
    except (ValueError, TypeError):
        return jsonify({"erro": "Formato de data invalido. Use YYYY-MM-DD"}), 400

    codigo_gerado = db_service.insere_contrato(
        valor,
        status,
        data_início,
        data_fim,
        tipo,
        matrícula_imóvel,
        CPF_prop,
        CPF_logado_corretor
    )
    
    if codigo_gerado:
        registro2 = db_service.completa_adquirente(
            CPF_adq,
            codigo_gerado
        )

        if registro2:
            return jsonify({
                "message": "Contrato inserido corretamente.",
                "codigo": codigo_gerado
            }), 200
        else:
            ContratoDatabase().deleta_contrato(codigo_gerado) #para garantir que o contrato não vai ficar sem preencher a tabela assina
            return jsonify({"error": "Erro ao vincular adquirente. Contrato desfeito."}),

    return jsonify({"error": "Nao foi possivel criar contrato no banco."}), 400


@contrato_blueprint.route("/contratos/deleta", methods=["DELETE"])
@token_obrigatorio
def deleta_contrato(): #deleta um contrato
    ódigo = request.args.get("codigo")

    if not código:
        return jsonify({"error": "O campo codigo e obrigatorio."}), 400

    registro = ContratoDatabase().deleta_contrato(código)

    if not registro:
        return jsonify({"error": "Nao foi possivel deletar contrato."}), 400

    return jsonify({"message": "Contrato deletado corretamente."}), 200

@contrato_blueprint.route("/contratos/alterar-status", methods=["PUT"])
@token_obrigatorio
def alterar_status_contrato(): #altera status de um contrato
    json = request.get_json()
    código = json.get("codigo")
    status = json.get("status")

    if not all([código, status]):
        return jsonify("Todos os campos (codigo, status) sao obrigatorios"), 400

    registro=ContratoDatabase().altera_status_contrato(
        código,
        status
    )

    if not registro:
        return jsonify("Nao foi possivel alterar o status do contrato."), 400

    return jsonify("Status do contrato alterado corretamente."), 200

@contrato_blueprint.route("/contratos/obter-periodo-aluguel",  methods=["GET"])
@token_obrigatorio
def get_periodo_alugueis_imovel(): #obtém os períodos dos contratos de aluguel de um imóvel
    matrícula = request.args.get("matricula", "")

    registro=ContratoDatabase().get_período_aluguéis_imóvel(
        matrícula
    )

    return jsonify(registro),200

@contrato_blueprint.route("/contratos", methods=["GET"])
@token_obrigatorio
def get_todos_contratos():
    """Retorna a lista geral de contratos."""
    try:
        resultados = ContratoDatabase().get_todos_contratos()
        return jsonify(resultados), 200
    except Exception as e:
        return jsonify({"error": f"Erro ao buscar contratos: {e}"}), 500

@contrato_blueprint.route("/contratos/dashboard", methods=["GET"])
@token_obrigatorio
def get_contratos_dashboard():
    try:
        stats = ContratoDatabase().get_dashboard_stats()
        # Garante que retorna 0 se for None
        if not stats:
            stats = {"ativos": 0, "atrasados": 0, "vencendo": 0}
        return jsonify(stats), 200
    except Exception as e:
        return jsonify({"error": f"Erro ao buscar estatísticas: {e}"}), 500

@contrato_blueprint.route("/contratos/obter-valores-imovel",  methods=["GET"])
@token_obrigatorio
def get_valores_contrato_imóvel(): #obtém histórico de valores dos contratos de um imóvel
    return jsonify(ContratoDatabase().get_valores_contratos_imóvel(
        matrícula_imóvel = request.args.get("matricula", "")
    )),200

@contrato_blueprint.route("/contratos/obter-mais-alugados",  methods=["GET"])
@token_obrigatorio
def get_mais_alugados(): #obtém os imóveis mais alugados
    return jsonify(ContratoDatabase().get_mais_alugados()),200

@contrato_blueprint.route("/contratos/obter-pessoas-imovel",  methods=["GET"])
@token_obrigatorio
def get_histórico_pessoas_imóvel(): #devolve o histórico de proprietários e adquirentes de um imóvel por contrato
    matrícula = request.args.get("matricula", "")
    return jsonify(ContratoDatabase().get_histórico_pessoas_imóvel(
        matrícula
    )),200