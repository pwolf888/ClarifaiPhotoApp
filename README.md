# Snapoetry App

## How to clone:

- Download SourceTree - https://www.sourcetreeapp.com/
- Sign into SourceTree using your GitHub details
- You should now see a window with options local and remote at the top left
- Select remote
- You should see Snapoetry
- Select "Clone"
- Choose where you want to save the repository
- Open it either by double clicking the clarifaiApp.xcworkspace file or through Xcode

## How to install Pods
I have implemented pods into the project, so you just need to make sure the frameworks are installed on your end. How to get it working for you:

1. Use your terminal (if you need terminal help let me know) to access the root folder of the project (there will be a file called podfile in there). I find the easiest way to do this is to type *cd* in terminal, then just drag the root folder into the finder window, and press enter.

2. Type *Pod install --verbose* (The verbose allows you to see the lines of code being processed)

3. Open the app in xcode by using the clarifaiApp.xcworkspace file, and make sure xcode isnt complaining about missing modules.


## How to create branch and pull request:
- In SourceTree, click on branch
- Select which branch you want to branch off (typically master but not always)
- Name branch with naming convention type/title-of-change i.e. feature/login-button
- Create branch
- Press commit
- Tick the files you wish to commit
- Add note, your note should explain what changes were made
- Press push, tick the branch you want to push
- Open GitHub and go to pull requests
- Create pull request

Note: I would recommend creating a branch before you start working on a new area of the app, and then creating a pull request. This will mean that everyone else will be able to see what it is you are working on. A pull request can stay open until you are ready to merge your changes with the master file. **DO NOT MERGE A PULL REQUEST WITHOUT FIRST CHECKING WITH THE OTHER TEAM MEMBERS.**
