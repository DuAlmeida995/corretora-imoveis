from serviços.database.conector import DatabaseManager
from datetime import date, datetime

class PagamentoDatabase:
    def __init__(self, db_provider=DatabaseManager()) -> None:
        self.db = db_provider

    def insere_pagamento(self, código_c:int, n_pagamento:int, data_vencimento:date, data_pagamento:date, valor:float, status:str, forma_pagamento:str, tipo:str):
        statement = f"""
            INSERT INTO pagamento (código_c, n_pagamento, data_vencimento, data_pagamento, valor, status, forma_pagamento, tipo)
            VALUES ({código_c},{n_pagamento},'{data_vencimento}', '{data_pagamento}', {valor}, '{status}','{forma_pagamento}','{tipo}'); \n
        """
        
        return self.db.execute_statement(statement)
    
    def atualiza_status_pagamento(self, código_c:int, n_pagamento:int, status:str): 
        statement= f"""
            UPDATE pagamento
            SET 
                status = '{status}'
            WHERE código_c = {código_c} AND n_pagamento = {n_pagamento}; \n
        """
        return self.db.execute_statement(statement)


    def get_status_pagamento(self, código_c:int, n_pagamento:int):
        statement = f"""
            SELECT status, data_vencimento FROM pagamento
            WHERE código_c = {código_c} AND n_pagamento = {n_pagamento}; \n
        """
        
        resultado_lista = self.db.execute_select_all(statement)
        if not resultado_lista:
            return None
        
        primeira_linha_dict = resultado_lista[0]
        status_do_banco = primeira_linha_dict['status']
        data_venc_do_banco = primeira_linha_dict['data_vencimento']

        if status_do_banco == 'Pendente' and (data_venc_do_banco < datetime.now().date()):
            self.atualiza_status_pagamento(código_c, n_pagamento, 'Atrasado')
            return "Atrasado"

        return status_do_banco