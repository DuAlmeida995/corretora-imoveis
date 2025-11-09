from serviços.database.conector import DatabaseManager
from datetime import date, datetime, timedelta

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
        
        data_hoje_str = data_hoje_obj.isoformat()
        data_futura_str = data_futura_obj.isoformat()
        
        query = f"""
                SELECT * FROM contrato
                WHERE tipo='Aluguel' AND status = 'Ativo' AND
                data_fim BETWEEN '{data_hoje_str}' AND '{data_futura_str}';

        """
        return self.db.execute_select_all(query)
    
    def insere_contrato(self, codigo:int, valor:float, status:str,data_inicio:date, data_fim:date, tipo:str, matricula_imovel:str, CPF_prop:str, CPF_corretor:str): #insere um novo contrato
        statement = f"""
            INSERT INTO contrato (codigo, valor, status, data_inicio, data_fim, tipo, matricula_imovel, CPF_prop, CPF_corretor)
            VALUES ({codigo}, {valor}, '{status}', '{data_inicio}', '{data_fim}', '{tipo}', '{matricula_imovel}', '{CPF_prop}', '{CPF_corretor}'); \n
        """
        
        return self.db.execute_statement(statement)
    
    def completa_adquirente(self, CPF_adq:str, codigo_c:int): #completa a tabela adquirente
       statement = f"""
            INSERT INTO assina(CPF_adq, codigo_c) VALUES ('{CPF_adq}', {codigo_c}); \n
        """ 
       return self.db.execute_statement(statement)

    
    def deleta_contrato(self, codigo:int): #deleta um contrato
        statement = f"""
            DELETE FROM contrato
            WHERE codigo = {codigo}; \n
        """
        return self.db.execute_statement(statement) 
    
    def altera_status_contrato(self, codigo:int, status:str): #altera status de um contrato
        statement = f"""
            UPDATE contrato
            SET 
                status = '{status}'
            WHERE codigo = {codigo}; \n
        """
        return self.db.execute_statement(statement)
    
    def get_período_aluguéis_imóvel(self, matricula_imovel:str): #obtém os períodos dos contratos de aluguel de um imóvel
        statement=f"""
        SELECT codigo, matricula_imovel,data_inicio,data_fim FROM contrato
        WHERE tipo='Aluguel' AND matricula_imovel='{matricula_imovel}'
        ORDER BY data_inicio DESC;
        """

        return self.db.execute_select_all(statement)

    def get_alugueis_ativos(self): #obtém contratos de alguel ativos
        statement=f""" 
        SELECT c.codigo,c.status, c.data_inicio, c.data_fim, c.valor, i.matricula, i.logradouro, i.numero
        FROM contrato c
        JOIN imovel i ON c.matricula_imovel = i.matricula
        WHERE c.tipo='Aluguel' AND c.status='Ativo';
        """
        return self.db.execute_select_all(statement)
    
    def get_valores_contratos_imóvel(self, matricula_imovel:str): #obtém histórico de valores dos contratos de um imóvel
        statement=f"""
        SELECT codigo,matricula_imovel,valor FROM contrato 
        WHERE matricula_imovel='{matricula_imovel}' 
        ORDER BY codigo DESC;
        """

        return self.db.execute_select_all(statement)
    
    def get_mais_alugados(self): #obtém os imóveis mais alugados
        statement=f"""
        SELECT i.matricula, i.logradouro, i.numero, 
        COUNT(c.codigo) AS nr_de_vezes_alugado
        FROM contrato c JOIN imovel i ON c.matricula_imovel = i.matricula
        WHERE c.tipo='Aluguel'
		GROUP BY i.matricula
        ORDER BY nr_de_vezes_alugado DESC;
        """
        
        return self.db.execute_select_all(statement)
    
    def get_histórico_pessoas_imóvel(self, matricula_imovel:str): #devolve o histórico de proprietários e adquirentes de um imóvel por contrato
        statement=f"""      
        SELECT c.codigo, c.tipo, c.status, prop.prenome AS proprietario_nome, prop.sobrenome AS proprietario_sobrenome, adq.prenome AS adquirente_nome, adq.sobrenome AS adquirente_sobrenome
        FROM contrato c
        JOIN usuario prop ON c.CPF_prop = prop.CPF
        LEFT JOIN assina a ON c.codigo = a.codigo_c
        LEFT JOIN usuario adq ON a.CPF_adq = adq.CPF
        WHERE c.matricula_imovel = '{matricula_imovel}'
        ORDER BY c.codigo DESC;
        """

        return self.db.execute_select_all(statement)