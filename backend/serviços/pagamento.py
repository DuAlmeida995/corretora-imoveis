from serviços.database.conector import DatabaseManager
from datetime import date, datetime

class PagamentoDatabase:
    def __init__(self, db_provider=None) -> None:
        if db_provider is None:
            self.db = DatabaseManager()
        else:
            self.db = db_provider

    def insere_pagamento(self, codigo_c:int, n_pagamento:int, data_vencimento:date, data_pagamento:date, valor:float, status:str, forma_pagamento:str, tipo:str): #insere um pagamento referente a um contrato
        statement = f"""
            INSERT INTO pagamento (codigo_c, n_pagamento, data_vencimento, data_pagamento, valor, status, forma_pagamento, tipo)
            VALUES ({codigo_c},{n_pagamento},'{data_vencimento}', '{data_pagamento}', {valor}, '{status}','{forma_pagamento}','{tipo}'); \n
        """
        
        return self.db.execute_statement(statement)
    
    def atualiza_status_pagamento(self, codigo_c:int, n_pagamento:int, status:str):  #muda o status de um pagamento de um contrato
        statement= f"""
            UPDATE pagamento
            SET 
                status = '{status}'
            WHERE codigo_c = {codigo_c} AND n_pagamento = {n_pagamento}; \n
        """
        return self.db.execute_statement(statement)


    def get_status_pagamento(self, codigo_c:int, n_pagamento:int): #pega o status de um pagamento (se tiver passado a data de vencimento já muda para atrasado)
        statement = f"""
            SELECT status, data_vencimento FROM pagamento
            WHERE codigo_c = {codigo_c} AND n_pagamento = {n_pagamento}; \n
        """
        
        resultado_lista = self.db.execute_select_all(statement)
        if not resultado_lista:
            return None
        
        primeira_linha_dict = resultado_lista[0]
        status_do_banco = primeira_linha_dict['status']
        data_venc_do_banco = primeira_linha_dict['data_vencimento']

        if status_do_banco == 'Pendente' and (data_venc_do_banco < datetime.now().date()):
            self.atualiza_status_pagamento(codigo_c, n_pagamento, 'Atrasado')
            return "Atrasado"

        return status_do_banco
    
    def get_extrato_pagamento_contrato(self, matricula_imovel: str): #obtem o extrato financeiro por contrato (quantos e quais pagamentos já foram realizados)
        statement=f"""
        SELECT  p.codigo_c, p.n_pagamento, p.status, p.valor, p.data_vencimento, p.data_pagamento
        FROM pagamento p
        JOIN contrato c ON p.codigo_c = c.codigo
        WHERE c.matricula_imovel = '{matricula_imovel}'
        ORDER BY p.data_vencimento DESC;
        """

        return self.db.execute_select_all(statement)

    def get_extrato_pagamento_adquirente(self,CPF_adq:str): #obtem o extrato financeiro por adquirente
        statement=f"""
        SELECT p.codigo_c, p.n_pagamento, p.status, p.valor, i.logradouro, i.numero, p.data_vencimento, p.data_pagamento
        FROM pagamento p
        JOIN contrato c ON p.codigo_c = c.codigo
        JOIN imovel i ON c.matricula_imovel = i.matricula
        JOIN assina a ON c.codigo = a.codigo_c
        WHERE a.CPF_adq = '{CPF_adq}'
        ORDER BY p.data_vencimento DESC;
        """

        return self.db.execute_select_all(statement)