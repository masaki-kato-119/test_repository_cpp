import openai
import sys
import os

# APIキーは環境変数から取得
client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

def main():
    # レビュープロンプトとレビュー対象ファイルを読み込む
    with open("レビュープロンプト.txt", "r", encoding="utf-8") as f:
        prompt = f.read()
    with open(sys.argv[1], "r", encoding="utf-8") as f:
        code = f.read()

    # OpenAI APIにリクエスト
    response = client.chat.completions.create(
        model="gpt-4o",  # 必要に応じてモデルを変更
        messages=[
            {"role": "system", "content": prompt},
            {"role": "user", "content": code}
        ],
        max_tokens=2048
    )
    print(response.choices[0].message.content)

if __name__ == "__main__":
    main()