#.\venv\Scripts\activate
from flask import Flask, jsonify
from rotas.imóvel import imovel_blueprint
from rotas.usuário import usuário_blueprint
from rotas.contrato import contrato_blueprint
from rotas.pagamento import pagamento_blueprint 
from rotas.auth import auth_blueprint 
from flask_cors import CORS
import os 

app = Flask(__name__)

# 2. CONFIGURE A SECRET_KEY
#    (Mude para uma string longa e aleatória)
app.config['SECRET_KEY'] = "sua_chave_secreta_super_segura_mude_isso_depois" 

CORS(app, origins="*")

@app.route("/", methods=["GET"])
def resposta_estado():
    return jsonify("It is alive"),200

app.register_blueprint(imovel_blueprint)
app.register_blueprint(usuário_blueprint)
app.register_blueprint(contrato_blueprint)
app.register_blueprint(pagamento_blueprint)
app.register_blueprint(auth_blueprint) 

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000, debug=False) 