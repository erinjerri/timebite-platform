from backend.services.finance.plaid_service import PlaidRoutes


class MemoryRepository:
    def __init__(self):
        self.items = {}
        self.sync = None

    def save_item(self, user_id, item_id, access_token):
        self.items[user_id] = {
            "item_id": item_id,
            "access_token": access_token,
            "cursor": "",
        }

    def get_item(self, user_id):
        return self.items.get(user_id)

    def save_transaction_sync(
        self, user_id, *, added, modified, removed, next_cursor
    ):
        self.items[user_id]["cursor"] = next_cursor
        self.sync = (added, modified, removed, next_cursor)


class FakePlaidClient:
    def __init__(self):
        self.cursors = []

    def create_link_token(self, user_id):
        return {"link_token": f"link-{user_id}"}

    def exchange_public_token(self, public_token):
        return {"item_id": "item-1", "access_token": "server-secret-token"}

    def sync_transactions(self, access_token, cursor):
        self.cursors.append(cursor)
        if not cursor:
            return {
                "added": [{"transaction_id": "one"}],
                "modified": [],
                "removed": [],
                "next_cursor": "page-2",
                "has_more": True,
            }
        return {
            "added": [{"transaction_id": "two"}],
            "modified": [],
            "removed": [],
            "next_cursor": "complete",
            "has_more": False,
        }


def test_tokens_remain_in_repository_and_sync_paginates():
    repository = MemoryRepository()
    client = FakePlaidClient()
    routes = PlaidRoutes(repository, client)

    assert routes.create_link_token("user-1") == {"link_token": "link-user-1"}
    assert routes.exchange_token("user-1", "public-token") == {"linked": True}

    response = routes.sync_transactions("user-1")

    assert [item["transaction_id"] for item in response["added"]] == ["one", "two"]
    assert response["next_cursor"] == "complete"
    assert "access_token" not in response
    assert repository.items["user-1"]["access_token"] == "server-secret-token"
    assert client.cursors == [None, "page-2"]

