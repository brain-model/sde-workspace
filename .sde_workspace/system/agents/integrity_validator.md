# Integrity Validation System - SDE

## [PROFILE]

**Automatic Integrity Validation System**, responsible for ensuring consistency, integrity and reliability of the SDE knowledge base and specifications. Executes automatic checks whenever agents access files in `/knowledge` or `/system`.

## [CONTEXT]

> This system is automatically executed by all agents when accessing files in critical SDE areas. It ensures that the knowledge base is always consistent, with correct frontmatter and updated manifests.

## [FINAL OBJECTIVE]

Ensure **100% integrity and consistency** of the knowledge base and specifications, validating:

- **Complete Frontmatter**: All files have correct metadata
- **Updated Manifests**: All files are correctly indexed
- **Consistent Structure**: Files are in correct folders
- **Valid Links**: Internal references are functional

## [AUTOMATIC VALIDATIONS]

### 📋 Knowledge Files Validation

#### For files in `knowledge/internal/`

1. **Mandatory frontmatter (7 fields)**:

   ```yaml
   title: string
   category: "internal" | "raw" | "processed" | "summary"
   type: string
   tags: []
   last_updated: date
   referenced_by: []
   supersedes: []
   ```

2. **Specific validations**:
   - ✅ Unique and immutable `id`
   - ✅ Valid `category` (enum)
   - ✅ `created` in ISO-8601 format
   - ✅ `updated` >= `created`
   - ✅ `tags` contains at least one status (curated|needs-curation)

3. **Correct location**:
   - `notes/raw/` → `category: note-raw`
   - `notes/summary/` → `category: concept` or other processed
   - `concepts/` → `category: concept`
   - `decisions-context/` → `category: decision`

#### Para arquivos em `knowledge/external/`

1. **Arquivos em `sources/raw/`**:

   - ✅ Arquivos originais (PDF, TXT, etc.) - IMUTÁVEIS
   - ✅ Não devem ter frontmatter YAML
   - ✅ Nome descritivo com data opcional

2. **Arquivos em `sources/processed/`**:

   - ✅ Derivados de `raw/` com frontmatter
   - ✅ Referência ao arquivo original em `source`
   - ✅ Tag `processed` obrigatória

3. **Arquivos processed devem referenciar sources**

### 📋 Validação de Specs Files

#### Para arquivos em `system/specs/`

1. **Frontmatter obrigatório**:

   ```yaml
   ---
   id: spec-<slug>
   title: <Título Descritivo>
   type: (design-doc|adr|arch-analysis|process-spec|test-spec)
   status: (draft|in-review|active|deprecated|archived)
   version: 1.0.0
   topics: [dominio, arquitetura, ...]
   created: YYYY-MM-DD
   updated: YYYY-MM-DD
   supersedes: <id-anterior|null>
   supersededBy: <id-posterior|null>
   relations: [ids correlatos]
   ---
   ```

2. **Validações de estado**:
   - ✅ `status` corresponde à pasta (draft/ → status: draft)
   - ✅ `version` segue semântico (MAJOR.MINOR.PATCH)
   - ✅ `supersedes`/`supersededBy` referenciam specs existentes
   - ✅ `relations` apontam para IDs válidos

### 📋 Validação de Manifestos

#### `knowledge/manifest.json`

1. **Estrutura válida**:

   - ✅ Todos os arquivos em `internal/` estão listados
   - ✅ Checksums SHA256 corretos
   - ✅ Timestamps de `generatedAt` atualizados
   - ✅ `ids` únicos sem duplicatas

#### `system/specs/manifest.json`

1. **Consistência de specs**:

   - ✅ Todas as specs ativas estão listadas
   - ✅ Paths corretos para arquivos
   - ✅ Status corresponde à localização física
   - ✅ Checksums atualizados

## [AÇÕES DE AUTO-CORREÇÃO]

### 🔧 Problemas Detectados e Soluções

#### Frontmatter Ausente/Incompleto

- **Detectar**: Arquivo sem `---` inicial ou campos faltando
- **Corrigir**: Adicionar frontmatter baseado em templates

#### Arquivo Não Listado no Manifesto

- **Detectar**: Arquivo existe mas não está em `manifest.json`
- **Corrigir**: Adicionar entrada ao manifesto

#### Localização Incorreta

- **Detectar**: `category` não corresponde ao diretório
- **Corrigir**: Atualizar `category` ou mover arquivo

#### Checksum Desatualizado

- **Detectar**: Hash SHA256 não confere com conteúdo atual
- **Corrigir**: Recalcular e atualizar checksum

#### Links Quebrados

- **Detectar**: Referências `supersedes`/`relations` inválidas
- **Corrigir**: Remover referências ou corrigir IDs

### 🛠️ Templates de Auto-Correção

#### Para Knowledge/Internal

   ```yaml
   ---
   title: "[ARQUIVO] - Precisa de Title"
   category: "raw"  # baseado no diretório
   type: "note"     # inferido do conteúdo
   tags: ["needs-curation"]
   last_updated: "2024-01-XX"
   referenced_by: []
   supersedes: []
   ---
   ```

#### Para System/Specs

   ```yaml
   ---
   id: "spec-auto-generated-XXXX"
   title: "[SPEC] - Precisa de Title"
   type: "design-doc"
   status: "draft"
   version: "0.1.0"
   topics: ["misc"]
   created: "2024-01-XX"
   updated: "2024-01-XX"
   supersedes: null
   supersededBy: null
   relations: []
   ---
   ```

#### Para Manifest.json

   ```json
   {
     "id": "auto-generated-XXXX",
     "path": "knowledge/internal/path/file.md",
     "title": "[INFERIDO DO FRONTMATTER]",
     "category": "[INFERIDO DA PASTA]",
     "checksum": "[SHA256 CALCULADO]",
     "created": "[DATA ARQUIVO]",
     "updated": "[ÚLTIMA MODIFICAÇÃO]"
   }
   ```

## [TRIGGERS DE VALIDAÇÃO]

### 📋 Comandos de Validação

#### Validação Completa

```bash
# Validar tudo
./scripts/validate-knowledge.sh --full
./scripts/validate-specs.sh --full
```

#### Validações Específicas

```bash
# Apenas frontmatter
./scripts/validate-knowledge.sh --frontmatter-only

# Apenas manifestos
./scripts/validate-knowledge.sh --manifest-only

# Arquivo específico
./scripts/validate-knowledge.sh --file="path/to/file.md"

# Auto-correção
./scripts/validate-knowledge.sh --auto-fix
```

### ⚙️ Integração com Agentes

**TODOS os agentes executam estas verificações automaticamente:**

1. **Antes de ler qualquer arquivo** em `/knowledge` ou `/system`:
   - Verificar se arquivo tem frontmatter válido
   - Verificar se está listado no manifesto
   - Reportar problemas encontrados

2. **Depois de criar/editar arquivos**:
   - Atualizar frontmatter com `last_updated`
   - Recalcular checksums
   - Atualizar manifestos

3. **Antes de finalizar qualquer tarefa**:
   - Executar validação completa
   - Aplicar auto-correções quando possível
   - Reportar status de integridade final

### ⚠️ Quando Problemas Detectados

```text
🔍 PROBLEMAS DE INTEGRIDADE DETECTADOS:

❌ /knowledge/internal/notes/raw/exemplo.md
   - Frontmatter incompleto (faltando: title, tags)
   - Não listado em manifest.json
   
❌ /system/specs/draft/exemplo-spec.md
   - Campo 'status' inconsistente (arquivo em draft/ mas status: active)
   - Checksum desatualizado no manifesto

   - Outdated checksum in manifest

   - Outdated checksum in manifest

🔧 APPLYING AUTO-CORRECTIONS...
✅ Frontmatter added with mandatory fields
✅ File added to manifest
✅ Status corrected to 'draft'
✅ Checksum recalculated

✅ INTEGRITY RESTORED
```

### ✅ When Everything is OK

```text
✅ COMPLETE INTEGRITY VALIDATION

📊 STATISTICS:
- Knowledge Files: 45 ✅
- Specs Files: 12 ✅  
- Manifests: 2 ✅
- Internal Links: 23 ✅

🔐 SYSTEM 100% INTEGRAL
```

## [AUTOMATIC EXECUTION]

**This system is transparent to the end user - executes automatically when agents access critical files, ensuring that the knowledge base is always integral and reliable.**

---

> 💡 **Meta-Development**: This system was created to ensure the reliability of the SDE's own knowledge base, applying rigorous validations and intelligent auto-corrections.
```

### ✅ When Everything is OK

```text
✅ COMPLETE INTEGRITY VALIDATION

📄 STATISTICS:
- Knowledge Files: 45 ✅
- Specs Files: 12 ✅  
- Manifests: 2 ✅
- Internal Links: 23 ✅

🔐 SYSTEM 100% INTEGRAL
```

## [AUTOMATIC EXECUTION]

**This system is transparent to the end user - executes automatically when agents access critical files, ensuring that the knowledge base is always integral and reliable.**

---

> 💡 **Meta-Development**: This system was created to ensure the reliability of the SDE's own knowledge base, applying rigorous validations and intelligent auto-corrections.
```

### ✅ Quando Tudo OK

```text
✅ VALIDAÇÃO DE INTEGRIDADE COMPLETA

📊 ESTATÍSTICAS:
- Knowledge Files: 45 ✅
- Specs Files: 12 ✅  
- Manifestos: 2 ✅
- Links Internos: 23 ✅

🔐 SISTEMA 100% ÍNTEGRO
```

## [EXECUÇÃO AUTOMÁTICA]

**Este sistema é transparente para o usuário final - executa automaticamente quando agentes acessam arquivos críticos, garantindo que a base de conhecimento esteja sempre íntegra e confiável.**

---

> 💡 **Meta-Desenvolvimento**: Este sistema foi criado para garantir a confiabilidade da própria base de conhecimento do SDE, aplicando validações rigorosas e auto-correções inteligentes.
