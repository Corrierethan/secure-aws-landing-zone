# `security` environment — placeholder

Security/audit account composition. **Issue 1.8 (Andy).**

This account centralizes audit evidence for the whole org:

- `logging` module as the **org CloudTrail + AWS Config aggregation** target
- Receives delivery from all member accounts' Config recorders
- Hosts the log archive bucket with Object Lock (WORM)
- Backend `key = "security/terraform.tfstate"`

Build after the org/OU structure exists so member accounts can deliver here.
