#.\venv\Scripts\activate
from flask import Flask, jsonify
from rotas.imóvel import imovel_blueprint
from rotas.usuário import usuário_blueprint
from rotas.contrato import contrato_blueprint
from rotas.pagamento import pagamento_blueprint 
from rotas.auth import auth_blueprint 
from flask_cors import CORS
from flask_mail import Mail
import os 

app = Flask(__name__)

app.config['SECRET_KEY'] = "'ba632747b4b0046d63f2b0bf86a15015ea967f477363b3255b3340e9f59aba3b'" 

CORS(app, origins="*")

@app.route("/", methods=["GET"])
def resposta_estado():
    return jsonify("It is alive"),200

app.register_blueprint(imovel_blueprint)
app.register_blueprint(usuário_blueprint)
app.register_blueprint(contrato_blueprint)
app.register_blueprint(pagamento_blueprint)
app.register_blueprint(auth_blueprint) 

# configuração de gmail
app.config['MAIL_SERVER'] = 'smtp.gmail.com'
app.config['MAIL_PORT'] = 587
app.config['MAIL_USE_TLS'] = True
app.config['MAIL_USERNAME'] = 'corretora.aura.smtp@gmail.com' 
app.config['MAIL_PASSWORD'] = 'pjzmwlbysixhmcqp' 
app.config['MAIL_DEFAULT_SENDER'] = 'corretora.aura.smtp@gmail.com'

mail = Mail(app)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000, debug=False) 