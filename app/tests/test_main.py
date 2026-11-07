from fastapi.testclient import TestClient

from main import app

client = TestClient(app)


def test_root_returns_message_and_version():
    response = client.get("/")
    assert response.status_code == 200
    body = response.json()
    assert "message" in body
    assert "version" in body


def test_health_returns_ok():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


def test_unknown_route_returns_404():
    assert client.get("/does-not-exist").status_code == 404
