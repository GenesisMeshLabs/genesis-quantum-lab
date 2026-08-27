"""
Synthetic lab web application — Phase 2/3 "Lab Workloads".
Ref: 02-Cloud-Infrastructure.md, 06-Roadmap.md (Week 13-16).

This is the "realistic but synthetic application stack" described in
swedish-government-aws-playground-proposal.md's Simulated Application Layer:
a web frontend + API + auth flow + synthetic user records + structured
telemetry, all backed by generated data only. It has NO connection to any
real user, company, or production system, and must only ever be deployed
inside the isolated Research/Sandbox accounts defined in
src/terraform/modules/organization.

Run locally:
    pip install -r requirements.txt
    python app.py
Then open http://localhost:8080
"""
import json
import logging
import os
import secrets
import sys
import time
import uuid
from datetime import datetime, timezone

from faker import Faker
from flask import Flask, jsonify, redirect, render_template, request, session, url_for

app = Flask(__name__)
app.secret_key = os.environ.get("APP_SECRET_KEY", secrets.token_hex(32))

# --- Structured JSON logging (maps to CloudWatch Logs once containerized) ---
logger = logging.getLogger("mqh.lab_app")
logger.setLevel(logging.INFO)
_handler = logging.StreamHandler(sys.stdout)


class JsonFormatter(logging.Formatter):
    def format(self, record):
        payload = {
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "level": record.levelname,
            "message": record.getMessage(),
            "logger": record.name,
        }
        if hasattr(record, "event"):
            payload.update(record.event)
        return json.dumps(payload)


_handler.setFormatter(JsonFormatter())
logger.addHandler(_handler)


def log_event(event_type: str, **fields):
    logger.info(event_type, extra={"event": {"event_type": event_type, **fields}})


# --- Synthetic data generation (never real personal data, see 04-Security-Policy.md) ---
fake = Faker()
Faker.seed(int(os.environ.get("SYNTHETIC_DATA_SEED", "42")))

SYNTHETIC_USER_COUNT = int(os.environ.get("SYNTHETIC_USER_COUNT", "25"))


def generate_synthetic_users(count: int):
    users = []
    for _ in range(count):
        users.append(
            {
                "id": str(uuid.uuid4()),
                "username": fake.user_name(),
                "display_name": fake.name(),
                "email": fake.free_email(),  # synthetic-only, never a real mailbox
                "role": fake.random_element(elements=("researcher", "operator", "viewer")),
                "created_at": fake.date_time_this_year(tzinfo=timezone.utc).isoformat(),
                # Synthetic-only password hash placeholder — never a real credential.
                "password_hash": secrets.token_hex(16),
            }
        )
    return users


SYNTHETIC_USERS = generate_synthetic_users(SYNTHETIC_USER_COUNT)
USERS_BY_USERNAME = {u["username"]: u for u in SYNTHETIC_USERS}

log_event("app_startup", synthetic_user_count=len(SYNTHETIC_USERS))


# --- Health check (used by the ALB target group) ---
@app.route("/healthz")
def healthz():
    return jsonify(status="ok", service="mqh-lab-app", time=datetime.now(timezone.utc).isoformat())


# --- Synthetic auth flow ---
@app.route("/login", methods=["GET", "POST"])
def login():
    if request.method == "GET":
        return render_template("login.html")

    username = request.form.get("username", "")
    password = request.form.get("password", "")
    user = USERS_BY_USERNAME.get(username)

    # Deliberately simple/demonstrative check against synthetic data only —
    # this app is a research target, not a real auth system.
    success = bool(user) and len(password) > 0

    log_event(
        "login_attempt",
        username=username,
        success=success,
        source_ip=request.headers.get("X-Forwarded-For", request.remote_addr),
    )

    if success:
        session["user_id"] = user["id"]
        session["username"] = user["username"]
        return redirect(url_for("dashboard"))

    return render_template("login.html", error="Invalid credentials"), 401


@app.route("/logout")
def logout():
    log_event("logout", username=session.get("username"))
    session.clear()
    return redirect(url_for("login"))


@app.route("/")
@app.route("/dashboard")
def dashboard():
    if "user_id" not in session:
        return redirect(url_for("login"))
    return render_template(
        "dashboard.html",
        username=session.get("username"),
        user_count=len(SYNTHETIC_USERS),
    )


# --- Synthetic API layer ---
@app.route("/api/users")
def api_users():
    if "user_id" not in session:
        return jsonify(error="unauthenticated"), 401
    # Never return password_hash from the API — same discipline as production.
    safe_users = [{k: v for k, v in u.items() if k != "password_hash"} for u in SYNTHETIC_USERS]
    log_event("api_call", endpoint="/api/users", username=session.get("username"))
    return jsonify(users=safe_users)


@app.route("/api/telemetry", methods=["POST"])
def api_telemetry():
    """Synthetic telemetry ingestion endpoint used by lab exercises to
    generate traffic patterns for detection-engineering tests
    (05-Testing-Methodology.md)."""
    payload = request.get_json(silent=True) or {}
    log_event("synthetic_telemetry", **payload)
    return jsonify(received=True), 202


if __name__ == "__main__":
    port = int(os.environ.get("PORT", "8080"))
    app.run(host="0.0.0.0", port=port, debug=os.environ.get("FLASK_DEBUG") == "1")
