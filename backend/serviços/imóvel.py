from datetime import date, datetime
from serviços.database.conector import DatabaseManager
from serviços.contrato import ContratoDatabase

class ImóvelDatabase:
    '''Classe para operações de banco de dados relacionadas a imóveis.'''
    def __init__(self, db_provider=None) -> None:
        '''Inicializa a conexão com o banco de dados'''
        if db_provider is None:
            self.db = DatabaseManager()
        else:
            self.db = db_provider

    def filtra_imoveis(self, valor_venal_min: float ,valor_venal_max: float, logradouro:str, numero:str, CEP: str, cidade: str, metragem_min: float, metragem_max:float, finalidade:str, tipo: str, n_quartos: int, n_reformas: int, possui_garagem: bool, mobiliado: bool, CPF_prop:str, matricula:str, bairro:str,comodidade:str): 
        '''Filtra imóveis com base em múltiplos critérios.'''
        query = """
                SELECT DISTINCT i.*, array_agg(DISTINCT img.imovel_image_url) AS imagens
                FROM imovel i
                LEFT JOIN comodidades_imovel c ON i.matricula = c.matricula
                LEFT JOIN imagem_imovel img ON i.matricula = img.matricula
                """
        
        where_conditions = []
        params = []

        if valor_venal_min:
            where_conditions.append("i.valor_venal >= %s") 
            params.append(valor_venal_min)
        
        if valor_venal_max:
            where_conditions.append("i.valor_venal <= %s")
            params.append(valor_venal_max)

        if logradouro:
            where_conditions.append("i.logradouro = %s")
            params.append(logradouro)

        if numero:
            where_conditions.append("i.numero = %s")
            params.append(numero)

        if CEP:
            cep_limpo = CEP.strip()
            where_conditions.append("i.CEP = %s")
            params.append(cep_limpo)

        if cidade:
            where_conditions.append("i.cidade = %s")
            params.append(cidade)
        
        if metragem_min:
            where_conditions.append("i.metragem >= %s") 
            params.append(metragem_min)

        if metragem_max:
            where_conditions.append("i.metragem <= %s") 
            params.append(metragem_max)

        if finalidade:
            where_conditions.append("i.finalidade = %s")
            params.append(finalidade)

        if tipo:
            where_conditions.append("i.tipo = %s")
            params.append(tipo)

        if n_quartos is not None:
            where_conditions.append("i.n_quartos = %s")
            params.append(n_quartos)

        if n_reformas is not None:
            where_conditions.append("i.n_reformas <= %s")
            params.append(n_reformas)

        if possui_garagem is not None:
            where_conditions.append("i.possui_garagem = %s")
            params.append(possui_garagem)
        
        if mobiliado is not None:
            where_conditions.append("i.mobiliado = %s")
            params.append(mobiliado)

        if CPF_prop:
            where_conditions.append("i.CPF_prop = %s")
            params.append(CPF_prop)

        if matricula:
            where_conditions.append("i.matricula = %s")
            params.append(matricula)

        if bairro:
            where_conditions.append("i.bairro = %s")
            params.append(bairro)

        if comodidade:
            comodidade_list = [item.strip() for item in comodidade.split(",") if item.strip()]
            if comodidade_list:
                where_conditions.append("c.comodidade = ANY(%s)")
                params.append(comodidade_list)
                query += " WHERE " + " AND ".join(where_conditions)
                query += " GROUP BY i.matricula HAVING COUNT(DISTINCT c.comodidade) = %s"
                params.append(len(comodidade_list))
                
                return self.db.execute_select_all(query, tuple(params))

        if where_conditions:
            query += " WHERE " + " AND ".join(where_conditions)
        
        query += " GROUP BY i.matricula"

        return self.db.execute_select_all(query, tuple(params))
    
    def atualiza_imóvel(self, matricula, n_quartos, valor_venal, metragem, tipo, mobiliado, possui_garagem, n_reformas, finalidade, logradouro, complemento, numero, cep, cidade, descricao, bairro):
        '''Atualiza as informações de um imóvel específico.'''
        statement = """
            UPDATE imovel
            SET n_quartos = %s, 
                valor_venal = %s, 
                metragem = %s, 
                tipo = %s, 
                mobiliado = %s, 
                possui_garagem = %s, 
                n_reformas = %s, 
                finalidade = %s, 
                logradouro = %s, 
                complemento = %s, 
                numero = %s, 
                cep = %s, 
                cidade = %s, 
                descricao = %s, 
                bairro = %s
            WHERE matricula = %s;
        """
        params = (n_quartos, valor_venal, metragem, tipo, mobiliado, possui_garagem, n_reformas, finalidade, logradouro, complemento, numero, cep, cidade, descricao, bairro, matricula)
        return self.db.execute_statement(statement, params)
        
    def get_status_imovel(self, matricula: str): 
        '''Obtém o status atual de um imóvel específico.'''
        statement = """
            SELECT c.codigo, c.status, c.data_fim FROM imovel i 
            LEFT JOIN contrato c ON i.matricula = c.matricula_imovel 
            WHERE i.matricula = %s 
            ORDER BY c.codigo DESC;
        """
        
        resultado_lista = self.db.execute_select_all(statement, (matricula,))
        if not resultado_lista:
            return "Matricula Invalida"
        
        primeira_linha_dict = resultado_lista[0]
        status_do_banco = primeira_linha_dict['status']
        data_fim_do_banco = primeira_linha_dict['data_fim']

        if status_do_banco is None or status_do_banco=='Finalizado' or status_do_banco == 'Cancelado':
            return "Disponivel"
        elif status_do_banco == 'Ativo':
            if data_fim_do_banco and data_fim_do_banco <= datetime.now().date():
                ContratoDatabase().altera_status_contrato(primeira_linha_dict['codigo'], 'Finalizado')
                return "Disponivel"
            return "Alugado"
        else:
            return status_do_banco
        
        
    def cadastra_imóvel(self, matricula:str, n_quartos: int, valor_venal: float, metragem: float, tipo: str, mobiliado: bool, possui_garagem: bool, n_reformas: int, finalidade: str, logradouro: str, complemento:str, numero: str, CEP: str, cidade: str, cpf_prop: str, descricao: str, bairro:str): 
        '''Cadastra um novo imóvel no sistema.'''
        statement = """
            INSERT INTO imovel (matricula, n_quartos, valor_venal, metragem, tipo, mobiliado, possui_garagem, n_reformas, finalidade, logradouro, complemento, numero, CEP, cidade, CPF_prop, descricao, bairro)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s);
        """
        params = (matricula, n_quartos, valor_venal, metragem, tipo, mobiliado, possui_garagem, n_reformas, finalidade, logradouro, complemento, numero, CEP, cidade, cpf_prop, descricao, bairro)
        
        return self.db.execute_statement(statement, params)
    
    def altera_imóvel(self, matricula:str, n_quartos: int, valor_venal: float, metragem: float, tipo: str, mobiliado: bool, possui_garagem: bool, n_reformas: int, finalidade: str, descricao: str): #altera alguma carcterística de um imóvel (as comodidades são tratadas em método separado)
        
        set_clauses = []
        params = []

        if n_quartos is not None:
            set_clauses.append("n_quartos = %s")
            params.append(n_quartos)
        if valor_venal:
            set_clauses.append("valor_venal = %s")
            params.append(valor_venal)
        if metragem:
            set_clauses.append("metragem = %s")
            params.append(metragem)
        if finalidade:
            set_clauses.append("finalidade = %s")
            params.append(finalidade)
        if tipo:
            set_clauses.append("tipo = %s")
            params.append(tipo)
        if mobiliado is not None:
            set_clauses.append("mobiliado = %s")
            params.append(mobiliado)
        if possui_garagem is not None:
            set_clauses.append("possui_garagem = %s")
            params.append(possui_garagem)
        if n_reformas is not None:
            set_clauses.append("n_reformas = %s")
            params.append(n_reformas)
        if descricao:
            set_clauses.append("descricao = %s")
            params.append(descricao)

        if not set_clauses:
            return True 

        statement = f"""
            UPDATE imovel
            SET {', '.join(set_clauses)}
            WHERE matricula = %s;
        """
        params.append(matricula) 
        
        return self.db.execute_statement(statement, tuple(params))
    
    def altera_proprietario_imóvel(self, matricula:str, cpf_prop: str): 
        '''Altera o proprietário de um imóvel específico.'''
        statement = """
            UPDATE imovel
            SET CPF_prop = %s
            WHERE matricula = %s;
        """
        params = (cpf_prop, matricula)
        return self.db.execute_statement(statement, params)
    
    def adiciona_comodidades_imóvel(self, matricula:str, comodidades: str): 
        '''Adiciona comodidades a um imóvel específico.''' 
        comodidade_list = [item.strip() for item in comodidades.split(",") if item.strip()]
        if not comodidade_list:
            return True 

        placeholders = ", ".join(["(%s, %s)"] * len(comodidade_list))
        
        params = []
        for item in comodidade_list:
            params.extend([matricula, item])

        statement = f"""
                INSERT INTO comodidades_imovel(matricula, comodidade) VALUES {placeholders};
        """
        return self.db.execute_statement(statement, tuple(params))
    
    def remove_comodidades_imóvel(self, matricula:str, comodidades: str): 
        '''Remove comodidades de um imóvel específico.'''
        comodidade_list = [item.strip() for item in comodidades.split(",") if item.strip()]
        if not comodidade_list:
            return True 

        statement = """
            DELETE FROM comodidades_imovel
            WHERE matricula = %s AND comodidade = ANY(%s);
        """
        params = (matricula, comodidade_list)
        return self.db.execute_statement(statement, params)
    
    def deleta_imóvel(self, matricula:str):
        '''Deleta um imóvel específico do sistema.'''
        statement = """
            DELETE FROM imovel
            WHERE matricula = %s;
        """
        return self.db.execute_statement(statement, (matricula,))
    
    def insere_imagem_imovel(self, matricula: str, url: str):
        '''Insere uma imagem para um imóvel específico.'''
        statement = """
            INSERT INTO imagem_imovel (matricula, imovel_image_url)
            VALUES (%s, %s);
        """
        return self.db.execute_statement(statement, (matricula, url))
    
    def deleta_imagem_imovel(self, matricula: str, url: str):
        '''Deleta uma imagem específica de um imóvel.'''
        statement = """
            DELETE FROM imagem_imovel
            WHERE matricula = %s AND imovel_image_url = %s;
        """
        return self.db.execute_statement(statement, (matricula, url))

