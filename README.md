# Azure Synapse CI/CD
In this project, I have created CI/CD pipelines for Azure Synapse resources, following the flow through ARM deployment.

It includes the execution of DDL SQL script commands in a production database, using REST and PowerShell. The idea is to capture the commands from each PR while also ensuring the correct execution order of objects in the script.

Points to consider: the logic in the 'take_queries.ps1' file could be refactored by using functions to avoid duplication of commands.

UPDATE: The script was refactored, the redundancy was taken off with a function, the match of prefixes was fixed, and better handle of exceptions was improved with addition of try/catch.

OBS: The action "validateDeploy" in yaml of Azure DevOps needs to be choosed, because if only want to "deploy", the ARM templates will be generated before release, and cannot take the sqlscripts changes.
The action "validateDeploy" generate the templates during deploy by the agent, but not droped as pipelines artifacts. In this way, it could see changes in sqlscript folder in every commit, and take the commands to execute.
This could't be possible with the general ARM template artifact of publish branch.
