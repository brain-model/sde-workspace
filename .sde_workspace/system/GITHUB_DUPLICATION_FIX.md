# Correção: Duplicação do Diretório .github

## Problema Identificado

Durante a instalação do SDE v0.1.0 'copilot-ptbr', o diretório `.github` é copiado corretamente para a raiz do projeto, mas permanece duplicado dentro de `.sde_workspace/.github/`.

## Comportamento Atual (Incorreto)
```
projeto/
├── .github/                    # ✅ Copiado corretamente
│   ├── copilot-instructions.md
│   └── chatmodes/
└── .sde_workspace/
    └── .github/               # ❌ Não deveria estar aqui após instalação
        ├── copilot-instructions.md
        └── chatmodes/
```

## Comportamento Esperado (Correto)
```
projeto/
├── .github/                    # ✅ Único local após instalação
│   ├── copilot-instructions.md
│   └── chatmodes/
└── .sde_workspace/
    ├── system/
    ├── knowledge/
    └── (sem .github)          # ✅ Removido após cópia
```

## Solução Temporária

Até que o script de instalação seja corrigido na branch master, usuários devem executar manualmente:

```bash
# Após a instalação, remover a duplicação
rm -rf .sde_workspace/.github
```

## Solução Definitiva (Para branch master)

No script de instalação, após copiar `.sde_workspace/.github/` para `.github/`, adicionar:

```bash
# Remover duplicação após cópia bem-sucedida
if [ -d ".github" ] && [ -d ".sde_workspace/.github" ]; then
    echo "Removendo duplicação do diretório .github..."
    rm -rf .sde_workspace/.github
fi
```

## Status

- **Identificado**: ✅ 29/09/2025
- **Solução Documentada**: ✅ 29/09/2025  
- **Correção no Script**: ❌ Pendente (branch master)
- **Workaround Disponível**: ✅ Comando manual

## Impacto

- **Funcional**: Baixo - ambos os arquivos funcionam
- **Confusão**: Médio - usuários podem editar o arquivo errado
- **Manutenção**: Alto - mudanças podem precisar ser feitas em dois lugares