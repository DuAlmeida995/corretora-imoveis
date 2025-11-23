from serviços.database.conector import DatabaseManager
from datetime import date, datetime

class PagamentoDatabase:
    '''Classe para operações de banco de dados relacionadas a pagamentos.'''
    def __init__(self, db_provider=None) -> None:
        '''Inicializa a conexão com o banco de dados'''
        if db_provider is None:
            self.db = DatabaseManager()
        else:
            self.db = db_provider

    def insere_pagamento(self, codigo_c:int, n_pagamento:int, data_vencimento:date, data_pagamento:date, valor:float, status:str, forma_pagamento:str, tipo:str): 
        '''Insere um novo pagamento na tabela pagamento.'''
        statement = """
            INSERT INTO pagamento (codigo_c, n_pagamento, data_vencimento, data_pagamento, valor, status, forma_pagamento, tipo)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s);
        """
        params = (codigo_c, n_pagamento, data_vencimento, data_pagamento, valor, status, forma_pagamento, tipo)
        
        return self.db.execute_statement(statement, params)
    
    def atualiza_status_pagamento(self, codigo_c:int, n_pagamento:int, status:str):  
        '''Atualiza o status de um pagamento específico.'''
        statement= """
            UPDATE pagamento
            SET 
                status = %s
            WHERE codigo_c = %s AND n_pagamento = %s;
        """
        params = (status, codigo_c, n_pagamento)
        return self.db.execute_statement(statement, params)


    def get_status_pagamento(self, codigo_c:int, n_pagamento:int): 
        '''Obtém o status de um pagamento específico e atualiza para atrasado, se necessário.'''
        statement = """
            SELECT status, data_vencimento FROM pagamento
            WHERE codigo_c = %s AND n_pagamento = %s;
        """
        params = (codigo_c, n_pagamento)
        
        resultado_lista = self.db.execute_select_all(statement, params)
        if not resultado_lista:
            return None
        
        primeira_linha_dict = resultado_lista[0]
        status_do_banco = primeira_linha_dict['status']
        data_venc_do_banco = primeira_linha_dict['data_vencimento']

        if status_do_banco == 'Pendente' and (data_venc_do_banco < datetime.now().date()):
            self.atualiza_status_pagamento(codigo_c, n_pagamento, 'Atrasado')
            return "Atrasado"

        return status_do_banco
    
    def get_extrato_pagamento_contrato(self, matricula_imovel: str): 
        '''Obtém o extrato financeiro por contrato/imóvel'''
        statement="""
        SELECT  p.codigo_c, p.n_pagamento, p.status, p.valor, p.data_vencimento, p.data_pagamento
        FROM pagamento p
        JOIN contrato c ON p.codigo_c = c.codigo
        WHERE c.matricula_imovel = %s
        ORDER BY p.data_vencimento DESC;
        """
        params = (matricula_imovel,)
        return self.db.execute_select_all(statement, params)

    def get_extrato_pagamento_adquirente(self,CPF_adq:str):
        '''Obtém o extrato financeiro por adquirente'''
        statement="""
        SELECT p.codigo_c, p.n_pagamento, p.status, p.valor, i.logradouro, i.numero, p.data_vencimento, p.data_pagamento
        FROM pagamento p
        JOIN contrato c ON p.codigo_c = c.codigo
        JOIN imovel i ON c.matricula_imovel = i.matricula
        JOIN assina a ON c.codigo = a.codigo_c
        WHERE a.CPF_adq = %s
        ORDER BY p.data_vencimento DESC;
        """
        params = (CPF_adq,)
        return self.db.execute_select_all(statement, params)