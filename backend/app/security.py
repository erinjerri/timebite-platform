from __future__ import annotations

import base64
import hashlib
import secrets
from datetime import UTC, datetime, timedelta
from typing import Any
from uuid import uuid4

import httpx
import jwt
from cryptography.hazmat.primitives.ciphers.aead import AESGCM
from jwt.algorithms import RSAAlgorithm

from backend.app.config import Settings
from backend.app.errors import APIError


APPLE_ISSUER = "https://appleid.apple.com"
APPLE_JWKS_URL = "https://appleid.apple.com/auth/keys"


class AppleIdentityVerifier:
    def __init__(self, settings: Settings, client: httpx.AsyncClient | None = None) -> None:
        self.settings = settings
        self.client = client or httpx.AsyncClient(timeout=5)

    async def verify(self, identity_token: str, raw_nonce: str) -> dict[str, Any]:
        try:
            header = jwt.get_unverified_header(identity_token)
            response = await self.client.get(APPLE_JWKS_URL)
            response.raise_for_status()
            key_data = next(key for key in response.json()["keys"] if key["kid"] == header["kid"])
            public_key = RSAAlgorithm.from_jwk(key_data)
            claims = jwt.decode(
                identity_token,
                public_key,
                algorithms=["RS256"],
                audience=self.settings.apple_client_id,
                issuer=APPLE_ISSUER,
                options={"require": ["exp", "iat", "iss", "aud", "sub", "nonce"]},
            )
        except Exception as exc:
            raise APIError(401, "invalid_apple_credential", "Apple identity credential is invalid") from exc
        expected_nonce = hashlib.sha256(raw_nonce.encode()).hexdigest()
        if not secrets.compare_digest(str(claims["nonce"]), expected_nonce):
            raise APIError(401, "invalid_nonce", "Apple identity credential nonce is invalid")
        return claims


class TokenService:
    def __init__(self, settings: Settings) -> None:
        self.settings = settings

    def issue_access(self, user_id: str) -> tuple[str, int]:
        now = datetime.now(UTC)
        seconds = self.settings.access_token_minutes * 60
        token = jwt.encode(
            {
                "sub": user_id,
                "typ": "access",
                "jti": str(uuid4()),
                "iat": now,
                "exp": now + timedelta(seconds=seconds),
                "iss": "timebite-api",
                "aud": "timebite-ios",
            },
            self.settings.jwt_signing_key.get_secret_value(),
            algorithm="HS256",
        )
        return token, seconds

    def verify_access(self, token: str) -> str:
        try:
            claims = jwt.decode(
                token,
                self.settings.jwt_signing_key.get_secret_value(),
                algorithms=["HS256"],
                audience="timebite-ios",
                issuer="timebite-api",
                options={"require": ["sub", "typ", "exp", "iat", "jti"]},
            )
            if claims["typ"] != "access":
                raise ValueError("wrong token type")
            return str(claims["sub"])
        except Exception as exc:
            raise APIError(401, "invalid_access_token", "Access token is invalid or expired") from exc

    @staticmethod
    def new_refresh_token() -> tuple[str, str]:
        raw = secrets.token_urlsafe(48)
        return raw, hashlib.sha256(raw.encode()).hexdigest()

    @staticmethod
    def hash_refresh_token(raw: str) -> str:
        return hashlib.sha256(raw.encode()).hexdigest()


class SecretBox:
    """Application-layer authenticated encryption for Plaid access tokens."""

    def __init__(self, encoded_key: str) -> None:
        self.key = base64.urlsafe_b64decode(encoded_key)

    def encrypt(self, plaintext: str) -> str:
        nonce = secrets.token_bytes(12)
        ciphertext = AESGCM(self.key).encrypt(nonce, plaintext.encode(), b"timebite:plaid:v1")
        return base64.urlsafe_b64encode(nonce + ciphertext).decode()

    def decrypt(self, payload: str) -> str:
        decoded = base64.urlsafe_b64decode(payload)
        return AESGCM(self.key).decrypt(decoded[:12], decoded[12:], b"timebite:plaid:v1").decode()
