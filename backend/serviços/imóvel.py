from datetime import date, datetime
from serviços.database.conector import DatabaseManager
from serviços.contrato import ContratoDatabase

class ImóvelDatabase:
    def __init__(self, db_provider=None) -> None:
        if db_provider is None:
            self.db = DatabaseManager()
        else:
            self.db = db_provider

    def filtra_imoveis(self, valor_venal_min: float ,valor_venal_max: float, logradouro:str, numero:str, CEP: str, cidade: str, metragem_min: float, metragem_max:float, finalidade:str, tipo: str, n_quartos: int, n_reformas: int, possui_garagem: bool, mobiliado: bool, CPF_prop:str, matricula:str, comodidade:str): #filtra imóveis de acordo com uma série de características (vc ecolhe quantas e quais)
        query = """
                SELECT DISTINCT i.* FROM imovel i
                LEFT JOIN comodidades_imovel c ON i.matricula = c.matricula
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

        if numero:
            if "WHERE" in query:
                query += f"AND i.numero = '{numero}'\n"
            else:
                query += f"WHERE i.numero = '{numero}'\n"

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

        if matricula:
            if "WHERE" in query:
                query += f"AND i.matricula = '{matricula}'\n"
            else:
                query += f"WHERE i.matricula = '{matricula}'\n"

        if comodidade:
            comodidade_list = comodidade.split(",")
            subqueries = []
            for item in comodidade_list:
                comodidade_item = item.strip()
                subquery = f"""
                SELECT i.matricula
                FROM imovel i
                LEFT JOIN comodidades_imovel c ON i.matricula = c.matricula
                WHERE c.comodidade = '{comodidade_item}'
                """
                subqueries.append(subquery)

            intersect_query = f" INTERSECT ".join(subqueries)

            if "WHERE" in query:
                query = f"{query} AND i.matricula IN ({intersect_query})"
            else:
                query += f"WHERE i.matricula IN ({intersect_query})\n"

        return self.db.execute_select_all(query)
    
    def get_status_imovel(self, matricula: str): #obtém os status de um imóvel (se a data de fim de um contrato tiver passado, altera o status do contrato para finalizado e o status do imóvel para disponível)
        statement = f"""
            SELECT c.codigo, c.status, c.data_fim FROM imovel i LEFT JOIN contrato c ON i.matricula = c.matricula_imovel WHERE i.matricula='{matricula}' ORDER BY c.codigo DESC; \n
        """
        
        resultado_lista = self.db.execute_select_all(statement)
        if not resultado_lista:
            return "Matricula Invalida"
        
        primeira_linha_dict = resultado_lista[0]
        status_do_banco = primeira_linha_dict['status']
        data_fim_do_banco = primeira_linha_dict['data_fim']

        if status_do_banco is None or status_do_banco=='Finalizado' or status_do_banco == 'Cancelado':
            return "Disponivel"
        elif status_do_banco == 'Ativo':
            if data_fim_do_banco<=datetime.now().date():
                ContratoDatabase().altera_status_contrato(primeira_linha_dict['codigo'], 'Finalizado')
                return "Disponivel"
            return "Alugado"
        else:
            return status_do_banco
        
        
    def cadastra_imóvel(self, matricula:str, n_quartos: int, valor_venal: float, metragem: float, tipo: str, mobiliado: bool, possui_garagem: bool, n_reformas: int, finalidade: str, logradouro: str, complemento:str, numero: str, CEP: str, cidade: str, cpf_prop: str): #cadastra um novo imóvel
        statement = f"""
            INSERT INTO imovel (matricula, n_quartos, valor_venal, metragem, tipo, mobiliado, possui_garagem, n_reformas, finalidade, logradouro, complemento, numero, CEP, cidade, CPF_prop)
            VALUES ('{matricula}', {n_quartos}, {valor_venal}, {metragem}, '{tipo}', {mobiliado}, {possui_garagem}, {n_reformas}, '{finalidade}', '{logradouro}', '{complemento}','{numero}', '{CEP}', '{cidade}', '{cpf_prop}'); \n
        """
        
        return self.db.execute_statement(statement)
    
    def altera_imóvel(self, matricula:str, n_quartos: int, valor_venal: float, metragem: float, tipo: str, mobiliado: bool, possui_garagem: bool, n_reformas: int, finalidade: str): #altera alguma carcterística de um imóvel (as comodidades são tratadas em método separado)
        statement = f"""
            UPDATE imovel
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


        statement += f""" \n WHERE matricula = '{matricula}'; \n"""
        return self.db.execute_statement(statement)
    
    def altera_proprietario_imóvel(self, matricula:str, cpf_prop: str): #altera o proprietário de um imóvel
        statement = f"""
            UPDATE imovel
            SET CPF_prop = '{cpf_prop}'
            WHERE matricula = '{matricula}'; \n
        """
        return self.db.execute_statement(statement)
    
    def adiciona_comodidades_imóvel(self, matricula:str, comodidades: str): #adiciona comodidades a um imóvel
        statement = """
                INSERT INTO comodidades_imovel(matricula, comodidade) VALUES \n
        """

        comodidade_list = comodidades.split(",")
        for item in comodidade_list:
            comodidade_item = item.strip()
            statement += f"('{matricula}', '{comodidade_item}'), \n"

        statement = statement.rstrip(", \n")  # Remove a vírgula e nova linha extras do final
        statement += "; \n"
        return self.db.execute_statement(statement)
    
    def remove_comodidades_imóvel(self, matricula:str, comodidades: str): #remove as comodiades de um imóvel (através desse e do adicionar que alteramos as comodidades de um imóvel)
        comodidade_list = [item.strip() for item in comodidades.split(",")]
        comodidade_str = "', '".join(comodidade_list)

        statement = f"""
            DELETE FROM comodidades_imovel
            WHERE matricula = '{matricula}' AND comodidade IN ('{comodidade_str}'); \n
        """
        return self.db.execute_statement(statement)
    
    def deleta_imóvel(self, matricula:str): #deleta um imóvel
        statement = f"""
            DELETE FROM imovel
            WHERE matricula = '{matricula}'; \n
        """
        return self.db.execute_statement(statement)