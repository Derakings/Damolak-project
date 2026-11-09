def test_info_returns_uptime():
    response = client.get("/info")
    assert response.status_code == 200
    body = response.json()
    assert "uptime_seconds" in body
    assert body["uptime_seconds"] >= 0