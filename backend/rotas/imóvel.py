from flask import Blueprint, jsonify, request, current_app
from serviços.imóvel import ImóvelDatabase
from utils.token_middleware import token_obrigatorio
import os
from flask import url_for
from werkzeug.utils import secure_filename

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
    bairro= request.args.get("bairro", "")

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
        bairro,
        comodidade
    )), 200

@imovel_blueprint.route("/imoveis/status", methods=["GET"])
def verifica_status_imóveis(): #obtém os status de um imóvel (se a data de fim de um contrato tiver passado, altera o status do contrato para finalizado e o status do imóvel para disponível)
    matrícula = request.args.get("matricula", "")
    return jsonify(ImóvelDatabase().get_status_imovel(
        matrícula
    )), 200

@imovel_blueprint.route("/imoveis/update", methods=["PUT"])
@token_obrigatorio
def atualiza_imovel():
    json = request.get_json()
    matrícula = json.get("matricula")
    
    if not matrícula:
        return jsonify({"error": "Matrícula é obrigatória para atualização."}), 400

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
    descricao = json.get("descricao")
    bairro = json.get("bairro")

    sucesso = ImóvelDatabase().atualiza_imóvel(
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
        descricao,
        bairro
    )

    if not sucesso:
        return jsonify({"error": "Não foi possível atualizar o imóvel."}), 400

    return jsonify({"message": "Imóvel atualizado com sucesso."}), 200
    
@imovel_blueprint.route("/imoveis/cadastro", methods=["POST"])
@token_obrigatorio
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
    descricao = json.get("descricao")
    bairro = json.get("bairro")

    comodidades = json.get("comodidades")  # aqui você passa uma lista separada por vírgula

    if not all([cpf_prop, logradouro, número, CEP, cidade, bairro,matrícula]):
        return jsonify({"error": "Ha campos obrigatorios nao preenchidos"}), 400

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
        cpf_prop,
        descricao,
        bairro
    )

    if not registro:
        return jsonify({"error": "Nao foi possivel cadastrar o imovel."}), 400
    
    if comodidades:
        sucesso_comodidades = ImóvelDatabase().adiciona_comodidades_imóvel(matrícula, comodidades)
        
        if not sucesso_comodidades:
            ImóvelDatabase().deleta_imóvel(matrícula)
            return jsonify({"error": "Houve erro ao inserir as comodidades. Cadastro desfeito"}), 206

    return jsonify({"message": "Imovel e comodidades cadastrados com sucesso."}), 200

# Configurações
UPLOAD_FOLDER_IMOVEIS = os.path.join(os.getcwd(), 'static', 'uploads', 'imoveis')
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg'}
MAX_FILE_SIZE = 5 * 1024 * 1024  # 5MB

def allowed_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

@imovel_blueprint.route("/imoveis/upload_fotos", methods=["POST"])
@token_obrigatorio
def upload_fotos_imovel():
    # Diferente do usuário (que pegamos pelo token), aqui o imóvel não está "logado".
    # O frontend DEVE mandar a matrícula para sabermos de quem são as fotos.
    matrícula = request.form.get("matricula")

    if not matrícula:
        return jsonify({"error": "Matrícula é obrigatória para vincular as fotos."}), 400

    # Verifica se enviaram arquivos na chave 'fotos'
    # getlist pega VÁRIOS arquivos de uma vez
    files = request.files.getlist('fotos') 

    if not files or files[0].filename == '':
        return jsonify({"error": "Nenhum arquivo de imagem encontrado."}), 400

    imagens_salvas = []
    erros = []
    db = ImóvelDatabase()

    # Cria pasta se não existir
    if not os.path.exists(UPLOAD_FOLDER_IMOVEIS):
        os.makedirs(UPLOAD_FOLDER_IMOVEIS)

    for i, file in enumerate(files):
        # 1. Valida tamanho e extensão
        file.seek(0, os.SEEK_END)
        size = file.tell()
        file.seek(0)

        if size > MAX_FILE_SIZE:
            erros.append(f"Arquivo {file.filename} ignorado (maior que 5MB)")
            continue
        
        if not allowed_file(file.filename):
            erros.append(f"Arquivo {file.filename} ignorado (tipo inválido)")
            continue

        # 2. Gera nome único: matricula_indice_aleatorio.ext
        # Usamos a matrícula para agrupar visualmente os arquivos na pasta
        ext = file.filename.rsplit('.', 1)[1].lower()
        # Dica: Adicionamos 'i' para evitar sobrescrever se mandar 2 fotos iguais
        filename = secure_filename(f"{matrícula}_{i}.{ext}") 
        
        file_path = os.path.join(UPLOAD_FOLDER_IMOVEIS, filename)
        
        try:
            # 3. Salva no Disco
            file.save(file_path)
            
            # 4. Gera URL
            local_url = url_for('static', filename=f'uploads/imoveis/{filename}', _external=True)
            
            # 5. Salva DIRETAMENTE no banco (Tabela imagem_imovel)
            if db.insere_imagem_imovel(matrícula, local_url):
                imagens_salvas.append(local_url)
            else:
                erros.append(f"Erro ao salvar URL no banco para {filename}")

        except Exception as e:
            erros.append(f"Erro de sistema ao salvar {filename}: {str(e)}")

    return jsonify({
        "message": "Processamento de imagens finalizado.",
        "sucesso_qtd": len(imagens_salvas),
        "urls_salvas": imagens_salvas,
        "erros": erros
    }), 200

@imovel_blueprint.route("/imoveis/imagem", methods=["DELETE"])
@token_obrigatorio
def deletar_imagem_imovel():
    data = request.get_json()
    matricula = data.get("matricula")
    image_url = data.get("image_url")

    if not matricula or not image_url:
        return jsonify({"error": "Matrícula e URL da imagem são obrigatórios."}), 400

    db = ImóvelDatabase()
    
    # 1. Tenta remover do Banco de Dados primeiro
    # É mais seguro garantir que o link sumiu antes de apagar o arquivo
    sucesso_db = db.deleta_imagem_imovel(matricula, image_url)
    
    if not sucesso_db:
        return jsonify({"error": "Imagem não encontrada no banco ou erro ao deletar registro."}), 404

    # 2. Tenta remover o arquivo físico (Limpeza)
    try:
        # A URL é algo como: http://localhost:5000/static/uploads/imoveis/1234_0.jpg
        # Precisamos extrair apenas o nome do arquivo: "1234_0.jpg"
        filename = image_url.split('/')[-1]
        
        # Monta o caminho absoluto do arquivo no servidor
        # current_app.root_path aponta para a pasta raiz da sua aplicação Flask
        file_path = os.path.join(os.getcwd(), 'static', 'uploads', 'imoveis', filename)

        if os.path.exists(file_path):
            os.remove(file_path)
            msg_arquivo = "Arquivo apagado com sucesso."
        else:
            msg_arquivo = "Arquivo físico não encontrado (pode já ter sido apagado)."

    except Exception as e:
        print(f"Erro ao apagar arquivo físico: {e}")
        # Não retornamos erro 500 aqui porque o registro no banco JÁ foi apagado,
        # então para o usuário a operação foi um sucesso (a imagem sumiu do sistema).
        msg_arquivo = f"Erro ao apagar arquivo físico: {str(e)}"

    return jsonify({
        "message": "Imagem removida com sucesso.",
        "details": msg_arquivo
    }), 200

@imovel_blueprint.route("/imoveis/alteracao", methods=["PUT"])
@token_obrigatorio
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
    descricao = json.get("descricao")

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
        descricao
    )

    if not registro:
        return jsonify("Nao foi possivel alterar o imovel."), 400

    return jsonify("Imovel alterado com sucesso."), 200

@imovel_blueprint.route("/imoveis/alteracao/proprietario", methods=["PUT"])
@token_obrigatorio
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
@token_obrigatorio
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
@token_obrigatorio
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
@token_obrigatorio
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