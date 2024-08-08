## Role Assignments

### Job Read for App Team
```bash
awx role_team_assignments create --object_ansible_text "100.1 Download Agents" --team_ansible_id "App Team" --role-definition 35
awx role_team_assignments create --object_ansible_text "100.0 List Agents from PPDM" --team_ansible_id "App Team" --role-definition 35
awx role_team_assignments create --object_ansible_text "100.2 Set DNS for Agents v16" --team_ansible_id "App Team" --role-definition 35
awx role_team_assignments create --object_ansible_text "100.2 Set DNS for Agents" --team_ansible_id "App Team" --role-definition 35
awx role_team_assignments create --object_ansible_text "100.3 Clear_hosts_file_windows_agent" --team_ansible_id "App Team" --role-definition 35
awx role_team_assignments create --object_ansible_text "100.3 Copy and Deploy Agents from S3" --team_ansible_id "App Team" --role-definition 35
awx role_team_assignments create --object_ansible_text "100.9 Uninstall-windows-agent" --team_ansible_id "App Team" --role-definition 35
awx role_team_assignments create --object_ansible_text "100.4 Create Whitelist Entry from Address Query" --team_ansible_id "App Team" --role-definition 35
```

### Job Execute for App Team
```bash
awx role_team_assignments create --object_ansible_text "100.1 Download Agents" --team_ansible_id "App Team" --role-definition 18
awx role_team_assignments create --object_ansible_text "100.0 List Agents from PPDM" --team_ansible_id "App Team" --role-definition 18
awx role_team_assignments create --object_ansible_text "100.2 Set DNS for Agents v16" --team_ansible_id "App Team" --role-definition 18
awx role_team_assignments create --object_ansible_text "100.2 Set DNS for Agents" --team_ansible_id "App Team" --role-definition 18
awx role_team_assignments create --object_ansible_text "100.3 Clear_hosts_file_windows_agent" --team_ansible_id "App Team" --role-definition 18
awx role_team_assignments create --object_ansible_text "100.3 Copy and Deploy Agents from S3" --team_ansible_id "App Team" --role-definition 18
awx role_team_assignments create --object_ansible_text "100.9 Uninstall-windows-agent" --team_ansible_id "App Team" --role-definition 18
awx role_team_assignments create --object_ansible_text "100.4 Create Whitelist Entry from Address Query" --team_ansible_id "App Team" --role-definition 18
```

### Credentials use and Read

```bash
awx role_team_assignments create --object_ansible_text "ppdm-1" --team_ansible_id "App Team" --role-definition 26
awx role_team_assignments create --object_ansible_text "ppdm-2" --team_ansible_id "App Team" --role-definition 26
awx role_team_assignments create --object_ansible_text "ppdm-1" --team_ansible_id "App Team" --role-definition 36
awx role_team_assignments create --object_ansible_text "ppdm-2" --team_ansible_id "App Team" --role-definition 36
```

### Project Roles

```bash
awx role_team_assignments create --object_ansible_text "PPDM Inventory" --team_ansible_id "App Team" --role-definition 9
awx role_team_assignments create --object_ansible_text "PPDM Inventory" --team_ansible_id "App Team" --role-definition 37
awx role_team_assignments create --object_ansible_text "Bob Inventory" --team_ansible_id "App Team" --role-definition 22
awx role_team_assignments create --object_ansible_text "Bob Inventory" --team_ansible_id "App Team" --role-definition 38
awx role_team_assignments create --object_ansible_text "ansible-ppdm" --team_ansible_id "App Team" --role-definition 22
```

### Kubernetes Team

```
awx role_team_assignments create --object_ansible_text "130.0 AdHoc Protect K8S Asset" --team_ansible_id "kubernetes team" --role-definition 40
awx role_team_assignments create --object_ansible_text "130.0 AdHoc Protect K8S Asset" --team_ansible_id "kubernetes team" --role-definition 15
awx role_team_assignments create --object_ansible_text "130.0 AdHoc Protect K8S Asset" --team_ansible_id "kubernetes team" --role-definition 14
awx role_team_assignments create --object_ansible_text "30.0 Query K8S Assets" --team_ansible_id "kubernetes team" --role-definition 40
awx role_team_assignments create --object_ansible_text "30.0 Query K8S Assets" --team_ansible_id "kubernetes team" --role-definition 15
awx role_team_assignments create --object_ansible_text "30.0 Query K8S Assets" --team_ansible_id "kubernetes team" --role-definition 14
awx role_team_assignments create --object_ansible_text "30.0 Query Assts" --team_ansible_id "kubernetes team" --role-definition 35
awx role_team_assignments create --object_ansible_text "130.0 AdHoc Asset Protection" --team_ansible_id "kubernetes team" --role-definition 35
```



