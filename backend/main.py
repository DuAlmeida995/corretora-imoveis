#.\venv\Scripts\activate
from flask import Flask, jsonify
from rotas.imóvel import imovel_blueprint
from flask_cors import CORS

app = Flask(__name__)
CORS(app, origins="*")

@app.route("/", methods=["GET"])
def resposta_estado():
    return jsonify("It is alive"),200

app.register_blueprint(imovel_blueprint)
app.run("0.0.0.0",port=8000,debug=False)