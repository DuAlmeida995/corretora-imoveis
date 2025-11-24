from serviços.database.conector import DatabaseManager
from datetime import date, datetime, timedelta
import uuid

class ContratoDatabase:
    """Classe para operações de banco de dados relacionadas a contratos."""
    def __init__(self, db_provider=None) -> None:
        if db_provider is None:
            self.db = DatabaseManager()
        else:
            self.db = db_provider

    def get_prazo_contrato(self): 
        '''Obtém contratos de aluguel que estão para vencer nos próximos 30 dias.'''
        dias_ate_vencer=30
        data_hoje_obj = datetime.now().date() 
        data_futura_obj = data_hoje_obj + timedelta(days=dias_ate_vencer)  
        
        query = """
                SELECT * FROM contrato
                WHERE tipo='Aluguel' AND status = 'Ativo' AND
                data_fim BETWEEN %s AND %s;
        """
        params = (data_hoje_obj, data_futura_obj)
        
        return self.db.execute_select_all(query, params)
    
    def insere_contrato(self, valor:float, status:str, data_inicio:date, data_fim:date, tipo:str, matricula_imovel:str, CPF_prop:str, CPF_corretor:str): 
        '''Insere um novo contrato na tabela contrato e retorna o código gerado.'''
        statement = """
            INSERT INTO contrato (codigo, valor, status, data_inicio, data_fim, tipo, matricula_imovel, CPF_prop, CPF_corretor)
            VALUES (DEFAULT, %s, %s, %s, %s, %s, %s, %s, %s) 
            RETURNING codigo;
        """
        params = (valor, status, data_inicio, data_fim, tipo, matricula_imovel, CPF_prop, CPF_corretor)
        
        resultado = self.db.execute_select_one(statement, params)
        
        if resultado and 'codigo' in resultado:
            return resultado['codigo']
        return None
    
    def completa_adquirente(self, CPF_adq:str, codigo_c:int): 
       '''Vincula um adquirente a um contrato existente na tabela assina'''
       statement = """
            INSERT INTO assina(CPF_adq, codigo_c) VALUES (%s, %s);
        """ 
       params = (CPF_adq, codigo_c)
       return self.db.execute_statement(statement, params)

    
    def deleta_contrato(self, codigo:int): 
        '''Deleta um contrato pelo código.'''
        statement = """
            DELETE FROM contrato
            WHERE codigo = %s;
        """
        return self.db.execute_statement(statement, (codigo,)) 
    
    def altera_status_contrato(self, codigo:int, status:str): 
        '''Altera o status de um contrato pelo código.'''
        statement = """
            UPDATE contrato
            SET 
                status = %s
            WHERE codigo = %s;
        """
        params = (status, codigo)
        return self.db.execute_statement(statement, params)
    
    def get_período_aluguéis_imóvel(self, matricula_imovel:str):
        '''Devolve a lista de contratos de aluguel de um imóvel, com datas de início e fim'''
        statement="""
        SELECT codigo, matricula_imovel,data_inicio,data_fim FROM contrato
        WHERE tipo='Aluguel' AND matricula_imovel=%s
        ORDER BY data_inicio DESC;
        """
        params = (matricula_imovel,)
        return self.db.execute_select_all(statement, params)

    def get_todos_contratos(self, limit=None):
        """
        Retorna a lista de contratos ordenados do mais recente para o mais antigo.
        Permite limitar a quantidade de resultados.
        """
        statement = """ 
        SELECT 
            c.codigo, c.status, c.tipo, c.data_inicio, c.data_fim, c.valor, 
            c.CPF_prop, c.CPF_corretor, 
            i.matricula, i.logradouro, i.numero
        FROM contrato c
        JOIN imovel i ON c.matricula_imovel = i.matricula
        ORDER BY c.codigo DESC
        """
        
        params = ()
        if limit:
            statement += " LIMIT %s"
            params = (limit,)
            
        return self.db.execute_select_all(statement, params)

    def get_dashboard_stats(self):
        """
        Retorna apenas os contadores para o dashboard.
        Usa SQL otimizado para calcular tudo em uma única consulta.
        """
        statement = """
        SELECT
            COUNT(*) FILTER (WHERE status = 'Ativo') as ativos,
            COUNT(*) FILTER (WHERE status = 'Ativo' AND data_fim < CURRENT_DATE) as atrasados,
            COUNT(*) FILTER (WHERE status = 'Ativo' AND data_fim BETWEEN CURRENT_DATE AND (CURRENT_DATE + INTERVAL '30 day')) as vencendo
        FROM contrato;
        """
        return self.db.execute_select_one(statement)
    
    def get_valores_contratos_imóvel(self, matricula_imovel:str):  
        '''Obtém o histórico de valores dos contratos de um imóvel específico'''
        statement="""
        SELECT codigo,matricula_imovel,valor FROM contrato 
        WHERE matricula_imovel=%s 
        ORDER BY codigo DESC;
        """
        params = (matricula_imovel,)
        return self.db.execute_select_all(statement, params)
    
    def get_mais_alugados(self): 
        '''Obtém os imóveis mais alugados'''
        statement="""
        SELECT i.matricula, i.logradouro, i.numero, 
        COUNT(c.codigo) AS nr_de_vezes_alugado
        FROM contrato c JOIN imovel i ON c.matricula_imovel = i.matricula
        WHERE c.tipo='Aluguel'
		GROUP BY i.matricula
        ORDER BY nr_de_vezes_alugado DESC;
        """
        
        return self.db.execute_select_all(statement)
    
    def get_histórico_pessoas_imóvel(self, matricula_imovel:str): 
        '''Obtém o histórico de proprietários e adquirentes de um imóvel específico'''
        statement="""      
        SELECT c.codigo, c.tipo, c.status, prop.prenome AS proprietario_nome, prop.sobrenome AS proprietario_sobrenome, adq.prenome AS adquirente_nome, adq.sobrenome AS adquirente_sobrenome
        FROM contrato c
        JOIN usuario prop ON c.CPF_prop = prop.CPF
        LEFT JOIN assina a ON c.codigo = a.codigo_c
        LEFT JOIN usuario adq ON a.CPF_adq = adq.CPF
        WHERE c.matricula_imovel = %s
        ORDER BY c.codigo DESC;
        """
        params = (matricula_imovel,)
        return self.db.execute_select_all(statement, params)