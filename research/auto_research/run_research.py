import sys
import os
from dotenv import load_dotenv
from openai import OpenAI
from datetime import datetime

load_dotenv()

client = OpenAI()

OUTPUT_DIR = "outputs"
os.makedirs(OUTPUT_DIR, exist_ok=True)

query = " ".join(sys.argv[1:])

if not query:
    print("Usage: python run_research.py 'research topic'")
    exit()

prompt = f"""
You are researching system design for an AI application.

Topic:
{query}

Return:
- algorithms used
- libraries / frameworks
- architecture pipeline
- performance considerations
- implementation suggestions
"""

response = client.responses.create(
    model="gpt-4.1",
    input=prompt
)

result = response.output_text

timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
filename = query.replace(" ", "_")[0:40]

filepath = f"{OUTPUT_DIR}/{filename}_{timestamp}.txt"

with open(filepath, "w") as f:
    f.write(result)

print(result)
print(f"\nSaved → {filepath}")
