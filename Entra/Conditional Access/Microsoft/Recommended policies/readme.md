# Microsoft Recommended Conditional Access
https://learn.microsoft.com/en-us/entra/identity/conditional-access/policy-risk-based-user

## missing
- Require multifactor authentication for elevated sign-in risk
- Require a secure password change for elevated user risk

## special config

### Protect AI with Conditional Access policy

```powershell
# Connect with the appropriate scopes to create service principals
Connect-MgGraph -Scopes "Application.ReadWrite.All"

# Create service principal for the service Enterprise Copilot Platform (Microsoft 365 Copilot)
New-MgServicePrincipal -AppId fb8d773d-7ef8-4ec0-a117-179f88add510

# Create service principal for the service Security Copilot (Microsoft Security Copilot) 
New-MgServicePrincipal -AppId bb5ffd56-39eb-458c-a53a-775ba21277da
```
