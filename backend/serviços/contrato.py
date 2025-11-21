from serviços.database.conector import DatabaseManager
from datetime import date, datetime, timedelta
import uuid

class ContratoDatabase:
    def __init__(self, db_provider=None) -> None:
        if db_provider is None:
            self.db = DatabaseManager()
        else:
            self.db = db_provider

    def get_prazo_contrato(self): #obtém contratos perto de vencer (em até 30 dias)
        dias_ate_vencer=30
        data_hoje_obj = datetime.now().date() 
        data_futura_obj = data_hoje_obj + timedelta(days=dias_ate_vencer)  
        
        # As datas não são mais injetadas na string
        query = """
                SELECT * FROM contrato
                WHERE tipo='Aluguel' AND status = 'Ativo' AND
                data_fim BETWEEN %s AND %s;
        """
        # Os valores são passados como parâmetros
        params = (data_hoje_obj, data_futura_obj)
        
        return self.db.execute_select_all(query, params)
    
    def insere_contrato(self, valor:float, status:str, data_inicio:date, data_fim:date, tipo:str, matricula_imovel:str, CPF_prop:str, CPF_corretor:str): 
        statement = """
            INSERT INTO contrato (codigo, valor, status, data_inicio, data_fim, tipo, matricula_imovel, CPF_prop, CPF_corretor)
            VALUES (DEFAULT, %s, %s, %s, %s, %s, %s, %s, %s) 
            RETURNING codigo;
        """
        params = (valor, status, data_inicio, data_fim, tipo, matricula_imovel, CPF_prop, CPF_corretor)
        
        # Executa a inserção
        resultado = self.db.execute_select_one(statement, params)
        
        if resultado and 'codigo' in resultado:
            return resultado['codigo']
        return None
    
    def completa_adquirente(self, CPF_adq:str, codigo_c:int): #completa a tabela adquirente
       statement = """
            INSERT INTO assina(CPF_adq, codigo_c) VALUES (%s, %s);
        """ 
       params = (CPF_adq, codigo_c)
       return self.db.execute_statement(statement, params)

    
    def deleta_contrato(self, codigo:int): #deleta um contrato
        statement = """
            DELETE FROM contrato
            WHERE codigo = %s;
        """
        # (codigo,) - A vírgula é crucial para criar uma tupla de um item
        return self.db.execute_statement(statement, (codigo,)) 
    
    def altera_status_contrato(self, codigo:int, status:str): #altera status de um contrato
        statement = """
            UPDATE contrato
            SET 
                status = %s
            WHERE codigo = %s;
        """
        params = (status, codigo)
        return self.db.execute_statement(statement, params)
    
    def get_período_aluguéis_imóvel(self, matricula_imovel:str): #obtém os períodos dos contratos de aluguel de um imóvel
        statement="""
        SELECT codigo, matricula_imovel,data_inicio,data_fim FROM contrato
        WHERE tipo='Aluguel' AND matricula_imovel=%s
        ORDER BY data_inicio DESC;
        """
        params = (matricula_imovel,)
        return self.db.execute_select_all(statement, params)

    def get_todos_contratos(self):
        """
        Retorna a lista completa de contratos (ou limitada aos últimos 50 para performance).
        """
        statement = """ 
        SELECT 
            c.codigo, c.status, c.tipo, c.data_inicio, c.data_fim, c.valor, 
            c.CPF_prop, c.CPF_corretor, 
            i.matricula, i.logradouro, i.numero
        FROM contrato c
        JOIN imovel i ON c.matricula_imovel = i.matricula
        ORDER BY c.codigo DESC; 
        """
        return self.db.execute_select_all(statement)

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
        # Nota: FILTER é sintaxe PostgreSQL moderna. Se der erro, use SUM(CASE WHEN...).
        return self.db.execute_select_one(statement)
    
    def get_valores_contratos_imóvel(self, matricula_imovel:str): #obtém histórico de valores dos contratos de um imóvel
        statement="""
        SELECT codigo,matricula_imovel,valor FROM contrato 
        WHERE matricula_imovel=%s 
        ORDER BY codigo DESC;
        """
        params = (matricula_imovel,)
        return self.db.execute_select_all(statement, params)
    
    def get_mais_alugados(self): #obtém os imóveis mais alugados
        # Esta consulta não tem input do usuário, então é segura como estava.
        statement="""
        SELECT i.matricula, i.logradouro, i.numero, 
        COUNT(c.codigo) AS nr_de_vezes_alugado
        FROM contrato c JOIN imovel i ON c.matricula_imovel = i.matricula
        WHERE c.tipo='Aluguel'
		GROUP BY i.matricula
        ORDER BY nr_de_vezes_alugado DESC;
        """
        
        return self.db.execute_select_all(statement)
    
    def get_histórico_pessoas_imóvel(self, matricula_imovel:str): #devolve o histórico de proprietários e adquirentes de um imóvel por contrato
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