from __future__ import annotations

from enum import StrEnum
from functools import lru_cache

from pydantic import Field, SecretStr, field_validator, model_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Environment(StrEnum):
    development = "development"
    test = "test"
    production = "production"


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=None,
        env_prefix="TIMEBITE_",
        case_sensitive=False,
        extra="ignore",
    )

    environment: Environment = Environment.development
    mongo_uri: SecretStr
    mongo_database: str = "timebite"
    apple_client_id: str
    jwt_signing_key: SecretStr = Field(min_length=32)
    token_encryption_key: SecretStr
    access_token_minutes: int = Field(default=15, ge=5, le=60)
    refresh_token_days: int = Field(default=30, ge=1, le=90)
    allowed_origins: list[str] = []
    public_base_url: str
    plaid_environment: str = "sandbox"
    plaid_client_id: SecretStr | None = None
    plaid_secret: SecretStr | None = None
    plaid_redirect_uri: str | None = None
    plaid_webhook_verification: bool = True
    rate_limit_per_minute: int = Field(default=120, ge=10, le=10_000)

    @field_validator("public_base_url")
    @classmethod
    def validate_public_url(cls, value: str) -> str:
        value = value.rstrip("/")
        if not value.startswith(("http://", "https://")):
            raise ValueError("must be an absolute HTTP(S) URL")
        return value

    @field_validator("token_encryption_key")
    @classmethod
    def validate_encryption_key(cls, value: SecretStr) -> SecretStr:
        import base64

        try:
            decoded = base64.urlsafe_b64decode(value.get_secret_value())
        except Exception as exc:
            raise ValueError("must be URL-safe base64") from exc
        if len(decoded) != 32:
            raise ValueError("must decode to exactly 32 bytes")
        return value

    @model_validator(mode="after")
    def validate_environment(self) -> "Settings":
        if self.plaid_environment not in {"sandbox", "production"}:
            raise ValueError("plaid_environment must be sandbox or production")
        if self.environment != Environment.production and self.plaid_environment != "sandbox":
            raise ValueError("non-production deployments must use Plaid Sandbox")
        if self.environment == Environment.production:
            if not self.public_base_url.startswith("https://"):
                raise ValueError("production public_base_url must use HTTPS")
            if any("localhost" in origin or "127.0.0.1" in origin for origin in self.allowed_origins):
                raise ValueError("production CORS cannot allow localhost")
        if self.plaid_redirect_uri and not self.plaid_redirect_uri.startswith("https://"):
            raise ValueError("plaid_redirect_uri must use HTTPS")
        return self


@lru_cache
def get_settings() -> Settings:
    return Settings()  # type: ignore[call-arg]
