// ------------------------------------------------------------
// Parameters
// ------------------------------------------------------------

@description('The principal ID.')
param principalId string

@allowed([
  'User'
  'Group'
  'ServicePrincipal'
])
@description('The principal type.')
param principalType string = 'ServicePrincipal'

@description('Specifies the name of the key vault.')
param keyVaultName string

@description('Specifies the name of the app configuration.')
param appConfigurationName string

// ------------------------------------------------------------
// Resources - Key Vault Role Assignments
// ------------------------------------------------------------

// get existing key vault
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

// key vault secrets officer role definition
var keyVaultSecretsOfficerId='b86a8fe4-44ce-4948-aee5-eccb2c155cd7' // #gitleaks:allow
@description('The built-in role for Key Vault Secrets Officer.')
resource keyVaultSecretsOfficerRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: subscription()
  name: keyVaultSecretsOfficerId
}

// assign key vault secrets officer role to principalId
resource keyVaultSecretsOfficerRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: keyVault
  name: guid(keyVault.id, principalId, keyVaultSecretsOfficerRoleDefinition.id)
  properties: {
    roleDefinitionId: keyVaultSecretsOfficerRoleDefinition.id
    principalId: principalId
    principalType: principalType
  }
}

// ------------------------------------------------------------
// Resources - App Configuration Role Assignments
// ------------------------------------------------------------

// get existing app configuration
resource appConfiguration 'Microsoft.AppConfiguration/configurationStores@2024-05-01' existing = {
  name: appConfigurationName
}

// app configuration contributor role definition
var appConfigurationContributorId='fe86443c-f201-4fc4-9d2a-ac61149fbda0' // #gitleaks:allow
@description('The built-in role for App Configuration Contributor.')
resource appConfigurationContributorRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: subscription()
  name: appConfigurationContributorId
}

// assign app configuration contributor role to principalId
resource appConfigurationContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: appConfiguration
  name: guid(appConfiguration.id, principalId, appConfigurationContributorRoleDefinition.id)
  properties: {
    roleDefinitionId: appConfigurationContributorRoleDefinition.id
    principalId: principalId
    principalType: principalType
  }
}
