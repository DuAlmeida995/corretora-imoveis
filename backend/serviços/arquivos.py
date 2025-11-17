import os
from flask import Flask, request, jsonify, url_for
from werkzeug.utils import secure_filename
from serviços.usuário import UsuárioDatabase

UPLOAD_FOLDER = os.path.join(os.getcwd(), 'uploads')
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg'}


def allowed_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

# Rota para o upload real
@usuário_blueprint.route("/usuario/upload_foto_perfil", methods=["POST"])
@token_obrigatorio
def upload_foto_perfil():
    cpf = request.cpf_usuario
    
    if 'foto' not in request.files:
        return jsonify({"error": "Nenhum arquivo 'foto' encontrado."}), 400
    
    file = request.files['foto']
    
    if file.filename == '':
        return jsonify({"error": "Nome do arquivo vazio."}), 400
    
    if file and allowed_file(file.filename):
        ext = file.filename.rsplit('.', 1)[1].lower()
        filename = f"{cpf}_profile.{ext}"
        
        # Garante que a pasta uploads exista
        if not os.path.exists(UPLOAD_FOLDER):
            os.makedirs(UPLOAD_FOLDER)
            
        file_path = os.path.join(UPLOAD_FOLDER, filename)
        file.save(file_path)        
        local_url = url_for('static', filename=f'uploads/{filename}', _external=True)

        return jsonify({
            "message": "Upload realizado com sucesso.",
            "url": local_url
        }), 200
    
    return jsonify({"error": "Tipo de arquivo não permitido."}), 400