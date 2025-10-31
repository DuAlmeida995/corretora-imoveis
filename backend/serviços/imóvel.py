from serviços.database.conector import DatabaseManager

class ImóvelDatabase:
    def __init__(self, db_provider=DatabaseManager()) -> None:
        self.db = db_provider

    def filtra_imoveis(self, valor_venal: float , logradouro:str, número:str, CEP: str, cidade: str, metragem_min: float, metragem_max:float, finalidade:str, tipo: str, n_quartos: int, n_reformas: int, possui_garagem: bool, mobiliado: bool, CPF_prop:str, matrícula:str, comodidade:str):
        query = """
                SELECT DISTINCT i.* FROM imóvel i
                LEFT JOIN comodidades_imóvel c ON i.matrícula = c.matrícula
                """
        if valor_venal:
            if "WHERE" in query:
                query += f"AND i.valor_venal <= {valor_venal}\n" #apresenta imóveis com valor venal menor ou igual ao especificado
            else:
                query += f"WHERE i.valor_venal <= {valor_venal}\n"

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