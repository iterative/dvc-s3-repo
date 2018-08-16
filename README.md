# dvc-s3-repo
Maintain deb and rpm repositories on s3

## DEB repository
Add to your `/etc/apt/sources.list`
```
deb [trusted=yes] https://s3-us-east-2.amazonaws.com/dvc-deb/ stable main
```
