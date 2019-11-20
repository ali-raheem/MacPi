from flask import Flask, request
from sys import exit
app = Flask(__name__)

@app.route('/public_key', methods=['GET', 'POST'])
def exchange_pubkey():
    if request.method == 'POST':
        open('keys/Bob.pub.pem.b64', 'w').write(request.form['pubkey'])
        return open('keys/Alice.pub.pem', 'r').read() #Now quit
    return 'Error'
if __name__ == '__main__':
    app.run()
