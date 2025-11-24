from typing import Any
import psycopg2
from psycopg2.extras import DictCursor

class DatabaseManager:
    "Classe de Gerenciamento do database"

    #estabelece conexao com o banco de dados PostgreSQL
    def __init__(self) -> None:
        self.conn = psycopg2.connect(
            dbname="imobiliaria",
            user="postgres",
            password="postgres",
            host="127.0.0.1",
            port=5432,
        )
        self.cursor = self.conn.cursor(cursor_factory=DictCursor)

    def __execute_query(self, statement: str, params: tuple = None, fetch_one=False, fetch_all=False):
        """
        Método privado para executar consultas de forma segura.
        """
        if self.conn is None:
            raise ConnectionError("Conexão com o banco de dados não está ativa.")
        
        #usamos DictCursor para que os resultados sejam dicionarios
        with self.conn.cursor(cursor_factory=DictCursor) as cursor:
            try:
                if params:
                    cursor.execute(statement, params)
                else:
                    cursor.execute(statement)

                # Para SELECT
                if fetch_one:
                    row = cursor.fetchone()
                    return dict(row) if row else None
                if fetch_all:
                    rows = cursor.fetchall()
                    return [dict(r) for r in rows]

                # Para INSERT/UPDATE/DELETE
                self.conn.commit()
                return True
            
            except Exception as e:
                self.conn.rollback() 
                print(f"Erro ao executar statement: {e}")
                raise e

    def execute_statement(self, statement: str, params: tuple = None):
        """ Executa INSERT, UPDATE, DELETE (e commita) """
        return self.__execute_query(statement, params)

    def execute_select_one(self, statement: str, params: tuple = None):
        """ Executa um SELECT e retorna UMA linha """
        return self.__execute_query(statement, params, fetch_one=True)

    def execute_select_all(self, statement: str, params: tuple = None):
        """ Executa um SELECT e retorna TODAS as linhas """
        return self.__execute_query(statement, params, fetch_all=True)

    def __del__(self):
        """ Garante que a conexão seja fechada """
        if self.conn:
            self.conn.close()