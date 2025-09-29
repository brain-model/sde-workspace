---
id: template-integrity-validation
title: Template de Validação e Auto-Correção de Integridade
type: template
status: active
version: 1.0.0
created: 2025-09-28
updated: 2025-09-28
---

# Template de Validação e Auto-Correção de Integridade

## 🔍 Checklist de Validação Automática

### Para Knowledge Files

#### ✅ Validações Obrigatórias
- [ ] Arquivo possui frontmatter YAML (---...---)
- [ ] Todos os 7 campos obrigatórios estão presentes
- [ ] Campo `id` é único no sistema
- [ ] Campo `category` corresponde à localização do arquivo
- [ ] Formato de data está correto (ISO-8601)
- [ ] Tags contém status de curadoria
- [ ] Arquivo está listado em `knowledge/manifest.json`

#### 🔧 Auto-Correções Disponíveis

**Frontmatter Ausente:**
```yaml
# Gerar automaticamente baseado na localização e nome do arquivo
---
id: [GENERATED_FROM_FILENAME]
title: [EXTRACTED_FROM_H1_OR_FILENAME]
category: [INFERRED_FROM_PATH]
created: [FILE_CREATION_DATE]
updated: [FILE_MODIFICATION_DATE]
source: "auto-generated"
tags: ["needs-curation"]
---
```

**Campo Faltando:**
```yaml
# Adicionar campos faltantes com valores padrão
updated: [CURRENT_TIMESTAMP]  # Se ausente
tags: ["needs-curation"]      # Se ausente
```

**Categoria Incorreta:**
```yaml
# Corrigir baseado na localização
knowledge/internal/concepts/ → category: concept
knowledge/internal/notes/raw/ → category: note-raw
knowledge/internal/decisions-context/ → category: decision
```

### Para Spec Files

#### ✅ Validações Obrigatórias
- [ ] Frontmatter com todos os campos de spec
- [ ] Status corresponde ao diretório (draft/ → status: draft)
- [ ] Versão segue padrão semântico
- [ ] Referências supersedes/supersededBy são válidas
- [ ] Arquivo está listado em `system/specs/manifest.json`

#### 🔧 Auto-Correções Disponíveis

**Status Inconsistente:**
```yaml
# Se arquivo está em system/specs/draft/ mas status: active
# Correção: status: draft
```

**Manifesto Desatualizado:**
```json
// Adicionar entrada no manifesto
{
  "id": "spec-nome",
  "path": "system/specs/active/spec-nome.md", 
  "checksum": "sha256:...",
  "status": "active",
  "type": "design-doc",
  "topics": ["..."],
  "version": "1.0.0",
  "updated": "2025-09-28"
}
```

## 📋 Fluxos de Correção

### Fluxo 1: Arquivo Novo Detectado

```
1. Detectar arquivo não listado no manifesto
2. Validar frontmatter existente
3. Se frontmatter ausente/incompleto:
   → Gerar frontmatter baseado em heurísticas
   → Solicitar confirmação do usuário
4. Calcular checksum SHA256
5. Adicionar entrada no manifesto
6. Regenerar manifesto ordenado
```

### Fluxo 2: Arquivo Modificado

```
1. Detectar checksum desatualizado no manifesto
2. Validar frontmatter:
   → Atualizar campo 'updated' se necessário
3. Recalcular checksum
4. Atualizar entrada no manifesto
5. Regenerar manifesto
```

### Fluxo 3: Arquivo Mal Localizado

```
1. Comparar category com localização
2. Se inconsistente:
   → Opção A: Mover arquivo para pasta correta
   → Opção B: Corrigir category no frontmatter
3. Solicitar confirmação do usuário
4. Aplicar correção escolhida
5. Atualizar manifesto
```

## 🤖 Mensagens de Interação

### Problema Detectado

```
🔍 VALIDAÇÃO DE INTEGRIDADE DETECTOU PROBLEMAS:

❌ Arquivo: knowledge/internal/concepts/architecture-patterns.md
   Problema: Campo 'updated' ausente no frontmatter
   Solução: Adicionar 'updated: 2025-09-28T15:30:00-03:00'

❌ Arquivo: system/specs/draft/new-feature.md  
   Problema: Não listado no manifesto specs
   Solução: Adicionar entrada com checksum calculado

❌ Arquivo: knowledge/internal/notes/summary/meeting-notes.md
   Problema: Category 'note-raw' incorreta para localização
   Solução: Corrigir para 'meeting-notes' ou mover para notes/raw/

APLICAR CORREÇÕES AUTOMATICAMENTE? [S/n]
```

### Correções Aplicadas

```
✅ CORREÇÕES DE INTEGRIDADE APLICADAS:

✓ architecture-patterns.md: Campo 'updated' adicionado
✓ new-feature.md: Entrada criada no manifesto specs
✓ meeting-notes.md: Category corrigida para 'meeting-notes'

📊 RESUMO:
- 3 problemas detectados
- 3 correções aplicadas
- 0 problemas restantes
- 2 manifestos regenerados

Todos os arquivos estão agora em conformidade! 🎉
```

### Nenhum Problema

```
✅ VALIDAÇÃO DE INTEGRIDADE: APROVADA

📊 Verificações realizadas:
- 23 arquivos knowledge validados
- 8 specs validadas  
- 2 manifestos sincronizados
- Frontmatter completo em 100% dos arquivos
- Nenhum problema de integridade detectado

Base de conhecimento está íntegra e confiável! 🎉
```

## 🔧 Comandos de Auto-Correção

### Heurísticas para Geração de Frontmatter

```yaml
# Para arquivos em knowledge/internal/
id: [filename-without-extension-slugified]
title: [first-h1-header || title-case-filename]
category: [inferred-from-directory-path]
created: [file-creation-timestamp-iso8601]
updated: [file-modification-timestamp-iso8601] 
source: [auto-generated || extracted-from-existing-source]
tags: [needs-curation]

# Para arquivos em system/specs/
id: spec-[filename-slug]
title: [first-h1-header || title-case-filename]
type: [inferred-from-content-or-default-design-doc]
status: [inferred-from-directory-path]
version: 1.0.0
created: [file-creation-date]
updated: [file-modification-date]
supersedes: null
supersededBy: null
relations: []
```

### Cálculo de Checksum

```bash
# SHA256 do conteúdo do arquivo
checksum=$(sha256sum "$filepath" | cut -d' ' -f1)
```

### Validação de Referências

```yaml
# Verificar se IDs em supersedes/relations existem
supersedes: spec-old-api-design  # ✓ Existe
relations: [spec-data-model]     # ✓ Existe  
supersededBy: spec-nonexistent  # ❌ Não existe - PROBLEMA!
```

## 📊 Métricas de Integridade

### Indicadores de Qualidade

- **Cobertura de Frontmatter**: XX% dos arquivos possuem frontmatter completo
- **Sincronização de Manifesto**: XX% dos arquivos estão indexados
- **Consistência de Localização**: XX% dos arquivos estão na pasta correta
- **Validade de Referências**: XX% das referências apontam para arquivos existentes

### Metas de Qualidade

- 🎯 **100%** de arquivos com frontmatter completo
- 🎯 **100%** de arquivos indexados nos manifestos
- 🎯 **100%** de consistência entre category e localização
- 🎯 **100%** de referências válidas

---

**Validação executada automaticamente por todos os agentes SDE**