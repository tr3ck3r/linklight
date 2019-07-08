# Exercise 5 - Tower Workflows

We are going to use workflows in this exercise to tie all of our playbooks together into a single automation job. Workflows allow you to configure a sequence of disparate job templates (or workflow templates) that may or may not share inventory, playbooks, or permissions. 

### Step 1: Create a Workflow Template

Let's join our seperate playbooks into a single automation workflow. Navigate to `Templates` and click the `+` button to add a new `workflow template`.

| FIELD | VALUE |
| :--- | :--- |
| NAME | AWS Web Server Workflow |
| DESCRIPTION | Workflow to deploy loadbalancer and web servers onto ec2 instances in AWS |
| ORGANIZATION | Default |
| INVENTORY | Ansible AWS Workshop Inventory |

Save the workflow template. Once saved, click on the `workflow visualizer`. Click on the `start` box to start building the workflow. 

### Step 2: Adding Workflow Items

Click on the START button and then in the dashed box.

Choose Create Security Group and SELECT.

Hover over the "Create Security Group" box, click on the GREEN PLUS button and choose Create Web Servers and SELECT.

Hover over the "Create Web Servers" box, click on the GREEN PLUS button and choose Create Load Balancer and SELECT.

Click on SAVE.

### Step3: Launch Workflow

Now let's try launching our workflow. Press the rocketship `launch` icon to run the workflow template.

It'll pop you into the job output screen so you can watch progress through the stages.

---

[Click Here to return to the Ansible Lightbulb - Ansible Tower Workshop](../../README.md)
