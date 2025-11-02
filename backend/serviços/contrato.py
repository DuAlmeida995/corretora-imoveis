from serviços.database.conector import DatabaseManager
from datetime import date, datetime, timedelta

class ContratoDatabase:
    def __init__(self, db_provider=DatabaseManager()) -> None:
        self.db = db_provider

    def get_prazo_contrato(self):
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
    
    def insere_contrato(self, código:int, valor:float, status:str,data_início:date, data_fim:date, tipo:str, matrícula_imóvel:str, CPF_prop:str, CPF_corretor:str):
        statement = f"""
            INSERT INTO contrato (código, valor, status, data_início, data_fim, tipo, matrícula_imóvel, CPF_prop, CPF_corretor)
            VALUES ({código}, {valor}, '{status}', '{data_início}', '{data_fim}', '{tipo}', '{matrícula_imóvel}', '{CPF_prop}', '{CPF_corretor}'); \n
        """
        
        return self.db.execute_statement(statement)
    
    def completa_adquirente(self, CPF_adq:str, código_c:int):
       statement = f"""
            INSERT INTO assina(CPF_adq, código_c) VALUES ('{CPF_adq}', {código_c}); \n
        """ 
       return self.db.execute_statement(statement)

    
    def deleta_contrato(self, código:int):
        statement = f"""
            DELETE FROM contrato
            WHERE código = {código}; \n
        """
        return self.db.execute_statement(statement) 
    
    def altera_status_contrato(self, código:int, status:str):
        statement = f"""
            UPDATE contrato
            SET 
                status = '{status}'
            WHERE código = {código}; \n
        """
        return self.db.execute_statement(statement)
    
    def get_período_aluguéis_imóvel(self, matrícula_imóvel:str):
        statement=f"""
        SELECT código, matrícula_imóvel,data_início,data_fim FROM contrato
        WHERE tipo='Aluguel' AND matrícula_imóvel='{matrícula_imóvel}'
        ORDER BY data_início DESC;
        """

        return self.db.execute_select_all(statement)
    
