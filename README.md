# Azure Synapse CI/CD
In this project, I have created CI/CD pipelines for Azure Synapse resources, following the flow through ARM deployment.

It includes the execution of DDL SQL script commands in the production database, using REST and PowerShell. The ideia is to take the commands of every PR.

Points to consider: the logic in the 'take_queries.ps1' file could be refactored by using functions to avoid duplication of commands.