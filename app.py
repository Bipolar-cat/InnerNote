from flask import Flask, render_template

app = Flask(__name__)

@app.route('/')
def index():
    # データベース関連の処理をすべて削除し、画面を表示するだけにします
    return render_template('index.html')

if __name__ == '__main__':
    app.run(debug=True)
