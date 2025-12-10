# CPD_Install

See: https://git-scm.com/cheat-sheet  
  
My Git repository for CPD install scripts. Manage each version in a separate branch.  
git branch/checkout CPD_5.1.1  
When ready, (other options: rebase, cherry-pick <commit>)  
  git switch master  
  git merge --squash <branch>  
  
To update the branch with the master (README.md, .gitignore, etc.):  
  git switch <branch>  
  git rebase master  

Other:  
  git remote add origin https://github.ibm.com/reutlinger/CPD_Install.git
  git push -u origin master

  git remote add public https://github.com/raanonr/CPD_Install.git
  git remote -v
  git push public master
  git push public CPD_5.1.1
