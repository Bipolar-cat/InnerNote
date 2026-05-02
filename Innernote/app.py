import os
from flask import Flask, render_template, request, jsonify
import sqlite3
from datetime import datetime, timedelta, timezone

app = Flask(__name__)

def init_db():
    with sqlite3.connect('innernote.db') as conn:
        conn.execute('''CREATE TABLE IF NOT EXISTS logs 
            (id INTEGER PRIMARY KEY AUTOINCREMENT, mood TEXT, mood_score INTEGER, body TEXT, body_score INTEGER, memo TEXT, date TEXT)''')

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/save', methods=['POST'])
def save()
    data = request.json
    jst = timezone(timedelta(hours=+9), 'JST')
    now = datetime.now(jst).strftime('%m/%d %H:%M')
    with sqlite3.connect('/opt/render/project/src/innernote.db') as conn:

        conn.execute('INSERT INTO logs (mood, mood_score, body, body_score, memo, date) VALUES (?, ?, ?, ?, ?, ?)',
                     (data['mood'], data['moodScore'], data['body'], data['bodyScore'], data['memo'], now))
    return jsonify({"status": "success"})

@app.route('/logs')
def get_logs as conn:
    conn = sqlite3.connect('/opt/render/project/src/innernote.db')
    
        conn.row_factory = sqlite3.Row
        logs = conn.execute('SELECT * FROM logs ORDER BY id DESC').fetchall()
    return jsonify([dict(log) for log in logs])
