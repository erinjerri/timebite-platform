import sys
from dotenv import load_dotenv
from openai import OpenAI
import os

load_dotenv()

client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

query = " ".join(sys.argv[1:])

response = client.responses.create(
    model="gpt-4.1",
    input=f"""
Research this topic for system design.

Topic:
{query}

Return:
- techniques
- libraries
- architecture suggestions
"""
)

print(response.output_text)
