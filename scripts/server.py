from flask import Flask, request
import os, signal

app = Flask(__name__)

@app.route('/public_key', methods=['GET', 'POST'])
def exchange_pubkey():
    if request.method == 'POST':
        open('keys/Bob.pub.pem.b64', 'w').write(request.form['pubkey'])
        return open('keys/Alice.pub.pem', 'r').read() #Now quit
    return 'Error'

@app.route('/quit')
def shutdown():
    os.kill(os.getpid(), signal.SIGTERM)

if __name__ == '__main__':
    app.run(host='0.0.0.0')
