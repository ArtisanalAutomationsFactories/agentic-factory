import os
import requests
import psycopg2
from pgvector.psycopg2 import register_vector

# Infrastructure Endpoints
VAULT_DIR = os.path.expanduser("~/Agentic-Vault/pages")
OLLAMA_URL = "http://localhost:11434/api/embeddings"
DB_CONN = "dbname=agentic_state user=hermes password=sovereign_memory host=localhost port=5433"

def init_db():
    conn = psycopg2.connect(DB_CONN)
    cur = conn.cursor()
    cur.execute("CREATE EXTENSION IF NOT EXISTS vector;")
    cur.execute("""
        CREATE TABLE IF NOT EXISTS documents (
            id SERIAL PRIMARY KEY,
            filename TEXT UNIQUE,
            content TEXT,
            embedding vector(768)
        );
    """)
    conn.commit()
    register_vector(conn)
    return conn

def get_embedding(text):
    payload = {"model": "nomic-embed-text", "prompt": text}
    res = requests.post(OLLAMA_URL, json=payload)
    if res.status_code == 200:
        return res.json().get("embedding")
    else:
        print(f"Ollama API Failure: {res.text}")
        return None

def ingest_vault(conn):
    cur = conn.cursor()
    if not os.path.exists(VAULT_DIR):
        print(f"CRITICAL: Vault directory not found at {VAULT_DIR}")
        return

    for filename in os.listdir(VAULT_DIR):
        if filename.endswith(".md"):
            filepath = os.path.join(VAULT_DIR, filename)
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()

            embedding = get_embedding(content)
            if embedding:
                cur.execute("""
                    INSERT INTO documents (filename, content, embedding)
                    VALUES (%s, %s, %s)
                    ON CONFLICT (filename) DO UPDATE
                    SET content = EXCLUDED.content, embedding = EXCLUDED.embedding;
                """, (filename, content, embedding))
                print(f"SUCCESS: Vectorized and committed {filename}")
    
    conn.commit()

if __name__ == "__main__":
    print("=== Igniting Mempalace Ingestion Engine ===")
    conn = init_db()
    ingest_vault(conn)
    conn.close()
    print("=== State Memory Securely Vaulted ===")
