### Last Meeting Recap
- You can collaborate on the same codebase with several team members by using ```branch``` and ```merge```
  1) Create a new branch by branching from ```dev```
  2) Introduce code changes into your new branch
  3) ```push``` your branch to GitHub
  4) Open a pull request
  5) Have the request reviewed, if reviews are positive, then it can be ```merged``` into ```dev```
  6) Everyone can then have access to the new functionalities by pulling the updated ```dev``` branch

### Why Collaboration is Important?
- Team members should be working on the same codebase for:
  - Reproducibility
  - Code quality
  - Efficiency of including new functionalities
  - Sharebility with existing or new members
  - Scalability for large projects or projects that last very long
- Team members all working on their own version of the code will result in:
  - Difficult to reproduce experiments if only one person has all the knowledge with regards to specific components
  - Lower code quality as code is not standarized or checked
  - Code overlap where several different team members spend time on different versions of the same task
  - Difficulty when sharing as code tends to get more and more "customized" for your own use instead of being shared
  - Difficult to retrace mistakes and also keep track of very large projects involving many team members

### How to Add Code Changes 
- Code changes should be added incrementally to avoid large changes over multiple files which are difficult to track when bugs occur
- You should aim to minimize the number of files you are changing at any one time
- It is important to always be concious of the code changes you are making:
  - How it impacts existing code
  - How it affects other team members
  - How it affects users
  - Whether your code changes actually contribute to an improvement in the code base, and doesn't repeat existing code
- For each branch/merge, you should aim to include code changes that contribute a SINGLE new functionality:
  - You have created a function that generates a single plot for one of your results
  - You have created a function that performs some new calculation, such as evaluating your model using a new metric
  - You have added one new processing step into the data pre/post-processing code which results in a better input/output for modelling
- Code changes should be aimed towards improving the existing code base rather than introducing completely new pipelines or workflows
  - It saves a lot of time if you adapt all your development so it aligns with what already exists
  - During development, you should actively aim to accomodate the existing code instead of making your own
  - Incrementally adding to the existing code will reduce bugs occuring
  - Even if there may be a better method, you should still follow the existing logic of the code even if it means the code might not be the most optimal
  - Major changes such as adding new pipelines or creating new logic flows should be performed seperately and should not be contributed as a part of improving the current functionality
  - Different developers have different styles and habits, so it is very important for all team members to actively work together to harmonise each others code. You should not be changing parts of the code base to make yourself feel comfortable. Even if you see a mistake somewhere unrelated to the component you are currently working on, you should not try to fix it until you have discussed this with another team member.
  - When every team member develops in the same framework, collaboration becomes much easier and efficient

### CI/CD (Continuous Integration/Continous Delivery)
- CT/CD is one of the most important principles in software development and is used by most software companies
- CI/CD automates many parts of the collaboration process which significantly increases productivity and the rate at which new features are released
- CI (continuous integration) involves:
  - Automatically incorporating code changes
  - Checking if code changes made have impacted the existing code
  - Integrating, or adding, the new changes automatically if certain criteria are met
 - CD (continous delivery) invovles:
  - Automatically deploying your code to production
  - Performing checks to ensure your code performs the correct functionality

### GitHub Actions
- GitHub actions are used to for CI/CD
- The actions are defined as workflow and are located here in the codebase: ```.github/workflows/```
- There are currently two actions, one for the ```dev``` branch and one for the ```prod``` branch
- The actions are configured using a language called YAML
  1) Define when the action is executed (on pull request) with ```on```
  2) Define name/permission with ```name``` and ```permissions```
  3) Define workflow with ```jobs```
  4) Include the content of each task inside the workflow which performs some sort of test
  5) You can also link asks together inside a ```job``` by using ```needs```. You will be able to visualize your action workflow in the 4th tab of GitHub on the top called "Actions"

### Putting this into Practice for Our Code Base
- Make sure your code is up to date
```
git checkout dev
git pull origin
```
- Make new branch
```
git branch new_branch_name
git checkout new_branch_name
```
- Make your code changes (try to only stick with changing only one file at a time) and commit your changes
```
git add name_of_file_updated
git commit -m "commited a change in file X for a new functionality"
```
- Run the entirely workflow again on your own computer which runs the preprocessing, modelling, and post processing (for non-linux, you can just run each file individually but MAKE SURE you run all the files)
```
src/run_UKB_cTI_subset.sh 
```
- At the end of the file, the workflow uses library ```pytest``` in python to run tests on the outputs of the workflow. Speficially it checks the files in ```src/fmrib/NeuroPM/io```
- ```python ./test/init.py``` configures the test outputs
- ```pytest ./test/test_neuropm.py``` runs the tests and stores the outputs
- The outputs are stored in ```test/test.json``` which is a dictionary containing key-value pairs for whether a certain test has passed or not
- After running the tests, you can add any updates and push your branch to GitHub
```
git add .
git commit -m "ran tests for CI"
git push --set-upstream origin new_branch_name
```
- Go to github and click the third tab "Pull Request", select your branch on the right and ```dev``` as the base branch on the left to merge into. Finally click open pull request.
- You will now see the test run. If it has passed, then you can click "merge" and your branch will be merged into ```dev``` without anyone having to review it
