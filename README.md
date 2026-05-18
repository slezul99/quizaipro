# QuizPro

Multi-tenant flashcard learning platform — Flask + SQLite + Tailwind + Alpine.js.

## Local development

```bash
pip install -r requirements.txt
python app.py
# → http://localhost:5000
```

## Production (Railway)

Required environment variables:

| Variable | Required | Purpose |
|---|---|---|
| `SECRET_KEY` | yes | Flask session encryption (generate random 32-byte hex) |
| `GEMINI_API_KEY` | optional | Google AI Studio key for AI features |
| `DATA_DIR` | yes | Path to persistent volume (e.g. `/data`) — for SQLite + uploads |
| `PORT` | auto | Set automatically by Railway |

## Deploy

1. Push to GitHub (private repo)
2. Connect GitHub to Railway
3. Add persistent volume mounted at `/data`
4. Set env vars
5. Deploy
