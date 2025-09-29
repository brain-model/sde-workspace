# Diretório de Handoffs Estruturados

Este diretório armazena os handoffs consolidados entre agentes. Convenções:

- `latest.json`: handoff vigente direcionado ao próximo agente.
- `history/` (opcional): versões anteriores armazenadas com timestamp (`YYYYMMDDTHHMMSSZ_<from>_to_<to>.json`).
- Todos os handoffs devem seguir `../schemas/handoff.schema.json` e ser validados via `../scripts/validate_handoff.sh` antes de uso.
- Arquivos gerados automaticamente devem ser versionados conforme política do PM.
- O campo `handoffs.latest` em `.sde_workspace/system/specs/manifest.json` deve apontar para `latest.json`; atualize-o sempre que um novo handoff for emitido.
- Gere métricas rápidas com `./.sde_workspace/system/scripts/report_handoff_metrics.sh [.sde_workspace/system/handoffs/latest.json] [saida.md]` sempre que validar um handoff.

> **Dica:** utilize `.sde_workspace/system/scripts/compute_artifact_hashes.sh` para recalcular os hashes declarados em `artifacts_produced` antes de enviar o handoff.
