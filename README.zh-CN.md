<div align="center">

<p>
  <img src="docs/brand/wordmark.png" alt="T-Sense pixel wordmark" width="860">
</p>

<h3>机会已经在噪音里了。T-Sense 把真正该看的信号捞出来。</h3>

<p>
  <a href="README.md"><strong>English</strong></a>
  ·
  <a href="#demo"><strong>Demo</strong></a>
  ·
  <a href="#快速开始"><strong>快速开始</strong></a>
  ·
  <a href="#输出效果"><strong>输出效果</strong></a>
  ·
  <a href="#隐私与边界"><strong>隐私</strong></a>
  ·
  <a href="docs/README.md"><strong>Docs</strong></a>
</p>

</div>

T-Sense 是一个 local-first 的 Telegram 信号工作流。它读取你已经有权限访问的
频道，用透明的 Markdown profile 评分，再把频道噪音变成本地可复查的信号报告。

这个仓库是 community open core：本地 scanner、profile 驱动报告、可选 OCR/STT、
HTML 报告模板、测试和公开示例。

私有产品层不在这里：managed dashboard、频道推荐 / 加入 / 文件夹管理、hosted
service、商业工作流、品牌化体验、私有数据包和 packaged app
distribution 都属于这个源码树之外。

## 一眼看懂

| open core 负责什么 | 不属于这个仓库的范围 |
| --- | --- |
| 通过你自己的账号权限读取 Telegram 来源。 | hosted scraping、公开消息索引或完整 Telegram 客户端。 |
| 用 Markdown profile 保持匹配规则可见、可改。 | 用户看不到也审不了的隐藏推荐状态。 |
| 生成带来源链接和运行元数据的 Markdown / HTML 报告。 | managed dashboard、recommendation engine、auto-join、invite 或 folder workflow。 |
| 可选 LLM extraction 和媒体 OCR/STT，provider 由你显式配置。 | managed commercial workflow、private service 或品牌化体验。 |

## Demo

压缩 Demo 视频展示 T-Sense 如何从频道噪音里抽出信号，并生成本地信号简报。

<p align="center">
  <a href="docs/demo.mp4">
    <img src="docs/screenshots/report-header.png" alt="观看 T-Sense demo 视频" width="860">
  </a>
</p>

<p align="center">
  <a href="docs/demo.mp4"><strong>观看 Demo 视频</strong></a>
</p>

## 快速开始

环境要求：

- Python 3.12+。
- 从 [my.telegram.org/apps](https://my.telegram.org/apps) 获取 Telegram API credentials。
- 只有在需要 AI extraction、summary 或媒体 OCR/STT 时，才需要 OpenAI-compatible API key。

```powershell
git clone https://github.com/Sapientropic/t-sense-open-core.git
cd t-sense-open-core
py -3.12 -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install -r requirements.txt -r requirements-llm.txt
Copy-Item config.example.toml config.toml
```

把 Telegram `api_id` 和 `api_hash` 填进 `config.toml`。如果 Telegram 表单不稳定，
看 [docs/getting-api-credentials.md](docs/getting-api-credentials.md)。

## 第一轮扫描

频道列表是一行一个 Telegram channel username：

```text
# channel_lists/my-channels.txt
bloomberg
reutersworldchannel
CoinDeskGlobal
```

运行扫描：

```powershell
python scripts/scan.py channel_lists/example.txt 24 --output-dir output
```

scanner 只读取你账号本来就能访问的频道。扫描结果、日志、session 和报告都留在本地，
不会提交到 Git。

## Profiles

Profile 是 Markdown 规则，定义什么算信号：主题、实体、关键词、排除规则、输出标签
和报告偏好。

```powershell
python scripts/report.py `
  --input output/scan_YYYYMMDD_HHMMSS.jsonl `
  --profile profiles/example-market-news.md `
  --output output/report.md
```

一条命令完成扫描和 HTML 报告：

```powershell
python scripts/daily_report.py channel_lists/market-news.txt `
  --profile profiles/example-market-news.md `
  --html `
  --output-dir output
```

starter profile 和 custom profile section 见 [profiles/README.md](profiles/README.md)。

## 输出效果

每次报告都可以生成自包含暗色主题 HTML，包含卡片、来源链接、判断标签、诊断信息和运行元数据。

<table>
  <tr>
    <td width="50%">
      <img src="docs/screenshots/report-header.png" alt="报告顶部">
    </td>
    <td width="50%">
      <img src="docs/screenshots/report-cards.png" alt="报告卡片">
    </td>
  </tr>
</table>

生成产物留在本地，不进 Git：

| 路径 | 用途 |
| --- | --- |
| `output/scan_*.jsonl` | 本地扫描结果。 |
| `output/*.meta.json` | 扫描元数据和 incomplete-scan 诊断。 |
| `output/*.md` / `output/*.html` | 生成的 Markdown / HTML 报告。 |
| `*.session` / `.t-sense/` | 本地 Telegram/session/runtime 状态。 |

## 隐私与边界

- Telegram 访问通过 Telethon / MTProto，只读取你本来就能访问的来源。
- `config.toml`、session、`.env`、生成报告和私有频道列表不要进 Git。
- 不需要联系方式时，调用 LLM 前加 `--redact-contact-info`。
- 媒体 OCR/STT 默认关闭；开启后，选中的媒体内容可能会发送到你配置的 provider。
- 大规模扫描或自动化扫描前，先看 [docs/tos-risk-analysis.md](docs/tos-risk-analysis.md)。

## 开发

```powershell
python -m pip install -r requirements.txt -r requirements-llm.txt -r requirements-dev.txt
python -m ruff check .
python -m pytest -q
```

## 仓库结构

| 路径 | 用途 |
| --- | --- |
| `scripts/` | 扫描、报告生成、OCR/STT helper 和 daily pipeline。 |
| `profiles/` | 公开 Markdown profile 示例。 |
| `channel_lists/` | 安全示例频道列表。 |
| `templates/` | HTML 报告模板和前端资源。 |
| `docs/` | 公开 setup、license、风险说明、截图和 demo 材料。 |
| `tests/` | public core 回归测试。 |

## Community / Commercial

Community open core 使用 `AGPL-3.0-only`，适合个人使用、研究、自托管、开放协作，
以及能接受 AGPL 义务的商业使用。

Sapientropic 可以单独提供商业产品或商业授权；这些能力不由本仓库直接授权。

品牌名称和资产不随 AGPL 代码授权。fork、再分发 build、hosted service、app bundle
和 bot 必须遵守 [TRADEMARKS.md](TRADEMARKS.md)。贡献需遵守
[CONTRIBUTING.md](CONTRIBUTING.md) 和 [docs/licensing.md](docs/licensing.md)。
