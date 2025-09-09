# テスト用リポジトリ

このリポジトリはCIワークフローのテストを記録するものです。
検討はGitHub Copilotを使っています。

test_repositoryと違い
C++の使用を前提に下記のツールを使用しています。

---
## 使用ツールの説明

- **gcc/g++**  
  C++の標準的なコンパイラ。ソースコード（.cpp）をビルドして実行ファイルを生成します。

- **cppcheck**  
  C++専用の静的解析ツール。バグの可能性やコーディングミス、非推奨な書き方などを検出します。  
  `cppcheck --enable=all --inconclusive --std=c++17 src` のように使います。

- **Google Test**  
  C++向けのユニットテストフレームワーク。テストコード（例：tests/test_main.cpp）を記述し、  
  `g++` でビルドしてテストを自動実行できます。

- **lcov / genhtml**  
  C++コードのテストカバレッジ（網羅率）を計測・HTMLレポート化するツール。  
  `--coverage`付きでビルド・テスト実行後、`lcov`でカバレッジ収集、`genhtml`でHTML化します。

- **reviewdog**  
  静的解析（cppcheck）の結果をPull Request上にインラインコメントとして表示するツール。  
  コードレビュー時に警告が直接見えるため、指摘漏れを防げます。

- **Codecov**  
  テストカバレッジの結果をPRコメントやバッジで可視化するサービス。  
  CIで生成したカバレッジ情報（coverage.info）をアップロードすることで、  
  PR上でカバレッジの増減や詳細レポートを確認できます。

- **AI自動コードレビュー（OpenAI API連携）**
  GitHub ActionsのCIパイプライン内で、OpenAI APIを利用したAIコードレビューを自動実行します。
  push時は変更ファイルのみ、Pull Request時は全C++ファイルを対象に、レビュープロンプト.txtの内容に従ってAIによるレビューコメントを生成し、成果物として保存します。

---
#### ディレクトリ・ファイル構成

```
test_repository_cpp/
├── .github/
│   └── workflows/
│       └── ci.yml         # ← GitHub Actionsのワークフロー定義（C++用に修正）
├── src/
│   └── main.cpp           # ← C++サンプルプログラム
├── tests/
│   └── test_main.cpp      # ← Google Test用テストコード
├── README.md
├── review.py
├── レビュープロンプト.py

```

---
## CI/CDパイプラインの特徴

- **キャッシュ活用による高速化**  
  aptパッケージのダウンロードキャッシュを利用し、依存パッケージのインストール時間を短縮しています。

- **push時**  
  - 変更ファイルのみ`cppcheck`で静的解析を実行し、早期に問題を検出します。
  - 差分C++ファイルのみを対象に、OpenAI APIを使ったAIレビューを自動実行します。

- **Pull Request時**  
  - 依存パッケージのインストール（キャッシュ活用）
  - `reviewdog`でcppcheckの警告をPR上にインライン表示
  - 全C++ファイルを対象に、OpenAI APIを使ったAIレビューを自動実行します。
  - `make`でビルド
  - `make test`でGoogle Testによるテスト実行
  - `lcov`/`genhtml`でテストカバレッジを計測し、HTMLレポートを生成
  - `Codecov`でカバレッジ情報をアップロードし、PRコメントやバッジで可視化

- **カバレッジレポートの確認方法**  
  - 詳細なHTMLレポートはGitHub Actionsの「Artifacts」からダウンロード可能
  - 概要や増減はPRコメントやバッジで即時確認可能

## 参考: PR上での可視化例

- **cppcheckの警告**  
  ![cppcheck-reviewdog-sample](https://user-images.githubusercontent.com/12345678/xxxxxx/reviewdog-cppcheck-sample.png)
- **Codecovのカバレッジバッジ・コメント**  
  ![codecov-sample](https://user-images.githubusercontent.com/12345678/xxxxxx/codecov-sample.png)


## 補足

- CodecovのPRコメントやバッジが表示されない場合は、[codecov.io](https://codecov.io/)でリポジトリを有効化してください。
- reviewdogのコメントは、PRの「Files changed」タブや「Conversation」タブで確認できます。

-

---
#### GitHub Actionsワークフロー例（.github/workflows/ci.yaml）

```yaml
# ===================================================================
# C++プロジェクト用 CI/CDパイプライン
# 目的: push時は変更ファイルのみ静的解析、PR時は網羅的な品質チェックとカバレッジレポート生成
# ===================================================================

name: C++ CI

on:
  # main以外へのpush時に限定して実行
  push:
    branches-ignore:
      - main
  # mainブランチへのPull Request作成時に実行
  pull_request:
    branches:
      - main

jobs:
  # ===================================================================
  # Job 1: push時に変更ファイルのみ静的解析を実行するジョブ
  # ===================================================================
  lint_changed_files:
    if: github.event_name == 'push'
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Cache apt packages
        uses: actions/cache@v4
        with:
          path: /var/cache/apt/archives
          key: ${{ runner.os }}-apt-${{ hashFiles('**/ci.yaml') }}
          restore-keys: |
            ${{ runner.os }}-apt-

      - name: Install cppcheck
        run: sudo apt-get update && sudo apt-get install -y cppcheck

      - name: Get changed C++ files
        id: changed_cpp_files
        run: |
          git fetch origin main
          files=$(git diff --name-only origin/main | grep -E '\.(cpp|hpp|cc|cxx|h)$' || true)
          echo "files<<EOF" >> $GITHUB_OUTPUT
          echo "$files" >> $GITHUB_OUTPUT
          echo "EOF" >> $GITHUB_OUTPUT

      - name: Run cppcheck on changed files
        if: steps.changed_cpp_files.outputs.files != ''
        run: |
          echo "${{ steps.changed_cpp_files.outputs.files }}" | xargs -r -d '\n' -I{} sh -c 'echo "Running cppcheck on {}"; cppcheck --enable=all --inconclusive --std=c++17 "{}"'

      # ここからOpenAIレビュー
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.10'

      - name: Install OpenAI Python client
        run: pip install openai

      - name: Run OpenAI review on changed files
        if: steps.changed_cpp_files.outputs.files != ''
        env:
          OPENAI_API_KEY: ${{ secrets.OPENAI_API_KEY }}
        run: |
          for file in ${{ steps.changed_cpp_files.outputs.files }}; do
            python review.py "$file" > "openai_review_${file//\//_}.txt"
            cat "openai_review_${file//\//_}.txt"
          done

      - name: Upload OpenAI review results
        if: steps.changed_cpp_files.outputs.files != ''
        uses: actions/upload-artifact@v4
        with:
          name: openai-review
          path: openai_review_*.txt

  # ===================================================================
  # Job 2: Pull Request時に網羅的な品質チェックを実行するジョブ
  # ===================================================================
  full_checks:
    if: github.event_name == 'pull_request'
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Cache apt packages
        uses: actions/cache@v4
        with:
          path: /var/cache/apt/archives
          key: ${{ runner.os }}-apt-${{ hashFiles('**/ci.yaml') }}
          restore-keys: |
            ${{ runner.os }}-apt-

      - name: Install dependencies
        run: |
          sudo apt-get update
          sudo apt-get install -y gcc g++ cppcheck cmake lcov libgtest-dev

      - name: Install reviewdog
        run: |
          sudo curl -sfL https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh | sh -s -- -b /usr/local/bin

      - name: Run cppcheck with reviewdog
        run: |
          cppcheck --enable=all --inconclusive --std=c++17 --template="{file}:{line}:{column}: error: {message}" src 2> cppcheck.txt || true
          cat cppcheck.txt | reviewdog -efm="%f:%l:%c: %t%*[^:]: %m" -name="cppcheck" -reporter=github-pr-review -fail-on-error=true
        env:
          REVIEWDOG_GITHUB_API_TOKEN: ${{ secrets.GITHUB_TOKEN }}

      # ここからOpenAIレビュー
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.10'

      - name: Install OpenAI Python client
        run: pip install openai

      - name: Find all C++ source files
        id: cpp_files
        run: |
          find src \( -name '*.cpp' -o -name '*.hpp' -o -name '*.h' -o -name '*.cc' -o -name '*.cxx' \) > cpp_files.txt
          echo "files<<EOF" >> $GITHUB_OUTPUT
          cat cpp_files.txt >> $GITHUB_OUTPUT
          echo "EOF" >> $GITHUB_OUTPUT

      - name: Run OpenAI review on all C++ files
        if: steps.cpp_files.outputs.files != ''
        env:
          OPENAI_API_KEY: ${{ secrets.OPENAI_API_KEY }}
        run: |
          for file in $(cat cpp_files.txt); do
            python review.py "$file" > "openai_review_${file//\//_}.txt"
            cat "openai_review_${file//\//_}.txt"
          done

      - name: Upload OpenAI review results
        if: steps.cpp_files.outputs.files != ''
        uses: actions/upload-artifact@v4
        with:
          name: openai-review
          path: openai_review_*.txt
          
      - name: Build (Makefile)
        run: make

      - name: Run tests (Makefile)
        run: make test

      - name: Upload test results
        if: failure() || success()
        uses: actions/upload-artifact@v4
        with:
          name: test-results
          path: |
            test-results.xml
            coverage.info

      - name: Generate coverage report
        run: |
          lcov --capture --directory . --output-file coverage.info --ignore-errors mismatch
          lcov --remove coverage.info '/usr/*' --output-file coverage.info
          lcov --list coverage.info
          genhtml coverage.info --output-directory coverage-report --ignore-errors mismatch

      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v4
        with:
          files: coverage.info
          token: ${{ secrets.CODECOV_TOKEN }}

# ===================================================================
# 補足
# - Makefileがカバレッジ対応済みなので、CI側でビルドフラグや個別ビルドコマンドは不要
# - push時は変更ファイルのみcppcheck、PR時は全体cppcheck＋make＋make test＋カバレッジ
# - 必要に応じてMakefileやテストターゲット名を調整
# ===================================================================
```

---

このREADMEはGitHub Copilotの支援で作成・更新しています。
