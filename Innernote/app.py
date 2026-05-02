from flask import Flask, render_template, request, jsonify
import sqlite3
from datetime import datetime

app = Flask(__name__)

def init_db():
    with sqlite3.connect('innernote.db') as conn:
        conn.execute('''
            CREATE TABLE IF NOT EXISTS logs (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                mood TEXT, mood_score INTEGER,
                body TEXT, body_score INTEGER,
                memo TEXT, date TEXT
            )
        ''')

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/save', methods=['POST'])
def save():
    data = request.json
    with sqlite3.connect('innernote.db') as conn:
        conn.execute('INSERT INTO logs (mood, mood_score, body, body_score, memo, date) VALUES (?, ?, ?, ?, ?, ?)',
                     (data['mood'], data['moodScore'], data['body'], data['bodyScore'], data['memo'], datetime.now().strftime('%m/%d %H:%M')))
    return jsonify({'status': 'success'})

@app.route('/logs', methods=['GET'])
def get_logs():
    with sqlite3.connect('innernote.db') as conn:
        conn.row_factory = sqlite3.Row
        logs = [dict(row) for row in conn.execute('SELECT * FROM logs ORDER BY id DESC').fetchall()]
    return jsonify(logs)

if __name__ == '__main__':
    init_db()
    app.run(host='0.0.0.0', port=5000)
