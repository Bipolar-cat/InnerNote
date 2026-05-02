sudo apt update
sudo apt upgrad -y
sudo apt upgrade -y
sudo apt install phyton3 phyton3-pip -y
mkdir Innernote
cd Innernote
sudo apt update
sudo apt install python3
pip3 install flask
cd -/Innote
Innernoto/
app.py
templates/
index.html
statik/
style.css
from flask import Flask, render_template, request, redirect, url_for, g
import sqlite3
from datetime import datetime, timedelta
import os
app = Flask(__name__)
DATABASE = os.path.join(os.path.dirname(__file__), "innernote.db")
def get_db():
@app.teardown_appcontext
def close_db(exception):
def setup():
def index():
if __name__ == "__main__":;     app.run(host="0.0.0.0", port=5000, debug=True)
cd ~/Innernote
mkdir -p templates
cat << 'EOF' > ~/Innernote/app.py
from flask import Flask, render_template, request, jsonify
import sqlite3
from datetime import datetime

app = Flask(__name__)

# データベースを初期化（テーブルがなければ作成）
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
    # スマホから localhost:5000 でアクセス可能にする
    app.run(host='0.0.0.0', port=5000)
EOF

cat << 'EOF' > ~/Innernote/templates/index.html
<!DOCTYPE html>
<html lang="ja">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>InnerNote</title>
  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
  <style>
    body { font-family: sans-serif; background: #f5f5f5; text-align: center; padding: 20px; color: #333; }
    .box { background: white; padding: 20px; border-radius: 12px; max-width: 450px; margin: auto; box-shadow: 0 4px 10px rgba(0,0,0,0.1); }
    .btn-group { display: flex; justify-content: center; gap: 10px; margin-bottom: 10px; }
    button { padding: 10px; border-radius: 8px; border: 1px solid #ddd; cursor: pointer; background: #fff; flex: 1; }
    textarea { width: 100%; margin-top: 15px; padding: 12px; border: 1px solid #ddd; border-radius: 8px; box-sizing: border-box; }
    .save-btn { background: #4a90e2; color: white; border: none; width: 100%; margin-top: 15px; font-weight: bold; height: 45px; }
    .chart-container { margin-top: 25px; border-top: 2px solid #f0f0f0; padding-top: 15px; }
    .log-item { border-bottom: 1px solid #eee; padding: 10px 0; text-align: left; font-size: 13px; }
  </style>
</head>
<body>
<div class="box">
  <h2>InnerNote</h2>
  <p>気分と体調を記録</p>
  <div class="btn-group" id="mood-btns">
    <button onclick="setMood('低', 1)">低</button><button onclick="setMood('普通', 2)">普通</button><button onclick="setMood('良い', 3)">良い</button>
  </div>
  <div class="btn-group" id="body-btns">
    <button onclick="setBodyStatus('悪い', 1)">悪い</button><button onclick="setBodyStatus('普通', 2)">普通</button><button onclick="setBodyStatus('良い', 3)">良い</button>
  </div>
  <textarea id="memo" placeholder="メモを残す..."></textarea>
  <button class="save-btn" onclick="saveLog()">記録する</button>
  <div class="chart-container"><canvas id="myChart"></canvas></div>
  <div id="logArea"></div>
</div>
<script>
let mood = {text: "", score: 0}, body = {text: "", score: 0};
function setMood(t, s) { mood = {text: t, score: s}; highlight('mood-btns', t); }
function setBodyStatus(t, s) { body = {text: t, score: s}; highlight('body-btns', t); }
function highlight(id, val) {
  const btns = document.getElementById(id).getElementsByTagName('button');
  for (let b of btns) b.style.background = b.innerText === val ? "#e0f0ff" : "#fff";
}
async function saveLog() {
  if (!mood.text || !body.text) return alert("両方選択してください");
  await fetch('/save', {
    method: 'POST',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify({mood: mood.text, moodScore: mood.score, body: body.text, bodyScore: body.score, memo: document.getElementById('memo').value})
  });
  location.reload();
}
async function loadData() {
  const res = await fetch('/logs');
  const logs = await res.json();
  const chartData = [...logs].reverse().slice(-7);
  document.getElementById('logArea').innerHTML = logs.map(l => `
    <div class="log-item"><strong>【${l.date}】</strong> 気分: ${l.mood} / 体: ${l.body}<br>${l.memo}</div>
  `).join('');
  new Chart(document.getElementById('myChart'), {
    type: 'line',
    data: {
      labels: chartData.map(d => d.date.split(' ')[0]),
      datasets: [{ label: '気分', data: chartData.map(d => d.mood_score), borderColor: '#4a90e2' },
                 { label: '体調', data: chartData.map(d => d.body_score), borderColor: '#ffcc00' }]
    },
    options: { scales: { y: { min: 1, max: 3 } } }
  });
}
loadData();
</script>
</body>
</html>
EOF

cat << 'EOF' > ~/Innernote/app.py
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
EOF

pip3 install flask
python3 ~/Innernote/app.py
sudo apt update
sudo apt install python3-pip -y
pip3 install flask
cat << 'EOF' > ~/Innernote/templates/index.html
<!DOCTYPE html>
<html lang="ja">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>InnerNote</title>
  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
  <style>
    body { font-family: sans-serif; background: #f5f5f5; text-align: center; padding: 20px; color: #333; }
    .box { background: white; padding: 20px; border-radius: 12px; max-width: 450px; margin: auto; box-shadow: 0 4px 10px rgba(0,0,0,0.1); }
    h2 { color: #4a90e2; margin-bottom: 20px; }
    .section-title { font-weight: bold; margin-top: 15px; margin-bottom: 8px; font-size: 14px; text-align: left; padding-left: 10px; border-left: 4px solid #4a90e2; }
    .btn-group { display: flex; justify-content: center; gap: 8px; margin-bottom: 15px; }
    .btn-container { flex: 1; display: flex; flex-direction: column; align-items: center; }
    .btn-label { font-size: 11px; color: #777; margin-bottom: 4px; }
    button { width: 100%; padding: 12px 5px; border-radius: 8px; border: 1px solid #ddd; cursor: pointer; background: #fff; font-size: 14px; transition: 0.2s; }
    textarea { width: 100%; margin-top: 15px; padding: 12px; border: 1px solid #ddd; border-radius: 8px; box-sizing: border-box; font-size: 15px; min-height: 80px; }
    .save-btn { background: #4a90e2; color: white; border: none; width: 100%; margin-top: 20px; font-weight: bold; height: 48px; border-radius: 8px; font-size: 16px; }
    .chart-container { margin-top: 25px; border-top: 2px solid #f0f0f0; padding-top: 20px; }
    .log-item { border-bottom: 1px solid #eee; padding: 12px 0; text-align: left; font-size: 13px; line-height: 1.5; }
    .log-date { color: #888; font-size: 11px; }
  </style>
</head>
<body>
<div class="box">
  <h2>InnerNote</h2>
  
  <p class="section-title">今日の気分</p>
  <div class="btn-group" id="mood-btns">
    <div class="btn-container"><span class="btn-label">低い</span><button onclick="setMood('低', 1)">低</button></div>
    <div class="btn-container"><span class="btn-label">普通</span><button onclick="setMood('普通', 2)">普通</button></div>
    <div class="btn-container"><span class="btn-label">良い</span><button onclick="setMood('良い', 3)">良い</button></div>
  </div>

  <p class="section-title">体の調子</p>
  <div class="btn-group" id="body-btns">
    <div class="btn-container"><span class="btn-label">悪い</span><button onclick="setBodyStatus('悪い', 1)">悪い</button></div>
    <div class="btn-container"><span class="btn-label">普通</span><button onclick="setBodyStatus('普通', 2)">普通</button></div>
    <div class="btn-container"><span class="btn-label">良い</span><button onclick="setBodyStatus('良い', 3)">良い</button></div>
  </div>

  <textarea id="memo" placeholder="今の状態をメモ..."></textarea>
  <button class="save-btn" onclick="saveLog()">記録を保存する</button>

  <div class="chart-container"><canvas id="myChart"></canvas></div>
  <div id="logArea"></div>
</div>

<script>
let mood = {text: "", score: 0}, body = {text: "", score: 0};

function setMood(t, s) { mood = {text: t, score: s}; highlight('mood-btns', t); }
function setBodyStatus(t, s) { body = {text: t, score: s}; highlight('body-btns', t); }

function highlight(id, val) {
  const btns = document.getElementById(id).getElementsByTagName('button');
  for (let b of btns) {
    b.style.background = b.innerText === val ? "#e0f0ff" : "#fff";
    b.style.borderColor = b.innerText === val ? "#4a90e2" : "#ddd";
  }
}

async function saveLog() {
  if (!mood.text || !body.text) return alert("気分と体調を選択してください");
  await fetch('/save', {
    method: 'POST',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify({mood: mood.text, moodScore: mood.score, body: body.text, bodyScore: body.score, memo: document.getElementById('memo').value})
  });
  location.reload();
}

async function loadData() {
  const res = await fetch('/logs');
  const logs = await res.json();
  const chartData = [...logs].reverse().slice(-7);
  
  document.getElementById('logArea').innerHTML = logs.map(l => `
    <div class="log-item">
      <div class="log-date">${l.date}</div>
      <strong>気分: ${l.mood} ／ 体調: ${l.body}</strong><br>
      ${l.memo || '<span style="color:#ccc">メモなし</span>'}
    </div>
  `).join('');

  new Chart(document.getElementById('myChart'), {
    type: 'line',
    data: {
      labels: chartData.map(d => d.date.split(' ')[0]),
      datasets: [
        { label: '気分', data: chartData.map(d => d.mood_score), borderColor: '#4a90e2', tension: 0.3 },
        { label: '体調', data: chartData.map(d => d.body_score), borderColor: '#ffcc00', tension: 0.3 }
      ]
    },
    options: { scales: { y: { min: 1, max: 3, ticks: { stepSize: 1, callback: v => v==3?'良い':v==2?'普通':'低' } } } }
  });
}
loadData();
</script>
</body>
</html>
EOF

cd ~/Innernote
python3 app.py
