## Role Assignments

### Job Read for App Team
```bash
awx role_team_assignments create --object_ansible_id "100.1 Download Agents" --team_ansible_id "App Team" --role_definition 35
awx role_team_assignments create --object_ansible_id "100.0 List Agents from PPDM" --team_ansible_id "App Team" --role_definition 35
awx role_team_assignments create --object_ansible_id "100.2 Set DNS for Agents v16" --team_ansible_id "App Team" --role_definition 35
awx role_team_assignments create --object_ansible_id "100.2 Set DNS for Agents" --team_ansible_id "App Team" --role_definition 35
awx role_team_assignments create --object_ansible_id "100.3 Clear_hosts_file_windows_agent" --team_ansible_id "App Team" --role_definition 35
awx role_team_assignments create --object_ansible_id "100.3 Copy and Deploy Agents from S3" --team_ansible_id "App Team" --role_definition 35
awx role_team_assignments create --object_ansible_id "100.9 Uninstall-windows-agent" --team_ansible_id "App Team" --role_definition 35
awx role_team_assignments create --object_ansible_id "100.4 Create Whitelist Entry from Address Query" --team_ansible_id "App Team" --role_definition 35
```

### Job Execute for App Team
```bash
awx role_team_assignments create --object_ansible_id "100.1 Download Agents" --team_ansible_id "App Team" --role_definition 18
awx role_team_assignments create --object_ansible_id "100.0 List Agents from PPDM" --team_ansible_id "App Team" --role_definition 18
awx role_team_assignments create --object_ansible_id "100.2 Set DNS for Agents v16" --team_ansible_id "App Team" --role_definition 18
awx role_team_assignments create --object_ansible_id "100.2 Set DNS for Agents" --team_ansible_id "App Team" --role_definition 18
awx role_team_assignments create --object_ansible_id "100.3 Clear_hosts_file_windows_agent" --team_ansible_id "App Team" --role_definition 18
awx role_team_assignments create --object_ansible_id "100.3 Copy and Deploy Agents from S3" --team_ansible_id "App Team" --role_definition 18
awx role_team_assignments create --object_ansible_id "100.9 Uninstall-windows-agent" --team_ansible_id "App Team" --role_definition 18
awx role_team_assignments create --object_ansible_id "100.4 Create Whitelist Entry from Address Query" --team_ansible_id "App Team" --role_definition 18
```

### Credentials use and Read

```bash
awx role_team_assignments create --object_ansible_id "ppdm-1" --team_ansible_id "App Team" --role_definition 26
awx role_team_assignments create --object_ansible_id "ppdm-2" --team_ansible_id "App Team" --role_definition 26
awx role_team_assignments create --object_ansible_id "ppdm-1" --team_ansible_id "App Team" --role_definition 36
awx role_team_assignments create --object_ansible_id "ppdm-2" --team_ansible_id "App Team" --role_definition 36
```

### Project Roles

```bash
awx role_team_assignments create --object_ansible_id "PPDM Inventory" --team_ansible_id "App Team" --role_definition 9
awx role_team_assignments create --object_ansible_id "PPDM Inventory" --team_ansible_id "App Team" --role_definition 37
awx role_team_assignments create --object_ansible_id "Bob Inventory" --team_ansible_id "App Team" --role_definition 22
awx role_team_assignments create --object_ansible_id "Bob Inventory" --team_ansible_id "App Team" --role_definition 38
awx role_team_assignments create --object_ansible_id "ansible-ppdm" --team_ansible_id "App Team" --role_definition 22
```

### Kubernetes Team

```
awx role_team_assignments create --object_ansible_id "130.0 AdHoc Protect K8S Asset" --team_ansible_id "kubernetes team" --role_definition 40
awx role_team_assignments create --object_ansible_id "130.0 AdHoc Protect K8S Asset" --team_ansible_id "kubernetes team" --role_definition 15
awx role_team_assignments create --object_ansible_id "130.0 AdHoc Protect K8S Asset" --team_ansible_id "kubernetes team" --role_definition 14
awx role_team_assignments create --object_ansible_id "30.0 Query K8S Assets" --team_ansible_id "kubernetes team" --role_definition 40
awx role_team_assignments create --object_ansible_id "30.0 Query K8S Assets" --team_ansible_id "kubernetes team" --role_definition 15
awx role_team_assignments create --object_ansible_id "30.0 Query K8S Assets" --team_ansible_id "kubernetes team" --role_definition 14
awx role_team_assignments create --object_ansible_id "30.0 Query Assts" --team_ansible_id "kubernetes team" --role_definition 35
awx role_team_assignments create --object_ansible_id "130.0 AdHoc Asset Protection" --team_ansible_id "kubernetes team" --role_definition 35
```



