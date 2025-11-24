from serviços.database.conector import DatabaseManager
from utils.hash import verificar_hash_senha 
import datetime
from datetime import timezone
import jwt

class AuthDatabase:
    '''Classe para operações de banco de dados relacionadas à autenticação e usuários.'''
    def __init__(self, db_provider=None) -> None:
        '''Inicializa a conexão com o banco de dados'''
        if db_provider is None:
            self.db = DatabaseManager()
        else:
            self.db = db_provider

    def get_corretor_profile(self, cpf: str):
        """Busca detalhes específicos do corretor e telefones em uma única query eficiente."""
        statement = """
            SELECT 
                c.especialidade, 
                c.creci_codigo AS creci, 
                c.regiao_atuacao,
                STRING_AGG(t.telefone, ',') AS telefone_contato
            FROM corretor c
            LEFT JOIN tel_usuario t ON c.CPF = t.CPF
            WHERE c.CPF = %s
            GROUP BY c.CPF, c.especialidade, c.creci_codigo, c.regiao_atuacao;
        """
        return self.db.execute_select_one(statement, (cpf,))

    def get_user_telephones(self, cpf: str):
        """Busca telefones para usuários que não são corretores (fallback)."""
        statement = """
            SELECT STRING_AGG(telefone, ',') AS telefone_contato
            FROM tel_usuario
            WHERE CPF = %s;
        """
        resultado = self.db.execute_select_one(statement, (cpf,))
        return resultado.get('telefone_contato') if resultado else None

    def validar_login(self, cpf: str, senha_fornecida: str):
        """Verifica o CPF e a senha, e retorna os dados completos do usuário/corretor."""
        
        statement_login = "SELECT senha FROM login WHERE CPF = %s"
        resultado_login = self.db.execute_select_one(statement_login, (cpf,))
        if not resultado_login or not verificar_hash_senha(senha_fornecida, resultado_login['senha']):
            return None 

        statement_usuario = """
            SELECT prenome, sobrenome, email, data_nasc, profile_image_url
            FROM usuario WHERE CPF = %s
        """
        usuario = self.db.execute_select_one(statement_usuario, (cpf,))
        if not usuario:
            return None
            
        usuario['cpf'] = cpf
        
        corretor_detalhes = self.get_corretor_profile(cpf)
        
        if corretor_detalhes:
            usuario.update({
                'especialidade': corretor_detalhes.get('especialidade'),
                'creci': corretor_detalhes.get('creci'),
                'regiaoAtuacao': corretor_detalhes.get('regiao_atuacao'),
                'telefone': corretor_detalhes.get('telefone_contato'),
            })
        else:
            usuario.update({
                'especialidade': None,
                'creci': None,
                'regiaoAtuacao': None,
                'telefone': self.get_user_telephones(cpf) 
            })
            
        for key, value in usuario.items():
            if value is None:
                usuario[key] = ''

        return usuario

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

    def get_user_email(self, cpf: str):
        """Busca o e-mail do usuário no banco (usado pelo EmailService)."""
        statement = "SELECT email FROM usuario WHERE CPF = %s"
        resultado = self.db.execute_select_one(statement, (cpf,))
        return resultado if resultado else None

    def save_otp_for_cpf(self, cpf: str, otp_code: str):
        """
        Salva o código OTP no banco com um tempo de expiração (10 minutos).
        Assume que existe uma tabela 'otp_codes' com colunas CPF, otp_code, expires_at.
        """
        expires_at = datetime.datetime.now(timezone.utc) + datetime.timedelta(minutes=10)        
        
        statement = """
            INSERT INTO otp_codes (CPF, otp_code, expires_at)
            VALUES (%s, %s, %s)
            ON CONFLICT (CPF) DO UPDATE
            SET otp_code = EXCLUDED.otp_code, expires_at = EXCLUDED.expires_at;
        """
        params = (cpf, otp_code, expires_at)
        
        try:
            self.db.execute_statement(statement, params)
            return True
        except Exception as e:
            print(f"Erro ao salvar OTP: {e}")
            return False

    def validate_otp_code(self, cpf: str, otp_code: str):
        """
        Verifica se o código OTP é válido e não expirou.
        Se for válido, ele o invalida (deleta) para evitar reutilização.
        """
        now = datetime.datetime.now(timezone.utc)
        
        statement_select = """
            SELECT otp_code, expires_at 
            FROM otp_codes
            WHERE CPF = %s;
        """
        resultado = self.db.execute_select_one(statement_select, (cpf,))
        
        if not resultado:
            return False
            
        is_valid = (resultado['otp_code'] == otp_code and resultado['expires_at'] > now)
        
        if is_valid:
            return True
        else:
            if resultado['expires_at'] <= now: 
                statement_delete = "DELETE FROM otp_codes WHERE CPF = %s;"
                self.db.execute_statement(statement_delete, (cpf,))                 
            return False

    def update_user_password(self, cpf: str, new_password_hash: str):
        """
        Atualiza o hash da senha na tabela 'login' e invalida quaisquer OTPs pendentes.
        """
        try:
            statement_update = """
                UPDATE login
                SET senha = %s
                WHERE CPF = %s;
            """
            self.db.execute_statement(statement_update, (new_password_hash, cpf))
            
            statement_cleanup = "DELETE FROM otp_codes WHERE CPF = %s;"
            self.db.execute_statement(statement_cleanup, (cpf,))
            
            return True
        except Exception as e:
            print(f"Erro ao atualizar senha do usuário: {e}")
            return False
    