#!/usr/bin/python
# coding: utf-8

from sys import stdin
from sys import argv
import smtplib
import datetime


# Configuracion cuenta
SERVER = 'smtp.gmail.com'
PORT = 587
USERNAME = 'eduardo.grosclaude'
PASSWORD = 'intifadajsbachrules1960'
# Puede ser la salida del comando hostname
SENDER = 'betsyrc'

USE_TLS = True

def sendMail(SENDER, (USERNAME, PASSWORD), RECIPIENTS, subject, text, html = False):

    text = text.replace("\\n", "\n");

    headers = "From: %s\r\n" % (SENDER, )
    headers += "To: %s\r\n" % (RECIPIENTS, )
    headers += "Subject: %s\r\n\r\n" % (subject, )
    if html == True:
        headers += "Content-Type: text/html;\r\n"

    message = headers + text

    # Send message
    s = smtplib.SMTP(SERVER, PORT)
    if USE_TLS:
        s.ehlo()
        s.starttls()
        s.ehlo()
    s.login(USERNAME, PASSWORD)
    s.sendmail(SENDER, RECIPIENTS, message)
    s.quit()

if __name__ == "__main__":
    #Para
    #Definido aca o el segundo parametro
    #RECIPIENTS = ['luiscoralle@gmail.com']
    RECIPIENTS = argv[1]
    
    subject = argv[2]
    text=''

    for line in stdin:
        text += line 

    sendMail(SENDER, (USERNAME,PASSWORD), RECIPIENTS, subject, text)
