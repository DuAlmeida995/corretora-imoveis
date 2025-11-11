from serviços.database.conector import DatabaseManager
from utils.hash import verificar_hash_senha 
import datetime
import jwt

class AuthDatabase:

    def __init__(self, db_provider=None) -> None:
        if db_provider is None:
            self.db = DatabaseManager()
        else:
            self.db = db_provider

    def validar_login(self, cpf: str, senha_fornecida: str):
        """
        Verifica o CPF e a senha. Retorna os dados do usuário se for válido.
        Usa consultas parametrizadas (seguras).
        """
        statement_login = "SELECT senha FROM login WHERE CPF = %s" #obtem o hash da senha do login

        try:
            resultado_login = self.db.execute_select_one(statement_login, (cpf,))
        except Exception as e:
            print(f"Erro ao buscar login: {e}")
            return None

        if not resultado_login:
            return None #usuário não encontrado

        hash_armazenado = resultado_login['senha']

        if not verificar_hash_senha(senha_fornecida, hash_armazenado):
            return None #senha inválida

        statement_usuario = """
            SELECT prenome, sobrenome, email, data_nasc 
            FROM usuario WHERE CPF = %s
        """
        try:
            usuario = self.db.execute_select_one(statement_usuario, (cpf,))
            usuario['cpf'] = cpf 
            #podemos buscar aqui também outras informações do usuário, se necessário

            return usuario

        except Exception as e:
            print(f"Erro ao buscar dados do usuário: {e}")
            return None

    def criar_tokens(self, cpf: str, secret_key: str):
        """
        Gera o par de access_token e refresh_token.
        """
    
        exp_access = datetime.datetime.utcnow() + datetime.timedelta(minutes=15) #acess token válido por 15 minutos
        payload_access = {"cpf": cpf, "type": "access", "exp": exp_access}
        access_token = jwt.encode(payload_access, secret_key, algorithm="HS256")

        exp_refresh = datetime.datetime.utcnow() + datetime.timedelta(days=7) #refresh token válido por 7 dias
        payload_refresh = {"cpf": cpf, "type": "refresh", "exp": exp_refresh}
        refresh_token = jwt.encode(payload_refresh, secret_key, algorithm="HS256")

        return access_token, refresh_token

    def renovar_tokens(self, refresh_token: str, secret_key: str):
        """
        Valida um refresh_token e gera um novo par de tokens.
        """
        try:
            payload = jwt.decode(refresh_token, secret_key, algorithms=["HS256"])

            if payload["type"] != "refresh":
                raise jwt.InvalidTokenError("Não é um refresh token.")

            cpf = payload["cpf"]
            return self.criar_tokens(cpf, secret_key)

        except (jwt.ExpiredSignatureError, jwt.InvalidTokenError) as e:
            print(f"Erro ao renovar token: {e}")
            return None