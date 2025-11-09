from serviços.contrato import ContratoDatabase
from serviços.database.conector import DatabaseManager
from datetime import date, datetime

class UsuárioDatabase:
    def __init__(self, db_provider=DatabaseManager()) -> None:
        self.db = db_provider

    def insere_usuário(self, cpf: str, prenome: str, sobrenome: str, data_nasc:date, email:str): #cadastra um usuário (sem ainda colocar de qual/quais tipos ele é)
        statement = f"""
            INSERT INTO usuário (CPF, prenome, sobrenome, data_nasc, email)
            VALUES ('{cpf}', '{prenome}', '{sobrenome}', '{data_nasc}', '{email}'); \n
        """
        
        return self.db.execute_statement(statement)

    def insere_adquirente(self, cpf: str, pontuacao_credito: int): #cadastra um usuário como adquirente
        statement = f"""
            INSERT INTO adquirente (CPF,pontuacao_credito)
            VALUES ('{cpf}',{pontuacao_credito}); \n
        """
        
        return self.db.execute_statement(statement)
    
    def insere_proprietário(self, cpf: str): #cadastra um usuário como proprietário
        statement = f"""
            INSERT INTO proprietário (CPF)
            VALUES ('{cpf}'); \n
        """
        
        return self.db.execute_statement(statement)
    
    def insere_corretor(self, cpf: str, especialidade:str, creci:str, regiao_atuação:str): #cadastra um usuário como corretor
        statement = f"""
            INSERT INTO corretor (CPF, especialidade, creci_codigo, regiao_atuação)
            VALUES ('{cpf}', '{especialidade}', '{creci}', '{regiao_atuação}'); \n
        """
        
        return self.db.execute_statement(statement)
    
    def insere_lista_tel_usuário(self, cpf: str, tel_usuario: str): #insere os telefones de um usuário (aqui vc passa uma lista separada por vírgula)
        statement = """
                INSERT INTO tel_usuário(CPF, telefone) VALUES \n
        """
        tel_list_limpa = [tel.strip() for tel in tel_usuario.split(',') if tel.strip()] #para limpar a lista e não quebrar a consulta
        if not tel_list_limpa:
            return

        tam_list= len(tel_list_limpa)

        telefones_atuais_count = self.get_total_telefones_por_cpf(cpf)

        if (telefones_atuais_count + tam_list) > 3:
            return False
        

        for indice, item in enumerate(tel_list_limpa):
            if indice < tam_list - 1:
                statement += f"('{cpf}', '{item}'), \n"
            else:
                statement += f"('{cpf}', '{item}'); \n"

        return self.db.execute_statement(statement)
    
    def get_total_telefones_por_cpf(self, cpf: str) -> int: # obtém o total de telefones cadastrados para um usuário específico
        statement = f"""
            SELECT COUNT(*) AS total
            FROM tel_usuário
            WHERE CPF = '{cpf}';
        """
        resultado = self.db.execute_select_one(statement) 
        
        if resultado and 'total' in resultado:
            return int(resultado['total'])
        
        # Se não encontrar nada, retorna 0
        return 0

    def deleta_tel_usuário(self, cpf: str, tel_usuario: str): # remove os telefones de um usuário (aqui vc passa uma lista separada por vírgula)
        tel_list_limpa = [tel.strip() for tel in tel_usuario.split(',') if tel.strip()] #para limpar a lista e não quebrar a consulta
        if not tel_list_limpa:
            return
        
        telefones_atuais_count = self.get_total_telefones_por_cpf(cpf)
        telefones_para_deletar_count = len(tel_list_limpa)

        if (telefones_atuais_count - telefones_para_deletar_count) < 1:
            return False

        tel_str = "', '".join(tel_list_limpa)

        statement = f"""
            DELETE FROM tel_usuário
            WHERE CPF = '{cpf}' AND telefone IN ('{tel_str}'); \n
        """

        return self.db.execute_statement(statement)
    
    def deleta_usuário(self, cpf: str): #deleta um usuário
        statement = f"""
            DELETE FROM usuário
            WHERE CPF = '{cpf}'; \n
        """
        return self.db.execute_statement(statement)

    def get_perfil_imóvel_adquirente(self, cpf:str): #obtém o perfil de imóveis de um adquirente
        statement=f"""
        SELECT u.prenome, u.sobrenome, i.tipo AS tipo_de_imóvel, i.finalidade, c.tipo AS tipo_de_contrato, COUNT(*) AS total_de_contratos
        FROM usuário u
        JOIN assina a ON u.CPF = a.CPF_adq
        JOIN contrato c ON a.código_c = c.código
        JOIN imóvel i ON c.matrícula_imóvel = i.matrícula
        WHERE u.CPF='{cpf}'
        GROUP BY u.CPF, i.tipo, i.finalidade, c.tipo 
        ORDER BY u.prenome, total_de_contratos DESC;
        """
        return self.db.execute_select_all(statement)

    def get_info_imóvel_proprietário(self, CPF_prop:str): #obtém os imóveis de um proprietário, fornecendo status sobre eles
        statement=f"""
        SELECT i.matrícula, i.logradouro, i.número, c.código, c.status, c.valor, c.data_fim
        FROM imóvel i
        LEFT JOIN contrato c ON i.matrícula = c.matrícula_imóvel
        WHERE i.CPF_prop = '{CPF_prop}'
        """
        lista_imoveis = self.db.execute_select_all(statement)
        
        if not lista_imoveis:
            return []
        
        resposta= []
        hoje = datetime.now().date()
        contrato_db = ContratoDatabase()

        for imovel in lista_imoveis:
            
            status_banco = imovel['status']
            data_fim = imovel['data_fim']
            codigo_contrato = imovel['código']
            
            situacao_final = ""

            if status_banco == 'Ativo' and (data_fim < hoje):
                contrato_db.altera_status_contrato(codigo_contrato, 'Finalizado')
                situacao_final = "Disponível"
            
            elif status_banco == 'Ativo':
                situacao_final = "Alugado"
            
            elif status_banco is None or status_banco == 'Finalizado' or status_banco == 'Cancelado':
                situacao_final = "Disponível"
            
            else: 
                situacao_final = status_banco
            
            resposta.append({
                "matrícula": imovel['matrícula'],
                "logradouro": imovel['logradouro'],
                "número": imovel['número'],
                "situacao_atual": situacao_final,
                "codigo_contrato_recente": codigo_contrato
            })
            
        return resposta