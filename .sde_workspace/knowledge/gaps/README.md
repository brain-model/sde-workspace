# Gaps de Conhecimento

Este diretório armazena registros estruturados de lacunas identificadas durante a execução dos agentes.

- Cada gap deve ser representado por um arquivo JSON seguindo o template `../templates/gap_template.json`.
- Utilize o script `../system/scripts/resolve_knowledge.sh` para criar gaps automaticamente ao esgotar as fontes internas/curadas.
- Nomeie os arquivos usando o identificador gerado (`GAP-<ISO8601>.json`).
- Atualize o manifest de conhecimento (`../manifest.json`) sempre que um gap for criado ou resolvido.
