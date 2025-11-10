from functools import wraps
from flask import request, jsonify
import jwt

# A CHAVE SECRETA - Puxaremos do app.config

def token_obrigatorio(f):
    @wraps(f)
    def decorator(*args, **kwargs):
        # Precisamos do 'app' atual para pegar o .config
        from main import app 
        
        auth_header = request.headers.get('Authorization')
        if not auth_header or not auth_header.startswith("Bearer "):
            return jsonify({"error": "Token ausente"}), 401

        token = auth_header.split(" ")[1]
        try:
            payload = jwt.decode(token, app.config['SECRET_KEY'], algorithms=["HS256"])
            
            if payload["type"] != "access":
                return jsonify({"error": "Token inválido (não é de acesso)"}), 401
            
            # Disponibiliza o CPF para a rota
            request.cpf_usuario = payload["cpf"] 

        except jwt.ExpiredSignatureError:
            return jsonify({"error": "Token expirado"}), 401
        except jwt.InvalidTokenError:
            return jsonify({"error": "Token inválido"}), 401

        return f(*args, **kwargs)
    return decorator