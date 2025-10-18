# CLI `sde-scripts`

Coleção de utilitários do SDE para transcrição de PDF e MP4, empacotada como projeto Python gerenciado pelo `uv`.

## Requisitos

- Python 3.10 ou superior
- [`uv`](https://github.com/astral-sh/uv) instalado (ex.: `pipx install uv`)
- Chave de API do Gemini (`GOOGLE_API_KEY` ou `GEMINI_API_KEY`)

## Configuração

```bash
cd .sde_workspace/system/scripts
uv venv                # cria .venv local
source .venv/bin/activate  # Linux/macOS
# No Windows (PowerShell): .venv\Scripts\Activate.ps1
uv pip install --editable .
```

> Use `uv run` se preferir evitar ativar o ambiente: o comando já respeita o `pyproject.toml`.

Configure a variável de ambiente antes de rodar qualquer comando. Você pode usar um arquivo `.env`
na raiz (mesmo diretório do `pyproject.toml`) com o conteúdo abaixo:

```bash
GOOGLE_API_KEY="SUA_CHAVE"
```

> O pacote carrega automaticamente o `.env` através de `python-dotenv`.

Caso prefira definir manualmente:

```bash
export GOOGLE_API_KEY="SUA_CHAVE"
# ou
export GEMINI_API_KEY="SUA_CHAVE"
```

## Uso

### Transcrever vídeo MP4

```bash
uv run transcribe-mp4 caminho/para/video.mp4
# ou, com o ambiente ativo:
transcribe-mp4 caminho/para/video.mp4
```

Saída: arquivo `.md` com a transcrição formatada em Markdown no mesmo diretório do vídeo.

### Processar PDF

```bash
uv run process-pdf caminho/para/documento.pdf
# ou, com o ambiente ativo:
process-pdf caminho/para/documento.pdf
```

Saída: diretório com o nome do PDF contendo `documento.md` e subpasta `img/` com mídias extraídas.

### Orquestrar scripts shell

Liste os scripts `.sh` disponíveis e execute-os via Python, garantindo logs padronizados:

```bash
uv run run-shell-script list
uv run run-shell-script run validate_handoff.sh -- --arg1 valor
```

> Tudo que aparece após `--` é repassado diretamente ao script shell selecionado.

## Dicas adicionais

- Execute `uv pip install --editable .` sempre que adicionar dependências ao `pyproject.toml`.
- Para atualizar o ambiente, rode `uv pip sync pyproject.toml`.
- Se preferir usar apenas um comando, explore `uv run --help`.
- Os scripts chamam a API do Gemini via HTTP; garanta que a rede permita conexão externa e suporte ao protocolo configurado (IPv4/IPv6).
