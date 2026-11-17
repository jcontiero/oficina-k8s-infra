# Recuperação de Falha Parcial e Transferência do State de Bootstrap (P7)

Este procedimento garante que o bootstrap em `fiap-project-514922` opere exclusivamente sobre recursos novos ou já importados, **preservando integralmente quaisquer states históricos existentes**.

## 1. Execução em Diretório Isolado

Execute sempre a partir de uma cópia limpa contendo apenas os arquivos versionados (`main.tf`, `variables.tf`, `outputs.tf`, `terraform.tfvars`) sem reutilizar `.terraform/` ou `terraform.tfstate*` locais antigos.

## 2. Recuperação em Caso de Falha Parcial no Apply

Se um `terraform apply` autorizado falhar no meio após criar parte dos recursos (ex.: APIs habilitadas ou bucket/WIF/SA já criados):

1. **Não** execute `terraform destroy` e **não** reutilize `terraform.tfstate` antigo.
2. Inspecione o state local temporário gerado pela tentativa atual (`terraform state list`).
3. Para qualquer recurso já existente no GCP que retorne erro `409 AlreadyExists`:
   - Importe o recurso no state temporário com `terraform import <endereco> <id_gcp>`.
   - Exemplos:
     - `terraform import google_storage_bucket.tf_state fiap-project-514922-tfstate`
     - `terraform import google_service_account.platform_sa projects/fiap-project-514922/serviceAccounts/github-actions-sa@fiap-project-514922.iam.gserviceaccount.com`
4. Reexecute `terraform plan -no-color -out=bootstrap.tfplan`, confirme que não há destruições/substituições e reaplique apenas o delta restante.

## 3. Transferência Controlada Apenas do State Novo (Etapa B)

Somente após a Etapa A concluir com sucesso e o bucket `gs://fiap-project-514922-tfstate` existir:

1. Copie `backend.tf.example` para `backend.tf` no diretório isolado do bootstrap (`prefix = "bootstrap"`).
2. Execute `terraform init -migrate-state` confirmando a cópia **exclusiva** do state novo do bootstrap para `gs://fiap-project-514922-tfstate/bootstrap/default.tfstate`.
3. Valide com:
   - `terraform state list`
   - `terraform plan -no-color` (resultado esperado: `No changes.`)
4. Remova/arquive o state local temporário somente após confirmar `No changes` no backend remoto.
