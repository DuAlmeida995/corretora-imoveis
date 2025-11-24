from functools import wraps
from flask import request, jsonify, current_app 
import jwt

def token_obrigatorio(f):
    @wraps(f)
    def decorator(*args, **kwargs):
        '''Verifica se o token JWT de acesso está presente e é válido'''
        auth_header = request.headers.get('Authorization')
        if not auth_header or not auth_header.startswith("Bearer "):
            return jsonify({"error": "Token ausente"}), 401

        token = auth_header.split(" ")[1]
        try:
            payload = jwt.decode(token, current_app.config['SECRET_KEY'], algorithms=["HS256"])
            
            if payload["type"] != "access":
                return jsonify({"error": "Token inválido (não é de acesso)"}), 401 
            
            request.cpf_usuario = payload["cpf"] 

        except jwt.ExpiredSignatureError:
            return jsonify({"error": "Token expirado"}), 401
        except jwt.InvalidTokenError:
            return jsonify({"error": "Token inválido"}), 401

        return f(*args, **kwargs)
    return decorator 