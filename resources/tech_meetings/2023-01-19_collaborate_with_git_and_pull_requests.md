### Collaboration
- Collaboration is an important part of a development team
- Processes exist for ensuring consistent and efficient updates to the codebase
- A common method is the "branch and merge" which allows multiple team members to collectively develop code
- By following a strict set of criteria, we can update our codebase in a way to ensure existing functions work and new functions are added to improve our codebase

### Making Edits to the Codebase
- You should set up your branch with the following (after downloading the repository with  ```git clone```)
```
git fetch --all
git pull --all
git checkout dev
git pull origin
```

- To make your own code changes, branch from the ```dev``` branch
```
git checkout dev
git branch new_branch
git checkout new_branch
```

- Now you have your own version of code that you can edit without affecting the main code in ```dev```
- You can always switch back to ```dev``` when you need the full working version of the code
```
git checkout dev
```

- To switch back to your own development
```
git checkout new_branch
```

- Once you have made your updates to the code, you can ```add```, ```commit```, ```push```
```
git add name_of_files_changes.m
git commit -m "my commit message here"
git push
```

- You may be prompted with a message on ```push``` if your branch is not on the remote repository on github
- The terminal will give you a new command which you can directly copy, paste, and run in your terminal
- This one-time command will be the following below, which you only need to do once during the first ever  ```push``` of your branch
```
git push --set-upstream origin new_branch
```

- Your branch will now be visible on github at the main page of the codebase on the left top hand side in a drop-down menu which shows all the branches

### Branch Structure and Permissions
- After making a new branch, adding changes, and pushing to github, we can combine these change with the main version of our codebase in the ```dev``` branch
- Note that the ```prod``` branch is the main branch and official release version, which will only be updated when ```dev``` is merged into ```prod```
- This is only done by development leads or managers who can ensure the official release is fulling working before updating for the users
- The ```dev``` branch can only be updated through pull requests to merge other branches into it
- The pull requests must be submitted by the person trying to merge their own branch, and be approved by at least one other reviewer (usually a senior or development lead)
- Some users may have special permissions to override the need for pull requests into branches such as ```dev``` and can push directly to it
- In our codebase, one person has permission to push to ```dev``` directly while everyone else must submit code changes through a pull request
- The ```prod``` branch must be updated through pull requests exclusively and must have at least one reviewer
- These permissions can be set up in the "Settings" tab at the top, "Branches" tab on the left hand side, and "Branch protection rules"

### Creating Pull Requests to Submit Your Code Changes
- To create a pull request, switch to the 3rd tab on the top named "Pull requests"
- Click the green buttom "New pull request"
- Then you can select the "base" branch and "compare" branch at the top at the top of the page
- The "base" branch is the one you are merging into, in this case, ```dev```
- The compare branch is the one you want to merge into ```dev```, in this case, ```new_branch```
- Click "Create pull request"
- Make sure to add a name and description to your pull request so other team members are aware of the changes being made

### Integrating Code Changes into Codebase for Release
- After creating a pull request, on the right hand side, you can select a reviewer
- The reviewer will then get a notice in their emails telling them a pull request has been made and review is needed for merging
- The reviewer will then go through the code and look at the updates
- The reviewer can make comments and re-request changes
- You can directly commit again in this case to the same branch and it will appear in the current active pull request
- You can then re-request review
- Once the reviewer is happy, they can "resolve" all comments they had and click "merge" to add contents in the new branch to the ```dev``` branch
- The ```dev``` branch will now be updated and can these changes can be downloaded to your own computer with
```
git checkout dev
git pull origin
```
