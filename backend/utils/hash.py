from passlib.context import CryptContext

pwd_context = CryptContext(
    schemes=["argon2"],
    deprecated="auto"
)

def gerar_hash_senha(senha: str) -> str:
    """ Gera um hash seguro da senha usando Argon2 (KDF moderna). """
    return pwd_context.hash(senha)

def verificar_hash_senha(senha_fornecida: str, hash_armazenado: str) -> bool:
    """ Verifica se a senha fornecida bate com o hash Argon2 armazenado. """
    try:
        return pwd_context.verify(senha_fornecida, hash_armazenado)
    except ValueError:
        return False