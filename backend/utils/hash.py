import hashlib

def gerar_hash_senha(senha: str) -> str:
    """ Gera um hash SHA256 da senha. """
    return hashlib.sha256(senha.encode()).hexdigest() #hash da senha usando SHA256

def verificar_hash_senha(senha_fornecida: str, hash_armazenado: str) -> bool:
    """ Verifica se o hash da senha fornecida bate com o hash armazenado. """
    return gerar_hash_senha(senha_fornecida) == hash_armazenado#verifica se o hash bate