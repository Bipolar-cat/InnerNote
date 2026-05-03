from flask import Flask, render_template
import os

# テンプレートの場所を明示的に指定する設定です
app = Flask(__name__, template_folder='templates')

@app.route('/')
def index():
    # index.html が見つからない場合に備えて、エラーを出しやすくします
        return render_template('index.html')

        if __name__ == '__main__':
            app.run(debug=True)
            
            