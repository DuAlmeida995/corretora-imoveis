from datetime import date, datetime
from serviços.database.conector import DatabaseManager
from serviços.contrato import ContratoDatabase

class ImóvelDatabase:
    def __init__(self, db_provider=DatabaseManager()) -> None:
        self.db = db_provider

    def filtra_imoveis(self, valor_venal_min: float ,valor_venal_max: float, logradouro:str, número:str, CEP: str, cidade: str, metragem_min: float, metragem_max:float, finalidade:str, tipo: str, n_quartos: int, n_reformas: int, possui_garagem: bool, mobiliado: bool, CPF_prop:str, matrícula:str, comodidade:str): #filtra imóveis de acordo com uma série de características (vc ecolhe quantas e quais)
        query = """
                SELECT DISTINCT i.* FROM imóvel i
                LEFT JOIN comodidades_imóvel c ON i.matrícula = c.matrícula
                """
        if valor_venal_min:
            if valor_venal_max:
                if "WHERE" in query:
                    query += f"AND i.valor_venal BETWEEN {valor_venal_min} AND {valor_venal_max}\n" #apresenta imóveis dentro da faixa de valor venal especificada
                else:
                    query += f"WHERE i.valor_venal BETWEEN {valor_venal_min} AND {valor_venal_max}\n"
        
            else:
                if "WHERE" in query:
                    query += f"AND i.valor_venal >= {valor_venal_min}\n" #apresenta imóveis com valor venal mínimo especificado
                else:
                    query += f"WHERE i.valor_venal >= {valor_venal_min}\n"
        else:
            if valor_venal_max:
                if "WHERE" in query:
                    query += f"AND i.valor_venal <= {valor_venal_max}\n" #apresenta imóveis com valor venal máximo especificado
                else:
                    query += f"WHERE i.valor_venal <= {valor_venal_max}\n"
        if logradouro:
            if "WHERE" in query:
                query += f"AND i.logradouro = '{logradouro}'\n"
            else:
                query += f"WHERE i.logradouro = '{logradouro}'\n"

        if número:
            if "WHERE" in query:
                query += f"AND i.número = '{número}'\n"
            else:
                query += f"WHERE i.número = '{número}'\n"

        if CEP:
            cep_limpo = CEP.strip()
            if "WHERE" in query:
                query += f"AND i.CEP = '{cep_limpo}'\n"
            else:
                query += f"WHERE i.CEP = '{cep_limpo}'\n"

        if cidade:
            if "WHERE" in query:
                query += f"AND i.cidade = '{cidade}'\n"
            else:
                query += f"WHERE i.cidade = '{cidade}'\n"

        if metragem_min:
            if metragem_max:
                if "WHERE" in query:
                    query += f"AND i.metragem BETWEEN {metragem_min} AND {metragem_max}\n" #filtra imóveis dentro da faixa de metragem especificada
                else:
                    query += f"WHERE i.metragem BETWEEN {metragem_min} AND {metragem_max}\n"
            else:
                if "WHERE" in query:
                    query += f"AND i.metragem >= {metragem_min}\n" #filtra imóveis com metragem mínima especificada
                else:
                    query += f"WHERE i.metragem >= {metragem_min}\n"

        else:
            if metragem_max:
                if "WHERE" in query:
                    query += f"AND i.metragem <= {metragem_max}\n" #filtra imóveis com metragem máxima especificada
                else:
                    query += f"WHERE i.metragem <= {metragem_max}\n"

        if finalidade:
            if "WHERE" in query:
                query += f"AND i.finalidade = '{finalidade}'\n"
            else:
                query += f"WHERE i.finalidade = '{finalidade}'\n"

        if tipo:
            if "WHERE" in query:
                query += f"AND i.tipo = '{tipo}'\n"
            else:
                query += f"WHERE i.tipo = '{tipo}'\n"

        if n_quartos is not None:
            if "WHERE" in query:
                query += f"AND i.n_quartos = {n_quartos}\n"
            else:
                query += f"WHERE i.n_quartos = {n_quartos}\n"

        if n_reformas is not None:
            if "WHERE" in query:
                query += f"AND i.n_reformas = {n_reformas}\n"
            else:
                query += f"WHERE i.n_reformas = {n_reformas}\n"

        if possui_garagem is not None:
            if "WHERE" in query:
                query += f"AND i.possui_garagem = {(possui_garagem)}\n"
            else:
                query += f"WHERE i.possui_garagem = {(possui_garagem)}\n"
        
        if mobiliado is not None:
            if "WHERE" in query:
                query += f"AND i.mobiliado = {(mobiliado)}\n"
            else:
                query += f"WHERE i.mobiliado = {(mobiliado)}\n"

        if CPF_prop:
            if "WHERE" in query:
                query += f"AND i.CPF_prop = '{CPF_prop}'\n"
            else:
                query += f"WHERE i.CPF_prop = '{CPF_prop}'\n"

        if matrícula:
            if "WHERE" in query:
                query += f"AND i.matrícula = '{matrícula}'\n"
            else:
                query += f"WHERE i.matrícula = '{matrícula}'\n"

        if comodidade:
            comodidade_list = comodidade.split(",")
            subqueries = []
            for item in comodidade_list:
                comodidade_item = item.strip()
                subquery = f"""
                SELECT i.matrícula
                FROM imóvel i
                LEFT JOIN comodidades_imóvel c ON i.matrícula = c.matrícula
                WHERE c.comodidade = '{comodidade_item}'
                """
                subqueries.append(subquery)

            intersect_query = f" INTERSECT ".join(subqueries)

            if "WHERE" in query:
                query = f"{query} AND i.matrícula IN ({intersect_query})"
            else:
                query += f"WHERE i.matrícula IN ({intersect_query})\n"

        return self.db.execute_select_all(query)
    
    def get_status_imovel(self, matrícula: str): #obtém os status de um imóvel (se a data de fim de um contrato tiver passado, altera o status do contrato para finalizado e o status do imóvel para disponível)
        statement = f"""
            SELECT c.código, c.status, c.data_fim FROM imóvel i LEFT JOIN contrato c ON i.matrícula = c.matrícula_imóvel WHERE i.matrícula='{matrícula}' ORDER BY c.código DESC; \n
        """
        
        resultado_lista = self.db.execute_select_all(statement)
        if not resultado_lista:
            return "Matrícula Inválida"
        
        primeira_linha_dict = resultado_lista[0]
        status_do_banco = primeira_linha_dict['status']
        data_fim_do_banco = primeira_linha_dict['data_fim']

        if status_do_banco is None or status_do_banco=='Finalizado' or status_do_banco == 'Cancelado':
            return "Disponível"
        elif status_do_banco == 'Ativo':
            if data_fim_do_banco<=datetime.now().date():
                ContratoDatabase().altera_status_contrato(primeira_linha_dict['código'], 'Finalizado')
                return "Disponível"
            return "Alugado"
        else:
            return status_do_banco
        
        
    def cadastra_imóvel(self, matrícula:str, n_quartos: int, valor_venal: float, metragem: float, tipo: str, mobiliado: bool, possui_garagem: bool, n_reformas: int, finalidade: str, logradouro: str, complemento:str, número: str, CEP: str, cidade: str, cpf_prop: str): #cadastra um novo imóvel
        statement = f"""
            INSERT INTO imóvel (matrícula, n_quartos, valor_venal, metragem, tipo, mobiliado, possui_garagem, n_reformas, finalidade, logradouro, complemento, número, CEP, cidade, CPF_prop)
            VALUES ('{matrícula}', {n_quartos}, {valor_venal}, {metragem}, '{tipo}', {mobiliado}, {possui_garagem}, {n_reformas}, '{finalidade}', '{logradouro}', '{complemento}','{número}', '{CEP}', '{cidade}', '{cpf_prop}'); \n
        """
        
        return self.db.execute_statement(statement)
    
    def altera_imóvel(self, matrícula:str, n_quartos: int, valor_venal: float, metragem: float, tipo: str, mobiliado: bool, possui_garagem: bool, n_reformas: int, finalidade: str): #altera alguma carcterística de um imóvel (as comodidades são tratadas em método separado)
        statement = f"""
            UPDATE imóvel
            SET 
        """
        if n_quartos is not None:
            statement += f"""n_quartos = {n_quartos}, \n"""
        if valor_venal:
            statement += f"""valor_venal = {valor_venal}, \n"""
        if metragem:
            statement += f"""metragem = {metragem}, \n"""
        if finalidade:
            statement += f"""finalidade = '{finalidade}', \n"""
        if tipo:
            statement += f"""tipo = '{tipo}', \n"""
        if mobiliado is not None:
            statement += f"""mobiliado = {mobiliado}, \n""" 
        if possui_garagem is not None:
            statement += f"""possui_garagem = {possui_garagem}, \n"""   
        if n_reformas is not None:
            statement += f"""n_reformas = {n_reformas}, \n"""

        statement = statement.rstrip(", \n")  # Remove a vírgula e nova linha extras do final


        statement += f""" \n WHERE matrícula = '{matrícula}'; \n"""
        return self.db.execute_statement(statement)
    
    def altera_proprietario_imóvel(self, matrícula:str, cpf_prop: str): #altera o proprietário de um imóvel
        statement = f"""
            UPDATE imóvel
            SET CPF_prop = '{cpf_prop}'
            WHERE matrícula = '{matrícula}'; \n
        """
        return self.db.execute_statement(statement)
    
    def adiciona_comodidades_imóvel(self, matrícula:str, comodidades: str): #adiciona comodidades a um imóvel
        statement = """
                INSERT INTO comodidades_imóvel(matrícula, comodidade) VALUES \n
        """

        comodidade_list = comodidades.split(",")
        for item in comodidade_list:
            comodidade_item = item.strip()
            statement += f"('{matrícula}', '{comodidade_item}'), \n"

        statement = statement.rstrip(", \n")  # Remove a vírgula e nova linha extras do final
        statement += "; \n"
        return self.db.execute_statement(statement)
    
    def remove_comodidades_imóvel(self, matrícula:str, comodidades: str): #remove as comodiades de um imóvel (através desse e do adicionar que alteramos as comodidades de um imóvel)
        comodidade_list = [item.strip() for item in comodidades.split(",")]
        comodidade_str = "', '".join(comodidade_list)

        statement = f"""
            DELETE FROM comodidades_imóvel
            WHERE matrícula = '{matrícula}' AND comodidade IN ('{comodidade_str}'); \n
        """
        return self.db.execute_statement(statement)
    
    def deleta_imóvel(self, matrícula:str): #deleta um imóvel
        statement = f"""
            DELETE FROM imóvel
            WHERE matrícula = '{matrícula}'; \n
        """
        return self.db.execute_statement(statement)