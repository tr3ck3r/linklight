# Exercise 7 - Tower API Job Launch

We can call into Ansible Tower via the API to run a job template for us.

We'll use the linux-accounts.yml example we did earlier to demonstate this.

## Adding The Job Template:

### Step 1:

Select TEMPLATES

### Step 2:

Click on ADD ![Add button](at_add.png), and select JOB TEMPLATE

### Step 3:

Complete the form using the following values

NAME |Linux Account Admin Template
-----|-------------------------
DESCRIPTION|Template for the Linux user account admin tasks
JOB TYPE|Run
INVENTORY|Ansible Workshop Inventory
PROJECT|Supplementary Project
PLAYBOOK|tower/linux-accounts.yml
MACHINE CREDENTIAL|Ansible Workshop Credential
LIMIT|web
OPTIONS|- [x] Enable Privilege Escalation

![Job Template Form](at_jt_detail.png)

## Job Launch Settings:

## Launching The Job:

We'll use the *curl* command to launch the job. It's a bit of a handful but let's break it down, so it's easier to understand:

-- user = who we authenticate as. In our case the admin account
-k = insecure HTTPS. So we don't check for valid certs
-s = silent mode. Cuts out some of the not so -useful curl output we don't want
-H = HTTP JSON MIME type headers. We need to POST in the extra_vars and job_tags so the job will run successfully

NB. You will need to check and change where necessary the PUBLIC_IP for your Tower instance and the Job Template number (mine here is 8)

Lastly, we use a little bit of python magic to prettify the output, making it more readable.

```bash
$ curl --user 'admin':'ansible' -k -s -H 'Content-Type: application/json' -XPOST -d '{"extra_vars":"{\"account\":\"fred\"}","job_tags":"disable"}' https://52.59.208.221/api/v2/job_templates/8/launch/ | python -m json.tool
```

You should see output similar to this:

{
    "allow_simultaneous": false,
    "artifacts": {},
    "ask_credential_on_launch": false,
    "ask_diff_mode_on_launch": false,
    "ask_inventory_on_launch": false,
    "ask_job_type_on_launch": false,
    "ask_limit_on_launch": false,
    "ask_skip_tags_on_launch": false,
    "ask_tags_on_launch": true,
    "ask_variables_on_launch": true,
    "ask_verbosity_on_launch": false,
    "controller_node": "",
    "created": "2019-02-25T19:24:29.041943Z",
    "credential": 2,
    "description": "",
    "diff_mode": false,
    "elapsed": 0.0,
    "event_processing_finished": false,
    "execution_node": "",
    "extra_vars": "{\"account\": \"fred\"}",
    "failed": false,
    "finished": null,
    "force_handlers": false,
    "forks": 1,
    "id": 6,
    "ignored_fields": {},
    "instance_group": null,
    "inventory": 2,
    "job": 6,
    "job_args": "",
    "job_cwd": "",
    "job_env": {},
    "job_explanation": "",
    "job_slice_count": 1,
    "job_slice_number": 0,
    "job_tags": "disable",
    "job_template": 8,
    "job_type": "run",
    "launch_type": "manual",
    "limit": "web",
    "modified": "2019-02-25T19:24:29.103024Z",
    "name": "Linux Account Admin Template",
    "passwords_needed_to_start": [],
    "playbook": "tower/linux-accounts.yml",
    "project": 6,
    "related": {
        "activity_stream": "/api/v2/jobs/6/activity_stream/",
        "cancel": "/api/v2/jobs/6/cancel/",
        "create_schedule": "/api/v2/jobs/6/create_schedule/",
        "created_by": "/api/v2/users/1/",
        "credential": "/api/v2/credentials/2/",
        "credentials": "/api/v2/jobs/6/credentials/",
        "extra_credentials": "/api/v2/jobs/6/extra_credentials/",
        "inventory": "/api/v2/inventories/2/",
        "job_events": "/api/v2/jobs/6/job_events/",
        "job_host_summaries": "/api/v2/jobs/6/job_host_summaries/",
        "job_template": "/api/v2/job_templates/8/",
        "labels": "/api/v2/jobs/6/labels/",
        "modified_by": "/api/v2/users/1/",
        "notifications": "/api/v2/jobs/6/notifications/",
        "project": "/api/v2/projects/6/",
        "relaunch": "/api/v2/jobs/6/relaunch/",
        "stdout": "/api/v2/jobs/6/stdout/",
        "unified_job_template": "/api/v2/job_templates/8/"
    },
    "result_traceback": "",
    "scm_revision": "",
    "skip_tags": "",
    "start_at_task": "",
    "started": null,
    "status": "pending",
    "summary_fields": {
        "created_by": {
            "first_name": "",
            "id": 1,
            "last_name": "",
            "username": "admin"
        },
        "credential": {
            "cloud": false,
            "credential_type_id": 1,
            "description": "",
            "id": 2,
            "kind": "ssh",
            "name": "Ansible Workshop Credential"
        },
        "credentials": [
            {
                "cloud": false,
                "credential_type_id": 1,
                "description": "",
                "id": 2,
                "kind": "ssh",
                "name": "Ansible Workshop Credential"
            }
        ],
        "extra_credentials": [],
        "inventory": {
            "description": "",
            "groups_with_active_failures": 0,
            "has_active_failures": false,
            "has_inventory_sources": false,
            "hosts_with_active_failures": 0,
            "id": 2,
            "inventory_sources_with_failures": 0,
            "kind": "",
            "name": "Ansible Workshop Inventory",
            "organization_id": 1,
            "total_groups": 2,
            "total_hosts": 4,
            "total_inventory_sources": 0
        },
        "job_template": {
            "description": "",
            "id": 8,
            "name": "Linux Account Admin Template"
        },
        "labels": {
            "count": 0,
            "results": []
        },
        "modified_by": {
            "first_name": "",
            "id": 1,
            "last_name": "",
            "username": "admin"
        },
        "project": {
            "description": "",
            "id": 6,
            "name": "Supplementary Workshop",
            "scm_type": "git",
            "status": "successful"
        },
        "unified_job_template": {
            "description": "",
            "id": 8,
            "name": "Linux Account Admin Template",
            "unified_job_type": "job"
        },
        "user_capabilities": {
            "delete": true,
            "start": true
        }
    },
    "timeout": 0,
    "type": "job",
    "unified_job_template": 8,
    "url": "/api/v2/jobs/6/",
    "use_fact_cache": false,
    "vault_credential": null,
    "verbosity": 0
}

## Checking The Job

From the above output, I can see that "job": 6 so that's what I should look for in Tower under Jobs.

## End Result
We've explored the Tower API callback facility in order to run a job template.


---

[Click Here to return to the Ansible Lightbulb - Ansible Tower Workshop](../README.md)
