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

```

---
#### GitHub Actionsワークフロー例（.github/workflows/ci.yaml）

# 主なCI/CDパイプラインの流れ

- **push時**  
  - 変更ファイルのみ`cppcheck`で静的解析を実行し、早期に問題を検出します。

- **Pull Request時**  
  - 依存パッケージのインストール  
  - プロジェクト全体に対して`cppcheck`で静的解析  
  - `make`でビルド  
  - `make test`でGoogle Testによるテスト実行  
  - `lcov`/`genhtml`でテストカバレッジを計測し、HTMLレポートを生成  
  - カバレッジレポート（HTML）をアーティファクトとしてアップロード

カバレッジレポートはGitHub Actionsの「Artifacts」からダウンロードして確認できます。

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

      - name: Install cppcheck
        run: sudo apt-get update && sudo apt-get install -y cppcheck

      - name: Get changed C++ files
        id: changed_cpp_files
        run: |
          git fetch origin main
          files=$(git diff --name-only origin/main | grep -E '\.(cpp|hpp|cc|cxx|h)$' || true)
          echo "files=$files" >> $GITHUB_OUTPUT

      - name: Run cppcheck on changed files
        if: steps.changed_cpp_files.outputs.files != ''
        run: |
          for file in ${{ steps.changed_cpp_files.outputs.files }}; do
            echo "Running cppcheck on $file"
            cppcheck --enable=all --inconclusive --std=c++17 $file
          done

  # ===================================================================
  # Job 2: Pull Request時に網羅的な品質チェックを実行するジョブ
  # ===================================================================
  full_checks:
    if: github.event_name == 'pull_request'
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Install dependencies
        run: |
          sudo apt-get update
          sudo apt-get install -y gcc g++ cppcheck cmake lcov libgtest-dev

      - name: Static analysis with cppcheck
        run: cppcheck --enable=all --inconclusive --std=c++17 src

      - name: Build (Makefile)
        run: make

      - name: Run tests (Makefile)
        run: make test

      - name: Generate coverage report
        run: |
          lcov --capture --directory . --output-file coverage.info
          lcov --remove coverage.info '/usr/*' --output-file coverage.info
          lcov --list coverage.info
          genhtml coverage.info --output-directory coverage-report

      - name: Upload coverage report
        uses: actions/upload-artifact@v4
        with:
          name: coverage-report-html
          path: coverage-report

# ===================================================================
# 補足
# - Makefileがカバレッジ対応済みなので、CI側でビルドフラグや個別ビルドコマンドは不要
# - push時は変更ファイルのみcppcheck、PR時は全体cppcheck＋make＋make test＋カバレッジ
# - 必要に応じてMakefileやテストターゲット名を調整
# ===================================================================
```

---

このREADMEはGitHub Copilotの支援で作成・更新しています。
