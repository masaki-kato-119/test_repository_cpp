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
#### GitHub Actionsワークフロー例（.github/workflows/ci.yml）

```yaml
name: C++ CI

on:
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v4

    - name: Install dependencies
      run: |
        sudo apt-get update
        sudo apt-get install -y gcc g++ cppcheck cmake libgtest-dev

    - name: Static analysis with cppcheck
      run: cppcheck --enable=all --inconclusive --std=c++17 src

    - name: Build with make
      run: make

    - name: Run tests (Google Test)
      run: make test
```

---

このREADMEはGitHub Copilotの支援で作成・更新しています。
