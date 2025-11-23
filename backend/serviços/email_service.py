import random
import datetime
from threading import Thread
from flask import current_app
from flask_mail import Message


class EmailService:
    def __init__(self):
        '''Inicializa o serviço de email com dependência do AuthDatabase para operações relacionadas a usuários.'''
        from serviços.auth import AuthDatabase 
        self.auth_db = AuthDatabase()

    def generate_otp(self, length=6):
        """ Gera um código OTP aleatório de 6 dígitos. """
        return "".join([str(random.randint(0, 9)) for _ in range(length)])

    def _send_async_email(self, app_context, msg):
        ''' Envia email de forma assíncrona. '''
        from main import mail, app

        """ 
        Envia email em uma thread separada.
        O app_context é necessário para que o Flask-Mail funcione fora da requisição principal.
        """
        with app_context:
            try:
                mail.send(msg)
                print(f"✅ Email enviado com sucesso para: {msg.recipients}")
            except Exception as e:
                print(f"❌ ERRO ao enviar email via SMTP: {e}")
               
    def send_otp_email(self, cpf, recipient_email):
        """ 
        Orquestra a geração, o salvamento no banco e o envio assíncrono do OTP.
        """

        from main import app, mail
        app_context = app.app_context() 
        
        otp_code = self.generate_otp()
        success = self.auth_db.save_otp_for_cpf(cpf, otp_code)

        if not success:
            print(f"Falha ao persistir OTP para CPF {cpf}.")
            return False
        
        subject = "Código de Recuperação de Senha - Aura Corretora"
        body = f"""Olá,

Você solicitou a recuperação de senha. Use o código abaixo para continuar:

Código OTP: {otp_code}

Este código é válido por 10 minutos. Se você não solicitou esta alteração, ignore este e-mail.

Atenciosamente,
Sua Equipe de Suporte da Aura.
"""
        
        msg = Message(
            subject=subject,
            recipients=[recipient_email],
            body=body,
            sender=app.config['MAIL_DEFAULT_SENDER']
        )
        
        thr = Thread(target=self._send_async_email, args=[app_context, msg])
        thr.start()
        
        return True