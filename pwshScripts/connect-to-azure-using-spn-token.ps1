cls
$azureAplicationId ="1791f063-d51f-4539-8061-4434753d98ac"
$azureTenantId= "05d75c05-fa1a-42e7-9cf1-eb416c396f2d"
$azurePassword = "CdP8Q~zM2zKXF~1Ut8qMg2t3Hd42zS6QMkPqTao_"
$resourceUrl = "https://admiral.hosting.maersk.com"

az login --service-principal -u $azureAplicationId -p $azurePassword --tenant $azureTenantId --output table

$aadToken = (az account get-access-token --resource 'https://management.core.windows.net/' | ConvertFrom-Json).accessToken
$aadToken

Connect-AzAccount -AccessToken $aadToken -AccountId $azureAplicationId
