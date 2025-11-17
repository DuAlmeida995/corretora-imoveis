from serviços.contrato import ContratoDatabase
from serviços.database.conector import DatabaseManager
from datetime import date, datetime

class UsuárioDatabase:
    def __init__(self, db_provider=None) -> None:
        if db_provider is None:
            self.db = DatabaseManager()
        else:
            self.db = db_provider

    def insere_usuário(self, cpf: str, prenome: str, sobrenome: str, data_nasc:date, email:str): #cadastra um usuário (sem ainda colocar de qual/quais tipos ele é)
        statement = """
            INSERT INTO usuario (CPF, prenome, sobrenome, data_nasc, email)
            VALUES (%s, %s, %s, %s, %s);
        """
        params = (cpf, prenome, sobrenome, data_nasc, email)
        return self.db.execute_statement(statement, params)

    def insere_adquirente(self, cpf: str, pontuacao_credito: int): #cadastra um usuário como adquirente
        statement = """
            INSERT INTO adquirente (CPF,pontuacao_credito)
            VALUES (%s, %s);
        """
        params = (cpf, pontuacao_credito)
        return self.db.execute_statement(statement, params)
    
    def insere_proprietário(self, cpf: str): #cadastra um usuário como proprietário
        statement = """
            INSERT INTO proprietario (CPF)
            VALUES (%s);
        """
        return self.db.execute_statement(statement, (cpf,))
    
    def insere_corretor(self, cpf: str, especialidade:str, creci:str, regiao_atuacao:str): #cadastra um usuário como corretor
        statement = """
            INSERT INTO corretor (CPF, especialidade, creci_codigo, regiao_atuacao)
            VALUES (%s, %s, %s, %s);
        """
        params = (cpf, especialidade, creci, regiao_atuacao)
        return self.db.execute_statement(statement, params)
    
    def insere_login(self, cpf: str, hash_senha: str):
        """ Insere a senha com hash na tabela login (de forma segura). """
        # Este método já estava correto.
        statement = """
            INSERT INTO login (CPF, senha)
            VALUES (%s, %s);
        """
        try:
            self.db.execute_statement(statement, (cpf, hash_senha))
            return True
        except Exception as e:
            print(f"Erro ao inserir login: {e}")
            raise e
    
    def insere_lista_tel_usuário(self, cpf: str, tel_usuario: str): #insere os telefones de um usuário (aqui vc passa uma lista separada por vírgula)
        
        tel_list_limpa = [tel.strip() for tel in tel_usuario.split(',') if tel.strip()] #para limpar a lista e não quebrar a consulta
        if not tel_list_limpa:
            return True #nada a inserir, mas não é um erro

        tam_list= len(tel_list_limpa)
        telefones_atuais_count = self.get_total_telefones_por_cpf(cpf)

        if (telefones_atuais_count + tam_list) > 3:
            return False
        
        #constrói placeholders e parâmetros de forma segura
        placeholders = ", ".join(["(%s, %s)"] * len(tel_list_limpa))
        params = []
        for item in tel_list_limpa:
            params.extend([cpf, item]) #adiciona (cpf, telefone) para cada item

        statement = f"""
                INSERT INTO tel_usuario(CPF, telefone) VALUES {placeholders};
        """
        return self.db.execute_statement(statement, tuple(params))
    
    def get_total_telefones_por_cpf(self, cpf: str) -> int: #obtém o total de telefones cadastrados para um usuário específico
        statement = """
            SELECT COUNT(*) AS total
            FROM tel_usuario
            WHERE CPF = %s;
        """
        resultado = self.db.execute_select_one(statement, (cpf,)) 
        
        if resultado and 'total' in resultado:
            return int(resultado['total'])
        
        return 0

    def deleta_tel_usuário(self, cpf: str, tel_usuario: str): #remove os telefones de um usuário (aqui vc passa uma lista separada por vírgula)
        tel_list_limpa = [tel.strip() for tel in tel_usuario.split(',') if tel.strip()] #para limpar a lista e não quebrar a consulta
        if not tel_list_limpa:
            return True #nada a deletar, mas não é um erro
        
        telefones_atuais_count = self.get_total_telefones_por_cpf(cpf)
        telefones_para_deletar_count = len(tel_list_limpa)

        if (telefones_atuais_count - telefones_para_deletar_count) < 1:
            return False

        statement = """
            DELETE FROM tel_usuario
            WHERE CPF = %s AND telefone = ANY(%s);
        """
        params = (cpf, tel_list_limpa)

        return self.db.execute_statement(statement, params)
    
    def deleta_usuário(self, cpf: str): #deleta um usuário
        statement = """
            DELETE FROM usuario
            WHERE CPF = %s;
        """
        return self.db.execute_statement(statement, (cpf,))

    def get_perfil_imóvel_adquirente(self, cpf:str): #obtém o perfil de imóveis de um adquirente
        statement="""
        SELECT u.prenome, u.sobrenome, i.tipo AS tipo_de_imovel, i.finalidade, c.tipo AS tipo_de_contrato, COUNT(*) AS total_de_contratos
        FROM usuario u
        JOIN assina a ON u.CPF = a.CPF_adq
        JOIN contrato c ON a.codigo_c = c.codigo
        JOIN imovel i ON c.matricula_imovel = i.matricula
        WHERE u.CPF = %s
        GROUP BY u.CPF, i.tipo, i.finalidade, c.tipo 
        ORDER BY u.prenome, total_de_contratos DESC;
        """
        return self.db.execute_select_all(statement, (cpf,))

    def get_info_imóvel_proprietário(self, CPF_prop:str): #obtém os imóveis de um proprietário, fornecendo status sobre eles
        statement="""
        SELECT i.matricula, i.logradouro, i.numero, c.codigo, c.status, c.valor, c.data_fim
        FROM imovel i
        LEFT JOIN contrato c ON i.matricula = c.matricula_imovel
        WHERE i.CPF_prop = %s
        """
        lista_imoveis = self.db.execute_select_all(statement, (CPF_prop,))
        
        if not lista_imoveis:
            return []
        
        resposta= []
        hoje = datetime.now().date()
        contrato_db = ContratoDatabase() 

        for imovel in lista_imoveis:
            status_banco = imovel['status']
            data_fim = imovel['data_fim']
            codigo_contrato = imovel['codigo']
            situacao_final = ""

            if status_banco == 'Ativo' and data_fim and (data_fim < hoje):
                contrato_db.altera_status_contrato(codigo_contrato, 'Finalizado')
                situacao_final = "Disponivel"
            elif status_banco == 'Ativo':
                situacao_final = "Alugado"
            elif status_banco is None or status_banco == 'Finalizado' or status_banco == 'Cancelado':
                situacao_final = "Disponivel"
            else: 
                situacao_final = status_banco
            
            resposta.append({
                "matricula": imovel['matricula'],
                "logradouro": imovel['logradouro'],
                "numero": imovel['numero'],
                "situacao_atual": situacao_final,
                "codigo_contrato_recente": codigo_contrato
            })
            
        return resposta

    def atualiza_usuario_perfil(self, cpf: str, prenome: str, sobrenome: str, email: str, tel_usuario: str, profile_image_url: str):
        """
        Atualiza dados básicos (nome, email) e a lista de telefones do usuário.
        """
        db = self.db

        try:
            # 1. ATUALIZAÇÃO NA TABELA USUARIO
            statement_user = """
                UPDATE usuario
                SET prenome = %s, sobrenome = %s, email = %s, profile_image_url = %s
                WHERE CPF = %s;
            """
            params_user = (prenome, sobrenome, email, profile_image_url, cpf)
            db.execute_statement(statement_user, params_user)

            # 2. ATUALIZAÇÃO NA TABELA TEL_USUARIO (Limpar e Reinserir)
            statement_delete_tel = "DELETE FROM tel_usuario WHERE CPF = %s;"
            db.execute_statement(statement_delete_tel, (cpf,))
            if tel_usuario:
                registro_tel = self.insere_lista_tel_usuário(cpf, tel_usuario)
                if not registro_tel:
                    raise Exception("Falha ao inserir a nova lista de telefones.")
            
            return True

        except Exception as e:
            print(f"Erro ao atualizar perfil do usuário {cpf}: {e}")
            raise e